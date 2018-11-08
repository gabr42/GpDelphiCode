program MemAtomic;

uses
  Vcl.Forms,
  MemAtomicMain in 'MemAtomicMain.pas' {frmMemSpeed};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMemSpeed, frmMemSpeed);
  Application.Run;
end.
