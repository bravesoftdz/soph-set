unit DataCollection;

interface

uses Windows, Sysutils, Classes, SyncObjs;

type
  TPlayerInformation = record
    uid: Integer;
    username: String;
    wins: Integer;
    score: Integer;
  end;

  TLobbyGameInformation = record
    owneruid: Integer;
    ownername: String;
    name: String;
    count: Integer;
  end;

  TLobbyInformation = class
  private
    FLock: TCriticalSection;
  public
    FRoomName: String;
    FOwnerID: Integer;
    FPlayers: array of TPlayerInformation;
    FGames: array of TLobbyGameInformation;

    constructor Create;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;

    function GetPlayerFromUID(uid: Integer): TPlayerInformation;
  end;

  TGameInformation = class
  private
    FLock: TCriticalSection;
  public
    FRoomName: String;
    FOwnerID: Integer;
    FPlayers: array of TPlayerInformation;
    FCards: array of Byte;
    FSelected: array of Byte;

    constructor Create;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;

    procedure SelectCard(id: Integer);
  end;

var
  LobbyInformation: TLobbyInformation;
  GameInformation: TGameInformation;

implementation

constructor TLobbyInformation.Create;
begin
  FLock:=TCriticalSection.Create;
end;

destructor TLobbyInformation.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TLobbyInformation.GetPlayerFromUID(uid: Integer): TPlayerInformation;
var
  i: Integer;
begin
  for i:=0 to High(FPlayers) do
    if FPlayers[i].uid = uid then
      Result:=FPlayers[i];
end;

procedure TLobbyInformation.Lock;
begin
  FLock.Enter;
end;

procedure TLobbyInformation.Unlock;
begin
  FLock.Leave;
end;

constructor TGameInformation.Create;
begin
  FLock:=TCriticalSection.Create;
end;

destructor TGameInformation.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TGameInformation.Lock;
begin
  FLock.Enter;
end;

procedure TGameInformation.SelectCard(id: Integer);
begin

end;

procedure TGameInformation.Unlock;
begin
  FLock.Leave;
end;

end.
