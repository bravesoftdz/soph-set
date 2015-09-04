unit GameForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Game, ExtCtrls, StdCtrls, DataCollection, Client, PacketFactory;

type
  TfrmGame = class(TForm)
    GameTimer: TTimer;
    lbPlayers: TListBox;
    btnCheat: TButton;
    CheatOff: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure GameTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnCheatClick(Sender: TObject);
    procedure CheatOffTimer(Sender: TObject);
  private
    {Private declarations}
  public
    {Public declarations}
  end;

var
  frmGame: TfrmGame;

implementation

{$R *.dfm}

var
  Game: TGame;
  PlayerUpdateTimer: Dword;

procedure TfrmGame.btnCheatClick(Sender: TObject);
begin
  c.SendPacket(TPacketFactory.Cheat);
end;

procedure TfrmGame.CheatOffTimer(Sender: TObject);
begin
  p1:=0;
  p2:=0;
  p3:=0;
  CheatOff.Enabled:=False;
end;

procedure TfrmGame.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ExitProcess(0);
end;

procedure TfrmGame.FormCreate(Sender: TObject);
begin
  Game:=TGame.Create(Handle);
  PlayerUpdateTimer:=0;
end;

procedure TfrmGame.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  i, j: Integer;
begin
  if (X > 520) or (Y > 280) then
  begin
    Game.HoverI:=-1;
    Game.HoverJ:=-1;
    Exit;
  end;
  i:=(X - 2) div 104;
  j:=(Y - 2) div 70;
  if j * 5 + i <= High(GameInformation.FCards) then
  begin
    Game.HoverI:=i;
    Game.HoverJ:=j;
  end
  else
  begin
    Game.HoverI:=-1;
    Game.HoverJ:=-1;
  end;
end;

procedure TfrmGame.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, j, cmb: Integer;
begin
  if Button = mbLeft then
  begin
    if (X > 520) or (Y > 280) then
      Exit;
    GameInformation.Lock;

    i:=(X - 2) div 104;
    j:=(Y - 2) div 70;
    cmb:=j * 5 + i;

    for i:=0 to High(GameInformation.FSelected) do
    begin
      if GameInformation.FSelected[i] = cmb then
      begin
        GameInformation.Unlock;
        Exit;
      end;
    end;

    if cmb <= High(GameInformation.FCards) then
    begin
      SetLength(GameInformation.FSelected, High(GameInformation.FSelected) + 2);
      GameInformation.FSelected[ High(GameInformation.FSelected)]:=cmb;
    end;

    if High(GameInformation.FSelected) = 2 then
    begin
      c.SendPacket(TPacketFactory.SendSet(GameInformation.FSelected[0], GameInformation.FSelected[1], GameInformation.FSelected[2]));
      SetLength(GameInformation.FSelected, 0);
    end;
    GameInformation.Unlock;
  end;
  if Button = mbRight then
  begin
    GameInformation.Lock;
    SetLength(GameInformation.FSelected, 0);
    GameInformation.Unlock;
  end;
end;

procedure TfrmGame.GameTimerTimer(Sender: TObject);
var
  i, selindex: Integer;
begin
  if not Visible then
    Exit;
  Game.DrawGameBoard(Canvas);
  if GetTickCount > PlayerUpdateTimer + 600 then
  begin
    {* Update Players *}
    selindex:=lbPlayers.ItemIndex;
    lbPlayers.Clear;
    GameInformation.Lock;
    for i:=0 to High(GameInformation.FPlayers) do
      lbPlayers.AddItem(GameInformation.FPlayers[i].username + ' - ' + IntToStr(GameInformation.FPlayers[i].score) + ' Points', nil);
    GameInformation.Unlock;
    if selindex < lbPlayers.Items.Count then
      lbPlayers.ItemIndex:=selindex;
    PlayerUpdateTimer:=GetTickCount;
  end;
  if not ((p1 = 0) and (p2 = 0) and (p3 = 0)) then
    CheatOff.Enabled:=True;
end;

end.
