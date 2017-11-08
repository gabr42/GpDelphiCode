unit FMXBridge;

interface

procedure Initialize;
procedure Finalize;

implementation

uses
  Vcl.Forms, Winapi.Windows, FMX.Platform.Win, FMX.Forms,
  FMXMain;

procedure Initialize;
begin
  Fmx.Forms.Application.Initialize;
end;

procedure Finalize;
begin
  Fmx.Forms.Application.Terminate;
  Fmx.Forms.Application.HandleMessage;
end;

function VclWnd: HWND;
begin
  Result := Vcl.Forms.Application.Handle;
end;

initialization
  RegisterApplicationHWNDProc(VclWnd);

end.
