unit OnIdleMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmOnIdle = class(TForm)
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
  private
    procedure HandleIdle(Sender: TObject; var Done: boolean);
  public
  end;

var
  frmOnIdle: TfrmOnIdle;

implementation

{$R *.dfm}

procedure TfrmOnIdle.FormCreate(Sender: TObject);
begin
  Application.OnIdle := HandleIdle;
end;

procedure TfrmOnIdle.HandleIdle(Sender: TObject; var Done: boolean);
begin
  ListBox1.ItemIndex := ListBox1.Items.Add(FormatDateTime('hh:mm:ss.zzz', Now));
  Done := True;
end;

end.
