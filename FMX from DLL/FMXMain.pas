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

implementation

{$R *.fmx}

procedure ShowMainForm; stdcall;
var
  FormMain: TFormMain;
begin
  FormMain := TFormMain.Create(Application);
  FormMain.ShowModal;
  FormMain.Free;
end;

{ TFormMain }

procedure TFormMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
