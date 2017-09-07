program xCode;

uses
  Vcl.Forms,
  xCodeMain in 'xCodeMain.pas' {frmXifyCode};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmXifyCode, frmXifyCode);
  Application.Run;
end.
