unit FMXMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TFormMain = class(TForm)
    btnClose: TButton;
    procedure btnCloseClick(Sender: TObject);
  private
  public
  end;

procedure ShowMainForm; stdcall;
procedure InitGDIP; stdcall;
procedure FreeGDIP; stdcall;

implementation

uses
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ;

{$R *.fmx}

procedure InitGDIP;
begin
  // Initialize StartupInput structure
  StartupInput.DebugEventCallback := nil;
  StartupInput.SuppressBackgroundThread := False;
  StartupInput.SuppressExternalCodecs   := False;
  StartupInput.GdiplusVersion := 1;

  GdiplusStartup(gdiplusToken, @StartupInput, nil);
end;

procedure FreeGDIP;
begin
  if Assigned(GenericSansSerifFontFamily) then
    GenericSansSerifFontFamily.Free;
  if Assigned(GenericSerifFontFamily) then
    GenericSerifFontFamily.Free;
  if Assigned(GenericMonospaceFontFamily) then
    GenericMonospaceFontFamily.Free;
  if Assigned(GenericTypographicStringFormatBuffer) then
    GenericTypographicStringFormatBuffer.free;
  if Assigned(GenericDefaultStringFormatBuffer) then
    GenericDefaultStringFormatBuffer.Free;

  GdiplusShutdown(gdiplusToken);
end;

procedure ShowMainForm; stdcall;
var
  FormMain: TFormMain;
begin
//  InitGDIP;
  Application.Title := 'DLL Form';
  FormMain := TFormMain.Create(Application);
  FormMain.ShowModal;
  FormMain.Free;
//  Application.Terminate;
//  Application.ProcessMessages;
//  FreeGDIP;
end;

{ TFormMain }

procedure TFormMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
