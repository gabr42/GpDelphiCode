unit MemAtomicMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.SyncObjs, System.Threading,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmMemSpeed = class(TForm)
    btnTest: TButton;
    dlgSave: TFileSaveDialog;
    procedure btnTestClick(Sender: TObject);
  private
    FError: boolean;
    FEndEvent: TEvent;
    FPrepareEvent: TEvent;
    FStartEvent: TEvent;
    FNumRunning: integer;
    procedure Asy_RunTest;
    procedure Asy_Reader(pData: pointer; dataSize: integer);
    function Asy_Start(action: TProc<pointer,integer>; pData: pointer;
      dataSize: integer): ITask;
    procedure Asy_Writer(pData: pointer; dataSize: integer);
    procedure LogErrors(const errors: TArray<string>);
  public
  end;

var
  frmMemSpeed: TfrmMemSpeed;

implementation

uses
  System.Diagnostics, System.Generics.Collections;

{$R *.dfm}

const
  CNumData         = 128;
  CTestDuration_ms = 100;
  CLowSize         = 0; // log2(1)
  CHighSize        = 3; // log2(8)

procedure TfrmMemSpeed.Asy_Writer(pData: pointer; dataSize: integer);
var
  timer: TStopwatch;
begin
  timer := TStopwatch.StartNew;
  while timer.ElapsedMilliseconds < CTestDuration_ms do begin
    case dataSize of
      1:
        begin
          PByte(pData)^ := $12;
          PBYte(pData)^ := $21;
        end;
      2:
        begin
          PWord(pData)^ := $1223;
          PWord(pData)^ := $3221;
        end;
      4:
        begin
          PDWord(pData)^ := $12233445;
          PDWord(pData)^ := $54433221;
        end;
      8:
        begin
          PULONGLONG(pData)^ := $1223344556677889;
          PULONGLONG(pData)^ := $9887766554433221;
        end;
      else
        raise Exception.Create('Unsupported data size');
    end;
  end;
end;

procedure TfrmMemSpeed.Asy_Reader(pData: pointer; dataSize: integer);
var
  bData : byte;
  dwData: DWORD;
  qwData : uint64;
  timer : TStopwatch;
  wData : word;
begin
  while PDWord(pData)^ = 0 do
    ;

  timer := TStopwatch.StartNew;
  while timer.ElapsedMilliseconds < CTestDuration_ms do begin
    case dataSize of
      1:
        begin
          bData := PByte(pData)^;
          if (bData <> $12) and (bData <> $21) then
            FError := true;
        end;
      2:
        begin
          wData := PWord(pData)^;
          if (wData <> $1223) and (wData <> $3221) then
            FError := true;
        end;
      4:
        begin
          dwData := PDWord(pData)^;
          if (dwData <> $12233445) and (dwData <> $54433221) then
            FError := true;
        end;
      8:
        begin
          qwData := PULONGLONG(pData)^;
          if (qwData <> $1223344556677889) and (qwData <> $9887766554433221) then
            FError := true;
        end;
      else
        raise Exception.Create('Unsupported data size');
    end;
  end;
end;

procedure TfrmMemSpeed.btnTestClick(Sender: TObject);
begin
  btnTest.Caption := 'Testing ...';
  btnTest.Enabled := false;
  TThread.CreateAnonymousThread(Asy_RunTest).Start;
end;

procedure TfrmMemSpeed.LogErrors(const errors: TArray<string>);
var
  iSize: integer;
  s    : string;
begin
  s := '';
  for iSize := CLowSize to CHighSize do
    s := s + IntToStr(1 SHL iSize) + ': ' + errors[iSize - CLowSize] + #13#10;
  ShowMessage(s);
end;

procedure TfrmMemSpeed.Asy_RunTest;
var
  buffer: PByte;
  errors: TArray<string>;
  iData : integer;
  iSize : integer;
  pData : PNativeUInt;
  s     : string;
  task1 : ITask;
  task2 : ITask;
begin
  try
    Sleep(1000); // wait a bit; removes noise at the beginning

    SetLength(errors, CHighSize - CLowSize + 1);
    buffer := VirtualAlloc(nil, CNumData + 8, MEM_RESERVE + MEM_COMMIT, PAGE_READWRITE);
    Assert(assigned(buffer));
    try
      FPrepareEvent := TEvent.Create;
      try
        FStartEvent := TEvent.Create;
        try
          FEndEvent := TEvent.Create;
          try
            for iData := 1 to CNumData do begin
              for iSize := 0 to 3 do begin
                FPrepareEvent.ResetEvent;
                FStartEvent.ResetEvent;
                FEndEvent.ResetEvent;

                FError := false;
                pData := @buffer[iData-1];

                PULONGLONG(pData)^ := 0;
                task1 := Asy_Start(Asy_Reader, pData, 1 SHL iSize);
                task2 := Asy_Start(Asy_Writer, pData, 1 SHL iSize);

                FPrepareEvent.WaitFor(INFINITE);
                FStartEvent.SetEvent;
                FEndEvent.WaitFor(INFINITE);

                if FError then
                  errors[iSize - CLowSize] := errors[iSize - CLowSize] + IntToStr(iData - 1) + ' ';

                task1.Wait(INFINITE);
                task2.Wait(INFINITE);
                task1 := nil;
                task2 := nil;
              end;
            end;
          finally FreeAndNil(FEndEvent); end;
        finally FreeAndNil(FStartEvent); end;
      finally FreeAndNil(FPrepareEvent); end;
    finally
      VirtualFree(buffer, CNumData + SizeOf(NativeUInt), MEM_RELEASE);
    end;

    TThread.Queue(nil, procedure begin
      LogErrors(errors);
      btnTest.Caption := 'Test!';
      btnTest.Enabled := true;
    end);
  except
    on E: Exception do begin
      s := E.ClassName + ': ' + E.Message;
      TThread.Queue(nil, procedure begin
        ShowMessage(s);
      end);
    end;
  end;
end;

function TfrmMemSpeed.Asy_Start(action: TProc<pointer,integer>;
  pData: pointer; dataSize: integer): ITask;
begin
  Result := TTask.Run(
    procedure
    begin
      if TInterlocked.Increment(FNumRunning) = 2 then
        FPrepareEvent.SetEvent;
      FStartEvent.WaitFor(INFINITE);
      action(pData, dataSize);
      if TInterlocked.Decrement(FNumRunning) = 0 then
        FEndEvent.SetEvent;
    end);
end;

end.
