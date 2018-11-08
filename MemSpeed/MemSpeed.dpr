program MemSpeed;

uses
  Vcl.Forms,
  MemSpeedMain in 'MemSpeedMain.pas' {frmMemSpeed};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMemSpeed, frmMemSpeed);
  Application.Run;
end.
