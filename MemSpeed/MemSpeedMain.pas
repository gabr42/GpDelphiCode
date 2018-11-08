unit MemSpeedMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmMemSpeed = class(TForm)
    btnMeasure: TButton;
    dlgSave: TFileSaveDialog;
    procedure btnMeasureClick(Sender: TObject);
  private
    procedure Asy_RunTest;
    procedure SaveToFile(const data: string);
  public
  end;

var
  frmMemSpeed: TfrmMemSpeed;

implementation

uses
  System.Diagnostics, System.Generics.Collections;

{$R *.dfm}

const
  CNumRuns    = 10;
  CNumData    = 1024;
  CNumRepeats = 1000000;

procedure TfrmMemSpeed.btnMeasureClick(Sender: TObject);
begin
  btnMeasure.Caption := 'Working ...';
  btnMeasure.Enabled := false;
  TThread.CreateAnonymousThread(Asy_RunTest).Start;
end;

procedure TfrmMemSpeed.Asy_RunTest;
var
  buffer : PByte;
  iData  : integer;
  iRepeat: integer;
  iRun   : integer;
  min    : int64;
  pData  : PNativeUInt;
  s      : string;
  time   : TStopwatch;
  timing : array [1..CNumData, 1..CNumRuns] of int64;
begin
  try
    Sleep(1000); // wait a bit; removes noise at the beginning

    buffer := VirtualAlloc(nil, CNumData + SizeOf(NativeUInt), MEM_RESERVE + MEM_COMMIT, PAGE_READWRITE);
    Assert(assigned(buffer));
    try
      TThread.Current.Priority := tpTimeCritical;

      for iRun := 1 to CNumRuns do begin
        for iData := 1 to CNumData do begin
          pData := @buffer[iData-1];
          time := TStopwatch.Create;
          Sleep(0); // wait for timeslice
          time.Start;
          for iRepeat := 1 to CNumRepeats do begin
            pData^ := {$IFDEF X64}$F0F0F0F0F0F0F0F0{$ELSE}$F0F0F0F0{$ENDIF};
            pData^ := {$IFDEF X64}$0F0F0F0F0F0F0F0F{$ELSE}$0F0F0F0F{$ENDIF};
          end;
          time.Stop;
          timing[iData, iRun] := time.ElapsedTicks;
        end;
      end;

      TThread.Current.Priority := tpNormal;
    finally
      VirtualFree(buffer, CNumData + SizeOf(NativeUInt), MEM_RELEASE);
    end;

    s := '';
    for iData := 1 to CNumData do begin
      min := timing[iData, 1];
      for iRun := 2 to CNumRuns do
        if timing[iData, iRun] < min then
          min := timing[iData, iRun];
      s := s + IntToStr(min) + #13#10;
    end;

    TThread.Queue(nil, procedure begin
      SaveToFile(s);
      btnMeasure.Caption := 'Measure!';
      btnMeasure.Enabled := true;
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

procedure TfrmMemSpeed.SaveToFile(const data: string);
var
  f: textfile;
begin
  if dlgSave.Execute then begin
    AssignFile(f, dlgSave.FileName);
    Rewrite(f);
    Writeln(f, data);
    CloseFile(f);
  end;
end;

end.
