object frmMemSpeed: TfrmMemSpeed
  Left = 0
  Top = 0
  Caption = 'MemAtomic'
  ClientHeight = 111
  ClientWidth = 254
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnTest: TButton
    Left = 24
    Top = 24
    Width = 201
    Height = 65
    Caption = 'Test!'
    TabOrder = 0
    OnClick = btnTestClick
  end
  object dlgSave: TFileSaveDialog
    DefaultExtension = '.txt'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Text file'
        FileMask = '*.txt'
      end>
    Options = []
    Left = 184
    Top = 32
  end
end
