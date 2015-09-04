object frmGameLobby: TfrmGameLobby
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Set Online Game Lobby'
  ClientHeight = 468
  ClientWidth = 387
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblUsername: TLabel
    Left = 8
    Top = 8
    Width = 73
    Height = 13
    Caption = 'Username: N/A'
  end
  object lblWins: TLabel
    Left = 8
    Top = 27
    Width = 48
    Height = 13
    Caption = 'Wins: N/A'
  end
  object lbPlayers: TListBox
    Left = 8
    Top = 46
    Width = 265
    Height = 195
    ItemHeight = 13
    TabOrder = 0
  end
  object btnKickPlayer: TButton
    Left = 279
    Top = 73
    Width = 98
    Height = 21
    Caption = 'Kick Player'
    TabOrder = 1
    OnClick = btnKickPlayerClick
  end
  object btnStartGame: TButton
    Left = 279
    Top = 46
    Width = 98
    Height = 21
    Caption = 'Start Game'
    TabOrder = 2
    OnClick = btnStartGameClick
  end
  object eMessages: TMemo
    Left = 8
    Top = 247
    Width = 369
    Height = 185
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object eInput: TEdit
    Left = 8
    Top = 438
    Width = 305
    Height = 21
    TabOrder = 4
    OnKeyPress = eInputKeyPress
  end
  object btnSend: TButton
    Left = 319
    Top = 438
    Width = 58
    Height = 21
    Caption = 'Send'
    TabOrder = 5
    OnClick = btnSendClick
  end
  object btnLeaveGame: TButton
    Left = 279
    Top = 100
    Width = 98
    Height = 21
    Caption = 'Leave Game'
    TabOrder = 6
    OnClick = btnLeaveGameClick
  end
  object InterfaceUpdate: TTimer
    Interval = 300
    OnTimer = InterfaceUpdateTimer
    Left = 344
    Top = 8
  end
end
