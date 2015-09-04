unit GameLobbyForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, PacketFactory, DataCollection, Client;

type
  TfrmGameLobby = class(TForm)
    lbPlayers: TListBox;
    lblUsername: TLabel;
    lblWins: TLabel;
    btnKickPlayer: TButton;
    btnStartGame: TButton;
    eMessages: TMemo;
    eInput: TEdit;
    btnSend: TButton;
    InterfaceUpdate: TTimer;
    btnLeaveGame: TButton;
    procedure btnSendClick(Sender: TObject);
    procedure eInputKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure InterfaceUpdateTimer(Sender: TObject);
    procedure btnStartGameClick(Sender: TObject);
    procedure btnKickPlayerClick(Sender: TObject);
    procedure btnLeaveGameClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    {Private declarations}
  public
    {Public declarations}
  end;

var
  frmGameLobby: TfrmGameLobby;

implementation

uses LobbyForm, GameForm;
{$R *.dfm}

procedure TfrmGameLobby.btnKickPlayerClick(Sender: TObject);
var
  playeruid: Integer;
begin
  if lbPlayers.ItemIndex = -1 then
    Exit;
  LobbyInformation.Lock;
  playeruid:=LobbyInformation.FPlayers[lbPlayers.ItemIndex].uid;
  LobbyInformation.Unlock;
  c.SendPacket(TPacketFactory.KickPlayer(playeruid));
end;

procedure TfrmGameLobby.btnLeaveGameClick(Sender: TObject);
begin
  c.SendPacket(TPacketFactory.LeaveGame);
end;

procedure TfrmGameLobby.btnSendClick(Sender: TObject);
begin
  c.SendPacket(TPacketFactory.Chat(eInput.Text));
  eInput.Text:='';
  eInput.SetFocus;
end;

procedure TfrmGameLobby.btnStartGameClick(Sender: TObject);
begin
  c.SendPacket(TPacketFactory.StartGame);
end;

procedure TfrmGameLobby.eInputKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key:=#0;
    btnSend.Click;
  end;
end;

procedure TfrmGameLobby.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ExitProcess(0);
end;

procedure TfrmGameLobby.FormShow(Sender: TObject);
begin
  lbPlayers.Clear;
  eMessages.Clear;
  eInput.Clear;
end;

procedure TfrmGameLobby.InterfaceUpdateTimer(Sender: TObject);
var
  i, selindex: Integer;
begin
  lblUsername.Caption:='Username: ' + c.Player.username;
  lblWins.Caption:='Wins: ' + IntToStr(c.Player.wins);
  LobbyInformation.Lock;
  if LobbyInformation.FOwnerID <> c.Player.uid then
  begin
    btnStartGame.Enabled:=False;
    btnKickPlayer.Enabled:=False;
  end
  else
  begin
    btnStartGame.Enabled:=True;
    if lbPlayers.ItemIndex = -1 then
      btnKickPlayer.Enabled:=False
    else
      btnKickPlayer.Enabled:=True;
  end;
  LobbyInformation.Unlock;
  {* Update Players *}
  selindex:=lbPlayers.ItemIndex;
  lbPlayers.Clear;
  LobbyInformation.Lock;
  for i:=0 to High(LobbyInformation.FPlayers) do
    lbPlayers.AddItem(LobbyInformation.FPlayers[i].username + ' - ' + IntToStr(LobbyInformation.FPlayers[i].wins) + ' Wins', nil);
  LobbyInformation.Unlock;
  if selindex < lbPlayers.Items.Count then
    lbPlayers.ItemIndex:=selindex;
  {* Update Title *}
  LobbyInformation.Lock;
  Caption:='Set Online Game Lobby: ' + LobbyInformation.FRoomName;
  LobbyInformation.Unlock;
end;

end.
