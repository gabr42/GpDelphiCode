unit DLLHostMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TShowMainForm = procedure; stdcall;

  TFormHost = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FLibHandle: THandle;
    FShowMain: TShowMainForm;
  public
  end;

var
  FormHost: TFormHost;

implementation

{$R *.dfm}

procedure TFormHost.Button1Click(Sender: TObject);
begin
  FShowMain();
end;

procedure TFormHost.FormDestroy(Sender: TObject);
begin
  if FLibHandle <> 0 then begin
    FreeLibrary(FLibHandle);
    FLibHandle := 0;
  end;
end;

procedure TFormHost.FormCreate(Sender: TObject);
begin
  FLibHandle := LoadLibrary('FMXDLL');
  if FLibHandle = 0 then begin
    ShowMessage('Cannot load FMXDLL.DLL');
    Application.Terminate;
  end
  else begin
    FShowMain := GetProcAddress(FLibHandle, 'ShowMainForm');
    if not assigned(FShowMain) then begin
      ShowMessage('Missing export: ShowMainForm');
      Application.Terminate;
    end;
  end;
end;

end.
