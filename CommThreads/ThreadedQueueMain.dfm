object frmThreadedQueue: TfrmThreadedQueue
  Left = 0
  Top = 0
  Caption = 'frmThreadedQueue'
  ClientHeight = 305
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    633
    305)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 128
    Top = 48
    Width = 47
    Height = 13
    Caption = 'messages'
  end
  object Edit1: TEdit
    Left = 16
    Top = 16
    Width = 159
    Height = 21
    TabOrder = 0
    Text = 'Communication!'
  end
  object SpinEdit1: TSpinEdit
    Left = 65
    Top = 45
    Width = 57
    Height = 22
    MaxValue = 10000
    MinValue = 1
    TabOrder = 2
    Value = 10
  end
  object Button1: TButton
    Left = 16
    Top = 43
    Width = 41
    Height = 25
    Caption = 'Send'
    TabOrder = 1
    OnClick = Button1Click
  end
  object ListBox1: TListBox
    Left = 200
    Top = 16
    Width = 417
    Height = 275
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 3
  end
  object Button2: TButton
    Left = 16
    Top = 74
    Width = 159
    Height = 25
    Caption = 'Send with TSingleCopyThread'
    TabOrder = 4
    OnClick = Button2Click
  end
end
