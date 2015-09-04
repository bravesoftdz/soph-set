program SetClient;

uses
  Forms,
  LoginForm in 'LoginForm.pas' {frmLogin},
  PacketStream in 'Client\PacketStream.pas',
  Client in 'Client\Client.pas',
  PacketFactory in 'Client\PacketFactory.pas',
  Player in 'Client\Player.pas',
  LobbyForm in 'LobbyForm.pas' {frmLobby},
  GameLobbyForm in 'GameLobbyForm.pas' {frmGameLobby},
  GameForm in 'GameForm.pas' {frmGame},
  DataCollection in 'Client\DataCollection.pas',
  Game in 'Client\Game.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmLobby, frmLobby);
  Application.CreateForm(TfrmGameLobby, frmGameLobby);
  Application.CreateForm(TfrmGame, frmGame);
  Application.Run;
end.
