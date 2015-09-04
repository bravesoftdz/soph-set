unit PacketStream;

interface

uses Classes, SysUtils, Types, GeneralFunctions;

type
  TPacketStream = class(TMemoryStream)
  public
    function ReadByte: Byte;
    function ReadShort: Smallint;
    function ReadInt: Integer;
    function ReadInt64: Int64;
    function ReadAnsiString(Length: Integer): string; overload;
    function ReadAnsiString: string; overload;
    function ReadNullTerminatedString(Length: Integer): string;
    function ReadPos: TPoint;

    procedure Skip(const Count: Int64);
    function SeekInt(i: Integer): Boolean;
    function SeekHex(s: String): Boolean;

    function ToString: string; override;
    function ToStringFromCurPos: string;

    procedure WriteByte(b: Byte);
    procedure WriteBool(b: Boolean);
    procedure WriteShort(s: Smallint);
    procedure WriteInt(i: Integer);
    procedure WriteAnsiString(const s: string);
    procedure WriteInt64(i: Int64);
    procedure WritePos(const Pos: TPoint);
    procedure WriteHex(s: string);

    constructor Create;
  end;

implementation

function TPacketStream.ReadByte: Byte;
begin
  Read(Result, 1);
end;

function TPacketStream.ReadShort: Smallint;
begin
  Read(Result, 2);
end;

function TPacketStream.ReadInt: Integer;
begin
  Read(Result, 4);
end;

function TPacketStream.ReadInt64: Int64;
begin
  Read(Result, 8);
end;

function TPacketStream.ReadAnsiString(Length: Integer): string;
var
  a: AnsiString;
  s: String;
begin
  SetLength(a, Length);
  Read(a[1], Length);
  s:=string(a);
  Result:=Copy(s, 1, StrLen(PChar(s)));
end;

constructor TPacketStream.Create;
begin
  inherited Create;
  WriteShort(0);
end;

function TPacketStream.ReadAnsiString: string;
begin
  Result:=ReadAnsiString(ReadShort);
end;

function TPacketStream.ReadNullTerminatedString(Length: Integer): string;
var
  b: Byte;
begin
  Result:='';
  b:=ReadByte;
  repeat
    Result:=Result + Chr(b);
    b:=ReadByte;
  until (b = 0) or (System.Length(Result) = Length);
  Skip(Length - (System.Length(Result) + 1));
end;

function TPacketStream.ReadPos: TPoint;
begin
  Result.X:=ReadShort;
  Result.Y:=ReadShort;
end;

function TPacketStream.SeekHex(s: String): Boolean;
var
  a: TStringArray;
  i, j: Integer;
  bMatch: Boolean;
begin
  Result:=False;
  a:=SplitW(s, ' ');
  if Size < High(a) + 1 then
    Exit;
  for i:=Position to Size - High(a) - 1 do
  begin
    bMatch:=True;
    for j:=0 to High(a) do
    begin
      if (a[j] = '??') or (a[j] = '?') then
        Continue;
      if UpperCase(a[j]) = 'XX' then
      begin
        if pByte(Dword(Memory) + Dword(i + j))^ = 0 then
          bMatch:=False
        else
          Continue;
      end;
      if pByte(Dword(Memory) + Dword(i + j))^ <> HexToDec(a[j]) then
        bMatch:=False;
    end;
    if bMatch then
    begin
      Position:=i;
      Result:=True;
      Break;
    end;
  end;
end;

function TPacketStream.SeekInt(i: Integer): Boolean;
begin
  Result:=False;
  while Position <= Size - 4 do
  begin
    if ReadInt = i then
    begin
      Skip(-4);
      Result:=True;
      Break;
    end;
    Skip(-3);
  end;
end;

procedure TPacketStream.Skip(const Count: Int64);
begin
  Seek(Count, soCurrent);
end;

function TPacketStream.ToString: string;
var
  OldPos: Integer;
begin
  OldPos:=Position;
  Position:=0;
  Result:=ToStringFromCurPos;
  Position:=OldPos;
end;

function TPacketStream.ToStringFromCurPos: string;
var
  OldPos: Integer;
  Data: TBytes;
  b: Byte;
begin
  if Size = 0 then
    Exit('<empty>');

  OldPos:=Position;

  Result:='';
  SetLength(Data, Size - Position);
  Read(Data[0], Size - Position);
  for b in Data do
    Result:=Result + Format('%.2x ', [b]);
  Data:=nil;

  Position:=OldPos;
end;

procedure TPacketStream.WriteByte(b: Byte);
begin
  Write(b, 1);
end;

procedure TPacketStream.WriteBool(b: Boolean);
begin
  if not b then
    WriteByte(0)
  else
    WriteByte(1);
end;

procedure TPacketStream.WriteShort(s: Smallint);
begin
  Write(s, 2);
end;

procedure TPacketStream.WriteInt(i: Integer);
begin
  Write(i, 4);
end;

procedure TPacketStream.WriteInt64(i: Int64);
begin
  Write(i, 8);
end;

procedure TPacketStream.WriteAnsiString(const s: string);
var
  a: AnsiString;
begin
  WriteShort(Length(s));
  a:=AnsiString(s);
  Write(a[1], Length(a));
end;

procedure TPacketStream.WritePos(const Pos: TPoint);
begin
  WriteShort(Pos.X);
  WriteShort(Pos.Y);
end;

procedure TPacketStream.WriteHex(s: string);
var
  i: Integer;
  b: Byte;
begin
  s:=StringReplace(s, ' ', '', [rfReplaceAll]);
  if Odd(Length(s)) then
    raise EArgumentException.Create('Length of hex-string is odd');

  for i:=1 to Length(s) div 2 do
  begin
    b:=StrToInt('$' + s[i * 2 - 1] + s[i * 2]);
    Write(b, 1);
  end;
end;

end.
