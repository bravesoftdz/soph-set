unit LoginForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Client, StdCtrls, PacketStream, PacketFactory, ExtCtrls;

type
  TfrmLogin = class(TForm)
    lblTitle: TLabel;
    lblUsername: TLabel;
    eUsername: TEdit;
    lblPassword: TLabel;
    ePassword: TEdit;
    btnLogin: TButton;
    OpenLobbyTimer: TTimer;
    btnREgister: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ePasswordKeyPress(Sender: TObject; var Key: Char);
    procedure eUsernameKeyPress(Sender: TObject; var Key: Char);
    procedure btnLoginClick(Sender: TObject);
    procedure OpenLobbyTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnREgisterClick(Sender: TObject);
  private
    {Private declarations}
  public
    {Public declarations}
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

uses LobbyForm, GameLobbyForm, GameForm;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
begin
  c.SendPacket(TPacketFactory.LoginPacket(eUsername.Text, ePassword.Text));
end;

procedure TfrmLogin.btnREgisterClick(Sender: TObject);
begin
  c.SendPacket(TPacketFactory.RegisterPacket(eUsername.Text, ePassword.Text));
end;

procedure TfrmLogin.ePasswordKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key:=#0;
    btnLogin.Click;
  end;
end;

procedure TfrmLogin.eUsernameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key:=#0;
    ePassword.SetFocus;
  end;
end;

procedure TfrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ExitProcess(0);
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  if not InitializeClient then
  begin
    MessageBox(0, PChar('Unable to connect to server. Please try again later.'), 'Set Online', MB_ICONERROR);
    ExitProcess(0);
  end;
end;

procedure TfrmLogin.OpenLobbyTimerTimer(Sender: TObject);
var
  AccessHandle: THandle;
begin
  if UpdateInterface then
  begin
    UpdateInterface:=False;
    case c.FGameState of
      GS_LOGIN:
        begin
          frmLogin.Show;
          frmLobby.Hide;
          frmGameLobby.Hide;
          frmGame.Hide;
        end;
      GS_LOBBY:
        begin
          frmLogin.Hide;
          frmLobby.Left:=frmGameLobby.Left;
          frmLobby.Top:=frmGameLobby.Top;
          frmLobby.Show;
          frmGameLobby.Hide;
          frmGame.Hide;
        end;
      GS_ROOM:
        begin
          frmLogin.Hide;
          frmLobby.Hide;
          frmGameLobby.Left:=frmLobby.Left;
          frmGameLobby.Top:=frmLobby.Top;
          frmGameLobby.Show;
          frmGame.Hide;
        end;
      GS_INGAME:
        begin
          frmLogin.Hide;
          frmLobby.Hide;
          frmGameLobby.Hide;
          frmGame.Show;
        end;
    end;
  end;
  if IncomingMessage then
  begin
    IncomingMessage:=False;
    case c.FGameState of
      GS_LOGIN:
        AccessHandle:=frmLogin.Handle;
      GS_LOBBY:
        AccessHandle:=frmLobby.Handle;
      GS_ROOM:
        AccessHandle:=frmGameLobby.Handle;
      GS_INGAME:
        AccessHandle:=frmGame.Handle;
    else
      AccessHandle:=0;
    end;
    MessageBox(AccessHandle, PChar(IncomingMessageStr), 'Set Online', MB_ICONHAND);
  end;
end;

end.
