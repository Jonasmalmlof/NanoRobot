unit Queen;

interface

uses
  Graphics,     // TCanvas
  Types;        // TPoint

type TQueenState = (stCreated, stRunning, stDead);

type TQueen = class(TObject)
  private
    Pos   : TPoint;       // Position on the map
    Food  : integer;      // Amount of food in stomack
    State : TQueenState;
  public

    //-------------  constructors / destructors and such -----------------------

    constructor Create (rMap : TRect); overload; // Not used outside

    procedure   Act (Can : TCanvas);

    procedure   Draw (Can : TCanvas);
  end;

implementation

constructor TQueen.Create(rMap : TRect);
begin
  State := stCreated;

  Pos.X := rMap.Left + Random(rMap.Right - rMap.Left);
  Pos.Y := rMap.Top +  Random(rMap.Bottom - rMap.Top);

  Food := 10;
end;

procedure TQueen.Act;
begin
  // Behave like a queen

  // If food > 100 then give birth to a ant now and then

  // Draw itself

  if Self.State = stCreated then
    begin
      Self.Draw(Can);
      Self.State := stRunning;
    end;
end;

procedure TQueen.Draw;
var
  w : integer;
begin
  // If first time draw itself

  if (Self.State = stDead) then
    Can.Brush.Color := clBlack
  else
    Can.Brush.Color := clRed;

  Can.Brush.Style := bsSolid;
  Can.Pen.Color := clBlack;
  Can.Pen.Width := 1;

  // Calc how big the queen should be

  w := Self.Food Div 2;
  Can.Ellipse(pos.X - w, pos.Y - w, pos.X + w, pos.Y + w);
end;
end.
