unit Client;

interface

uses
  Windows, Sysutils, Classes, PacketStream, GeneralFunctions, Player, SyncObjs, IdTCPClient,
  PacketFactory, DataCollection;

const
  SERVER_IP = '199.98.20.124';
  //SERVER_IP = 'localhost';
  SERVER_PORT = 8888;

type
  TGameState = (GS_LOGIN, GS_LOBBY, GS_ROOM, GS_INGAME);

  TSetClient = class(TThread)
  private
    FClient: TIdTCPClient;
    FPlayer: TPlayer;
    FLock: TCriticalSection;
    procedure OnClientData(p: TPacketStream);
  protected
    procedure Execute; override;
  public
    FGameState: TGameState;

    constructor Create;
    destructor Destroy; override;

    function isConnected: Boolean;
    procedure SendPacket(p: TPacketStream); overload;
    procedure SendPacket(s: String); overload;

    function Player: TPlayer;
  end;

function InitializeClient: Boolean;

var
  c: TSetClient;
  p1, p2, p3: Byte;
  UpdateInterface: Boolean;
  IncomingMessage: Boolean;
  IncomingMessageStr: String;

implementation

uses
  LoginForm, LobbyForm, GameLobbyForm;

function InitializeClient: Boolean;
begin
  c:=TSetClient.Create;
  LobbyInformation:=TLobbyInformation.Create;
  GameInformation:=TGameInformation.Create;
  Result:=c.isConnected;
end;

constructor TSetClient.Create;
begin
  FLock:=TCriticalSection.Create;
  FClient:=TIdTCPClient.Create(nil);
  FClient.Host:=SERVER_IP;
  FClient.Port:=SERVER_PORT;
  try
    FClient.Connect;
  except
  end;
  if not FClient.Connected then
  begin
    inherited Create(True);
    Exit;
  end;
  {* Initialize Variables *}
  FPlayer.uid:=0;
  FPlayer.wins:=0;
  FGameState:=GS_LOGIN;
  {* Start Thread *}
  inherited Create(False);
end;

destructor TSetClient.Destroy;
begin
  Terminate;
  FClient.Free;
  FLock.Free;
  inherited;
end;

procedure TSetClient.Execute;
var
  DataSize: Short;
  Data: TPacketStream;
begin
  while not Terminated do
  begin
    if not FClient.Connected then
      Break;
    if not FClient.IOHandler.InputBufferIsEmpty then
    begin
      Data:=TPacketStream.Create;
      try
        FClient.IOHandler.InputBufferToStream(Data, 2);
        Data.Position:=2;
        DataSize:=Data.ReadShort;
        while FClient.IOHandler.InputBuffer.Size < DataSize do
          SleepEx(1, True);
        Data.Position:=0;
        FClient.IOHandler.InputBufferToStream(Data, DataSize);
        Data.Position:=0;
        OnClientData(Data);
      except
      end;
      Data.Free;
    end;
    SleepEx(1, True);
  end;
end;

function TSetClient.isConnected: Boolean;
begin
  Result:=FClient.Connected;
end;

procedure TSetClient.OnClientData(p: TPacketStream);
var
  Header: Short;
  s: String;
  i: Integer;
begin
  {* Echo Packet (Debug) *}
  p.Position:=0;
  s:='';
  while not(p.Position = p.Size) do
    s:=s + IntToHex(p.ReadByte, 2) + ' ';
  OutputDebugString(PChar('Packet: ' + s));
  p.Position:=0;
  Header:=p.ReadShort;
  case Header of
    $01: //State
      begin
        FGameState:=TGameState(p.ReadInt);
        UpdateInterface:=True;
      end;
    $02: //Pong
      begin
        SendPacket(TPacketFactory.Pong);
      end;
    $04: //Player Info
      begin
        FPlayer.uid:=p.ReadInt;
        FPlayer.wins:=p.ReadInt;
        FPlayer.username:=p.ReadAnsiString;
      end;
    $05: //Lobby Info
      begin
        if FGameState = GS_LOBBY then
        begin
          LobbyInformation.Lock;
          SetLength(LobbyInformation.FPlayers, p.ReadShort);
          for i:=0 to High(LobbyInformation.FPlayers) do
          begin
            LobbyInformation.FPlayers[i].uid:=p.ReadInt;
            LobbyInformation.FPlayers[i].username:=p.ReadAnsiString;
            LobbyInformation.FPlayers[i].wins:=p.ReadInt;
          end;
          SetLength(LobbyInformation.FGames, p.ReadShort);
          for i:=0 to High(LobbyInformation.FGames) do
          begin
            LobbyInformation.FGames[i].owneruid:=p.ReadInt;
            LobbyInformation.FGames[i].ownername:=p.ReadAnsiString;
            LobbyInformation.FGames[i].name:=p.ReadAnsiString;
            LobbyInformation.FGames[i].count:=p.ReadInt;
          end;
          LobbyInformation.Unlock;
        end;
      end;
    $06: //Game Lobby Info
      begin
        if FGameState = GS_ROOM then
        begin
          LobbyInformation.Lock;
          LobbyInformation.FOwnerID:=p.ReadInt;
          LobbyInformation.FRoomName:=p.ReadAnsiString;
          SetLength(LobbyInformation.FPlayers, p.ReadShort);
          for i:=0 to High(LobbyInformation.FPlayers) do
          begin
            LobbyInformation.FPlayers[i].uid:=p.ReadInt;
            LobbyInformation.FPlayers[i].username:=p.ReadAnsiString;
            LobbyInformation.FPlayers[i].wins:=p.ReadInt;
          end;
          LobbyInformation.Unlock;
        end;
      end;
    $07: //Game Info
      begin
        if FGameState = GS_INGAME then
        begin
          GameInformation.Lock;
          GameInformation.FOwnerID:=p.ReadInt;
          GameInformation.FRoomName:=p.ReadAnsiString;
          SetLength(GameInformation.FPlayers, p.ReadShort);
          for i:=0 to High(GameInformation.FPlayers) do
          begin
            GameInformation.FPlayers[i].uid:=p.ReadInt;
            GameInformation.FPlayers[i].username:=p.ReadAnsiString;
            GameInformation.FPlayers[i].wins:=p.ReadInt;
            GameInformation.FPlayers[i].score:=p.ReadInt;
          end;
          SetLength(GameInformation.FCards, p.ReadShort);
          for i:=0 to High(GameInformation.FCards) do
            GameInformation.FCards[i]:=p.ReadByte;
          GameInformation.Unlock;
        end;
      end;
    $09: //Message
      begin
        IncomingMessageStr:=p.ReadAnsiString;
        IncomingMessage:=True;
      end;
    $0B: //Chat Message
      begin
        if FGameState = GS_LOBBY then
        begin
          frmLobby.eMessages.Lines.Add(p.ReadAnsiString);
        end;
        if FGameState = GS_ROOM then
        begin
          frmGameLobby.eMessages.Lines.Add(p.ReadAnsiString);
        end;
      end;
    $0E: //Game Event
      begin
        case p.ReadByte of
          0: //Someone Got A Set
            begin
              GameInformation.Lock;
              SetLength(GameInformation.FSelected, 0);
              GameInformation.Unlock;
            end;
          1: //You Got A Set
            begin
              GameInformation.Lock;
              SetLength(GameInformation.FSelected, 0);
              GameInformation.Unlock;
            end;
          2: //You Won
            begin
              LobbyInformation.Lock;
              inc(FPlayer.wins);
              LobbyInformation.Unlock;
            end;
        end;
      end;
    $11: //Cheat
      begin
        p1:=p.ReadByte;
        p2:=p.ReadByte;
        p3:=p.ReadByte;
      end;
  end;
end;

function TSetClient.Player: TPlayer;
begin
  Result:=FPlayer;
end;

procedure TSetClient.SendPacket(s: String);
var
  Packet: TPacketStream;
  SplitData: TStringArray;
  i: Integer;
begin
  Randomize;
  Packet:=TPacketStream.Create;
  SplitData:=SplitW(Trim(s), ' ');
  for i:=0 to High(SplitData) do
  begin
    Randomize;
    if SplitData[i] = '**' then
      Packet.WriteByte(Random($FF))
    else
      Packet.WriteByte(HexToDec(SplitData[i]));
  end;
  SendPacket(Packet);
end;

procedure TSetClient.SendPacket(p: TPacketStream);
begin
  p.Position:=0;
  p.WriteShort(p.Size - 2);
  try
    FClient.IOHandler.Write(p);
  except
  end;
  p.Free;
end;

end.
