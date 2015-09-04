object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Set Online'
  ClientHeight = 156
  ClientWidth = 199
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
  PixelsPerInch = 96
  TextHeight = 13
  object lblTitle: TLabel
    Left = 44
    Top = 9
    Width = 99
    Height = 23
    Caption = 'Set Online'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblUsername: TLabel
    Left = 8
    Top = 45
    Width = 52
    Height = 13
    Caption = 'Username:'
  end
  object lblPassword: TLabel
    Left = 9
    Top = 72
    Width = 50
    Height = 13
    Caption = 'Password:'
  end
  object eUsername: TEdit
    Left = 66
    Top = 42
    Width = 123
    Height = 21
    TabOrder = 0
    OnKeyPress = eUsernameKeyPress
  end
  object ePassword: TEdit
    Left = 67
    Top = 69
    Width = 122
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
    OnKeyPress = ePasswordKeyPress
  end
  object btnLogin: TButton
    Left = 8
    Top = 97
    Width = 181
    Height = 21
    Caption = 'Login'
    TabOrder = 2
    OnClick = btnLoginClick
  end
  object btnREgister: TButton
    Left = 8
    Top = 124
    Width = 181
    Height = 21
    Caption = 'Register'
    TabOrder = 3
    OnClick = btnREgisterClick
  end
  object OpenLobbyTimer: TTimer
    Interval = 300
    OnTimer = OpenLobbyTimerTimer
    Left = 8
    Top = 8
  end
end
