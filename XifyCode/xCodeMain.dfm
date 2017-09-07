object frmXifyCode: TfrmXifyCode
  Left = 0
  Top = 0
  Caption = 'X-ify Code'
  ClientHeight = 336
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    635
    336)
  PixelsPerInch = 96
  TextHeight = 13
  object lblKudos: TLabel
    Left = 213
    Top = 312
    Width = 209
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Great thanks to Kevlin Henney for the idea!'
  end
  object inpCode: TMemo
    Left = 8
    Top = 8
    Width = 619
    Height = 298
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      'Paste some code here ...')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object ActionList: TActionList
    Left = 32
    Top = 40
    object EditPaste: TEditPaste
      Category = 'Edit'
      Caption = '&Paste'
      Hint = 'Paste|Inserts Clipboard contents'
      ImageIndex = 2
      ShortCut = 16470
      OnExecute = EditPasteExecute
    end
  end
end
