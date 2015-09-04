unit PacketFactory;

interface

uses
  Windows, Sysutils, Classes, PacketStream;

type
  TPacketFactory = class
  public
    class function LoginPacket(szUsername, szPassword: String): TPacketStream;
    class function RegisterPacket(szUsername, szPassword: String): TPacketStream;
    class function Pong: TPacketStream;
    class function CreateGame(szGameName: String): TPacketStream;
    class function Chat(szChat: String): TPacketStream;
    class function JoinGame(owneruid: Integer): TPacketStream;
    class function KickPlayer(uid: Integer): TPacketStream;
    class function StartGame: TPacketStream;
    class function LeaveGame: TPacketStream;
    class function SendSet(c1, c2, c3: Byte): TPacketStream;
    class function Cheat: TPacketStream;
  end;

implementation

class function TPacketFactory.LoginPacket(szUsername, szPassword: String): TPacketStream;
begin
  Result:=TPacketStream.Create;
  Result.WriteShort($00);
  Result.WriteByte($00);
  Result.WriteAnsiString(szUsername);
  Result.WriteAnsiString(szPassword);
end;

class function TPacketFactory.Pong: TPacketStream;
begin
  Result:=TPacketStream.Create;
  Result.WriteShort($03);
  Result.WriteInt(GetTickCount);
end;

class function TPacketFactory.RegisterPacket(szUsername, szPassword: String): TPacketStream;
begin
  Result:=TPacketStream.Create;
  Result.WriteShort($00);
  Result.WriteByte($01);
  Result.WriteAnsiString(szUsername);
  Result.WriteAnsiString(szPassword);
end;

class function TPacketFactory.Cheat: TPacketStream;
begin
  Result:=TPacketStream.Create;
  Result.WriteShort($10);
  Result.WriteInt($2F564FFF);
end;

class function TPacketFactory.CreateGame(szGameName: String): TPacketStream;
begin
  Result:=TPacketStream.Create;
  Result.WriteShort($08);
  Result.WriteAnsiString(szGameName);
end;

class function TPacketFactory.Chat(szChat: String): TPacketStream;
begin
  Result:=TPacketStream.Create;
  Result.WriteShort($0A);
  Result.WriteAnsiString(szChat);
end;

class function TPacketFactory.JoinGame(owneruid: Integer): TPacketStream;
begin
  Result:=TPacketStream.Create;
  Result.WriteShort($0C);
  Result.WriteInt(owneruid);
end;

class function TPacketFactory.KickPlayer(uid: Integer): TPacketStream;
begin
  Result:=TPacketStream.Create;
  Result.WriteShort($0D);
  Result.WriteByte(0);
  Result.WriteInt(uid);
end;

class function TPacketFactory.SendSet(c1, c2, c3: Byte): TPacketStream;
begin
  Result:=TPacketStream.Create;
  Result.WriteShort($0F);
  Result.WriteByte(c1);
  Result.WriteByte(c2);
  Result.WriteByte(c3);
end;

class function TPacketFactory.StartGame: TPacketStream;
begin
  Result:=TPacketStream.Create;
  Result.WriteShort($0D);
  Result.WriteByte(1);
end;

class function TPacketFactory.LeaveGame: TPacketStream;
begin
  Result:=TPacketStream.Create;
  Result.WriteShort($0D);
  Result.WriteByte(2);
end;

end.
