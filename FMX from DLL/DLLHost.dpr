program DLLHost;

uses
  Vcl.Forms,
  DLLHostMain in 'DLLHostMain.pas' {FormHost};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormHost, FormHost);
  Application.Run;
end.
