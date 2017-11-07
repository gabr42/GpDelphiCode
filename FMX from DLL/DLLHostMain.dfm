object FormHost: TFormHost
  Left = 0
  Top = 0
  Caption = 'DLL Host'
  ClientHeight = 231
  ClientWidth = 395
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 128
    Top = 80
    Width = 161
    Height = 65
    Caption = 'Show FMX form'
    TabOrder = 0
    OnClick = Button1Click
  end
end
