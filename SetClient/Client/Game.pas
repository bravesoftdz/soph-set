unit Game;

interface

uses Windows, Sysutils, Classes, Graphics, DataCollection, Client;

type
  TGame = class
  private
    Gfx: TBitmap;
    Bitmap: TBitmap;

    function GetCard(id: Byte): TRect;
  public
    HoverI, HoverJ: Integer;

    constructor Create(FormHandle: THandle);

    procedure DrawGameBoard(Dest: TCanvas);
  end;

implementation

{$R Database.RES}

constructor TGame.Create(FormHandle: THandle);
var
  rs: TResourceStream;
begin
  Gfx:=TBitmap.Create;
  rs:=TResourceStream.Create(hInstance, 'CARDS', RT_RCDATA);
  Gfx.LoadFromStream(rs);
  rs.Free;
  Bitmap:=TBitmap.Create;
end;

procedure TGame.DrawGameBoard(Dest: TCanvas);
var
  i, t, l: Integer;
begin
  Bitmap.Canvas.Pen.Color:=clWhite;
  Bitmap.Canvas.Brush.Color:=clWhite;
  Bitmap.Width:=520;
  Bitmap.Height:=280;
  Bitmap.Canvas.FillRect(Rect(0, 0, 520, 280));
  //Selected
  GameInformation.Lock;
  Bitmap.Canvas.Pen.Color:=clGreen;
  Bitmap.Canvas.Brush.Color:=clGreen;
  for i:=0 to High(GameInformation.FSelected) do
  begin
    t:=GameInformation.FSelected[i] div 5;
    l:=GameInformation.FSelected[i] mod 5;
    Bitmap.Canvas.FillRect(Rect(l * 104, t * 70, l * 104 + 104, t * 70 + 70));
  end;
  GameInformation.Unlock;
  //Hover
  Bitmap.Canvas.Pen.Color:=clYellow;
  Bitmap.Canvas.Brush.Color:=clYellow;
  if HoverI <> -1 then
    Bitmap.Canvas.FillRect(Rect(HoverI * 104, HoverJ * 70, HoverI * 104 + 104, HoverJ * 70 + 70));
  //Cheat
  if not ((p1 = 0) and (p2 = 0) and (p3 = 0)) then
  begin
    Bitmap.Canvas.Pen.Color:=clRed;
    Bitmap.Canvas.Brush.Color:=clRed;
    t:=p1 div 5;
    l:=p1 mod 5;
    Bitmap.Canvas.FillRect(Rect(l * 104, t * 70, l * 104 + 104, t * 70 + 70));
    t:=p2 div 5;
    l:=p2 mod 5;
    Bitmap.Canvas.FillRect(Rect(l * 104, t * 70, l * 104 + 104, t * 70 + 70));
    t:=p3 div 5;
    l:=p3 mod 5;
    Bitmap.Canvas.FillRect(Rect(l * 104, t * 70, l * 104 + 104, t * 70 + 70));
  end;
  //Cards
  GameInformation.Lock;
  for i:=0 to High(GameInformation.FCards) do
  begin
    l:=i mod 5;
    t:=i div 5;
    Bitmap.Canvas.CopyRect(Rect(l * 104 + 2, t * 70 + 2, l * 104 + 100, t * 70 + 66), Gfx.Canvas, GetCard(GameInformation.FCards[i]));
  end;
  GameInformation.Unlock;
  Dest.CopyRect(Rect(0, 0, 520, 280), Bitmap.Canvas, Rect(0, 0, 520, 280));
end;

function TGame.GetCard(id: Byte): TRect;
var
  i, j: Integer;
begin
  i:=id mod 9;
  j:=id div 9;
  Result:=Rect(i * 50, j * 33, i * 50 + 50, j * 33 + 33);
end;

end.
