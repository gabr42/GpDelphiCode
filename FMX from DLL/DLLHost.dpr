program DLLHost;

uses
  Vcl.Forms,
  DLLHostMain in 'DLLHostMain.pas' {FormHost},
  FMXBridge in 'FMXBridge.pas';

{$R *.res}

begin
  Application.Initialize;
  FMXBridge.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormHost, FormHost);
  Application.Run;
  FMXBridge.Finalize;
end.
