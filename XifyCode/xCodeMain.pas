unit xCodeMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.StdActns,
  Vcl.StdCtrls;

type
  TfrmXifyCode = class(TForm)
    lblKudos: TLabel;
    inpCode: TMemo;
    ActionList: TActionList;
    EditPaste: TEditPaste;
    procedure EditPasteExecute(Sender: TObject);
  private
  public
  end;

var
  frmXifyCode: TfrmXifyCode;

implementation

uses
  System.Character,
  Vcl.Clipbrd;

{$R *.dfm}

function XIt(const s: string): string;
var
  i: integer;
begin
  Result := s;
  for i := 1 to Length(Result) do
    if Result[i].IsLetter or Result[i].IsNumber then
      Result[i] := 'X';
end;

procedure TfrmXifyCode.EditPasteExecute(Sender: TObject);
begin
  inpCode.Text := XIt(Clipboard.AsText);
end;

end.
