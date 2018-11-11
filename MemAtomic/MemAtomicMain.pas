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
    procedure EndTest(const errors: TArray<string>);
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
  CTestDuration_ms = 200;
  CLowSize         = 0; // log2(1)
  CHighSize        = 3; // log2(8)

type
  TAtomicWorker = class(TThread)
  strict private
    FBuffers     : array of PByte;
    FErrors      : array [0 .. CNumData - 1, CLowSize .. CHighSize] of boolean;
    FEndEvent    : TEvent;
    FPrepareEvent: TEvent;
    FStartEvent  : TEvent;
    FNumRunning  : integer;
    FNumTests    : integer;
  private
    procedure Reader(pData: pointer; pError: PBoolean; dataSize: integer);
    function  Start(action: TProc<pointer,PBoolean,integer>; pData: pointer;
      pError: PBoolean; dataSize: integer): ITask;
    procedure Writer(pData: pointer; pError: PBoolean; dataSize: integer);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure Execute; override;
  end;

procedure TfrmMemSpeed.btnTestClick(Sender: TObject);
var
  worker: TThread;
begin
  btnTest.Caption := 'Testing ...';
  btnTest.Enabled := false;
  worker := TAtomicWorker.Create(true);
  worker.FreeOnTerminate := true;
  worker.Start;
end;

procedure TfrmMemSpeed.EndTest(const errors: TArray<string>);
var
  iSize: integer;
  s    : string;
begin
  s := '';
  for iSize := CLowSize to CHighSize do
    s := s + IntToStr(1 SHL iSize) + ': ' + errors[iSize - CLowSize] + #13#10;
  ShowMessage(s);
  btnTest.Caption := 'Test!';
  btnTest.Enabled := true;
end;

{ TAtomicWorker }

procedure TAtomicWorker.AfterConstruction;
var
  iBuffer: integer;
begin
  inherited;
  FPrepareEvent := TEvent.Create;
  FStartEvent := TEvent.Create;
  FEndEvent := TEvent.Create;
  FNumTests := TThread.ProcessorCount div 2;
  SetLength(FBuffers, FNumTests);
  for iBuffer := Low(FBuffers) to High(FBuffers) do begin
    FBuffers[iBuffer] := VirtualAlloc(nil, CNumData + 8, MEM_RESERVE + MEM_COMMIT, PAGE_READWRITE);
    Assert(assigned(FBuffers[iBuffer]));
  end;
end;

procedure TAtomicWorker.BeforeDestruction;
var
  buffer: PByte;
begin
  for buffer in FBuffers do
    VirtualFree(buffer, CNumData + SizeOf(NativeUInt), MEM_RELEASE);
  FreeAndNil(FEndEvent);
  FreeAndNil(FStartEvent);
  FreeAndNil(FPrepareEvent);
  inherited;
end;

procedure TAtomicWorker.Execute;
var
  errors: TArray<string>;
  iBatch: integer;
  iData : integer;
  iSize : integer;
  isLast: boolean;
  pData : PNativeUInt;
  s     : string;
  tasks : TList<ITask>;
begin
  try
    tasks := TList<ITask>.Create;
    try
      SetLength(errors, CHighSize - CLowSize + 1);
      iBatch := FNumTests;
      for iData := 0 to CNumData - 1 do begin
        for iSize := 0 to 3 do begin
          isLast := (iData = (CNumData - 1)) and (iSize = 3);

          if iBatch = FNumTests then begin
            iBatch := 0;
            FPrepareEvent.ResetEvent;
            FStartEvent.ResetEvent;
            FEndEvent.ResetEvent;
          end;

          pData := @FBuffers[iBatch][iData];
          PULONGLONG(pData)^ := 0;
          tasks.Add(Start(Reader, pData, @FErrors[iData, iSize], 1 SHL iSize));
          tasks.Add(Start(Writer, pData, @FErrors[iData, iSize], 1 SHL iSize));

          Inc(iBatch);
          if isLast or (iBatch = FNumTests) then begin
            FPrepareEvent.WaitFor(INFINITE);
            FStartEvent.SetEvent;
            FEndEvent.WaitFor(INFINITE);
            tasks.Clear;
          end;
        end;
      end;

      for iData := 0 to CNumData - 1 do
        for iSize := 0 to 3 do
          if FErrors[iData, iSize] then
            errors[iSize - CLowSize] := errors[iSize - CLowSize] + IntToStr(iData) + ' ';

      TThread.Queue(nil, procedure begin
        frmMemSpeed.EndTest(errors);
      end);
    finally FreeAndNil(tasks); end;
  except
    on E: Exception do begin
      s := E.ClassName + ': ' + E.Message;
      TThread.Queue(nil, procedure begin
        ShowMessage(s);
      end);
    end;
  end;
end;

procedure TAtomicWorker.Reader(pData: pointer; pError: PBoolean; dataSize: integer);
var
  bData : byte;
  dwData: DWORD;
  qwData: uint64;
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
            pError^ :=true;
        end;
      2:
        begin
          wData := PWord(pData)^;
          if (wData <> $1223) and (wData <> $3221) then
            pError^ :=true;
        end;
      4:
        begin
          dwData := PDWord(pData)^;
          if (dwData <> $12233445) and (dwData <> $54433221) then
            pError^ :=true;
        end;
      8:
        begin
          qwData := PULONGLONG(pData)^;
          if (qwData <> $1223344556677889) and (qwData <> $9887766554433221) then
            pError^ :=true;
        end;
      else
        raise Exception.Create('Unsupported data size');
    end;
  end;
end;

function TAtomicWorker.Start(action: TProc<pointer,PBoolean,integer>; pData: pointer;
  pError: PBoolean; dataSize: integer): ITask;
begin
  Result := TTask.Run(
    procedure
    begin
      if TInterlocked.Increment(FNumRunning) = FNumTests then
        FPrepareEvent.SetEvent;
      FStartEvent.WaitFor(INFINITE);
      action(pData, pError, dataSize);
      if TInterlocked.Decrement(FNumRunning) = 0 then
        FEndEvent.SetEvent;
    end);
end;

procedure TAtomicWorker.Writer(pData: pointer; pError: PBoolean; dataSize: integer);
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

end.
