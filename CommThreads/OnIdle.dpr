program OnIdle;

uses
  Vcl.Forms,
  OnIdleMain in 'OnIdleMain.pas' {frmOnIdle};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmOnIdle, frmOnIdle);
  Application.Run;
end.
