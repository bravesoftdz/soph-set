unit LobbyForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Client, PacketFactory, DataCollection;

type
  TfrmLobby = class(TForm)
    lbGames: TListBox;
    lblUsername: TLabel;
    lblWins: TLabel;
    btnCreateGame: TButton;
    btnJoinGame: TButton;
    eMessages: TMemo;
    eInput: TEdit;
    btnSend: TButton;
    InterfaceUpdate: TTimer;
    lbPlayers: TListBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure InterfaceUpdateTimer(Sender: TObject);
    procedure btnCreateGameClick(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure eInputKeyPress(Sender: TObject; var Key: Char);
    procedure btnJoinGameClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    {Private declarations}
  public
    {Public declarations}
  end;

var
  frmLobby: TfrmLobby;

implementation

{$R *.dfm}

uses
  GameLobbyForm, LoginForm, GameForm;

procedure TfrmLobby.btnCreateGameClick(Sender: TObject);
var
  GameName: String;
begin
  GameName:='';
  if InputQuery('Set Online', 'Please Enter a Game Name:', GameName) then
    c.SendPacket(TPacketFactory.CreateGame(GameName));
end;

procedure TfrmLobby.btnJoinGameClick(Sender: TObject);
var
  ownerid: Integer;
begin
  if lbGames.ItemIndex = -1 then
    Exit;
  LobbyInformation.Lock;
  ownerid:=LobbyInformation.FGames[lbGames.ItemIndex].owneruid;
  LobbyInformation.Unlock;
  c.SendPacket(TPacketFactory.JoinGame(ownerid));
end;

procedure TfrmLobby.btnSendClick(Sender: TObject);
begin
  c.SendPacket(TPacketFactory.Chat(eInput.Text));
  eInput.Text:='';
  eInput.SetFocus;
end;

procedure TfrmLobby.eInputKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key:=#0;
    btnSend.Click;
  end;
end;

procedure TfrmLobby.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ExitProcess(0);
end;

procedure TfrmLobby.FormShow(Sender: TObject);
begin
  lbGames.Clear;
  lbPlayers.Clear;
  eMessages.Clear;
  eInput.Clear;
end;

procedure TfrmLobby.InterfaceUpdateTimer(Sender: TObject);
var
  i, selindex: Integer;
begin
  lblUsername.Caption:='Username: ' + c.Player.username;
  lblWins.Caption:='Wins: ' + IntToStr(c.Player.wins);
  {* Update Players *}
  selindex:=lbPlayers.ItemIndex;
  lbPlayers.Clear;
  LobbyInformation.Lock;
  for i:=0 to High(LobbyInformation.FPlayers) do
    lbPlayers.AddItem(LobbyInformation.FPlayers[i].username + ' - ' + IntToStr(LobbyInformation.FPlayers[i].wins) + ' Wins', nil);
  LobbyInformation.Unlock;
  if selindex < lbPlayers.Items.Count then
    lbPlayers.ItemIndex:=selindex;
  {* Update Games *}
  selindex:=lbGames.ItemIndex;
  lbGames.Clear;
  LobbyInformation.Lock;
  for i:=0 to High(LobbyInformation.FGames) do
    lbGames.AddItem('Name: ' + LobbyInformation.FGames[i].name + ' (Owner: ' + LobbyInformation.FGames[i].ownername + ') - Players: ' + IntToStr(LobbyInformation.FGames[i].Count), nil);
  LobbyInformation.Unlock;
  if selindex < lbGames.Items.Count then
    lbGames.ItemIndex:=selindex;
  {* Other Touches *}
  if lbGames.ItemIndex = -1 then
    btnJoinGame.Enabled:=False
  else
    btnJoinGame.Enabled:=True;
end;

end.
