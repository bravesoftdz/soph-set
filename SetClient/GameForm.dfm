object frmGame: TfrmGame
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Set Online'
  ClientHeight = 279
  ClientWidth = 681
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  PixelsPerInch = 96
  TextHeight = 13
  object lbPlayers: TListBox
    Left = 520
    Top = 0
    Width = 161
    Height = 280
    Ctl3D = False
    ItemHeight = 13
    ParentCtl3D = False
    TabOrder = 0
  end
  object btnCheat: TButton
    Left = 656
    Top = 256
    Width = 17
    Height = 17
    Caption = 'C'
    TabOrder = 1
    OnClick = btnCheatClick
  end
  object GameTimer: TTimer
    Interval = 1
    OnTimer = GameTimerTimer
    Left = 648
    Top = 8
  end
  object CheatOff: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = CheatOffTimer
    Left = 648
    Top = 56
  end
end
