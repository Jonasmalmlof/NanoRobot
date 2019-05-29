unit FoodUnit;

interface

uses
  SysUtils,     // IntToStr
  ComCtrls,     // TStatusBar
  Math,         // Min, Max
  Classes,      // TList
  Graphics,     // TCanvas
  Types,        // TPoint
  Forms,        // TApplication
  StdCtrls,     // TListBox

  BaseUnit;     // Base object


type TFood = class(TObject)
  private
    Id      : integer;
    Pos     : TPoint;       // Position on the map
    State   : TBaseState;   // State of the object
    Food    : Real;         // Amount of food in stomack

    World   : TList;        // Pointer to the world
    Bitmap  : TBitmap;      // Loaded queen bitmap
    Debug   : TListBox;     // Debug listbox
    DebugOn : boolean;
  public

    //---  constructors / destructors and such ---------------------------------

    constructor Create
                  (pPos   : TPoint;   // Position in the world
                   pWorld : TList;    // The world to act in
                   pDebug : TListBox  // Debug
                  ); overload;

    //--- General procedures ---------------------------------------------------

    // Act in the world

    procedure   Act (bDebug : boolean);

    // Return status

    function    InqState: TBaseState;

    // Return your position

    function    InqPos : TPoint;

    // Return the food amount you have

    function    InqFood : real;

    // Feed an object some food , return how much you was feed

    function    Feed (pObj : TBaseObject) : real;

    // Get/loose food and  return how much you got/lost

    function    Eat  (fFood : real) : real;
    function    Rob  (fFood : real) : real;

    // Return info about this object

    function InqInfo : string;

    //--- Drawing routines -----------------------------------------------------

    procedure   Draw (Can : TCanvas);
  end;

implementation

var curId : integer = 1;

//------------------------------------------------------------------------------
// Constructor
//
constructor TFood.Create(pPos   : TPoint; pWorld : TList; pDebug : TListBox );
begin
  inherited Create;

  Self.State := stRunning;
  Self.Pos   := pPos;
  Self.Food  := 20;
  Self.World := pWorld;

  Self.Id := curId;
  curId := curId + 1;

  // Load the bitmap to draw

  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Food.bmp');
  Bitmap.Width  := 16;
  Bitmap.Height := 16;
  
  Self.Debug := pDebug;
  Self.Debug.Items.Add('Food Unit [' + IntToStr(Self.Id) + '] created')
end;
//------------------------------------------------------------------------------
// Return true if you are alive
//
function TFood.InqState: TBaseState;
begin
  InqState := Self.State;
end;
//------------------------------------------------------------------------------
// Return Information about the queen
//
function TFood.InqInfo : string;
begin
  InqInfo := 'F[' + IntToStr(Id) + '] F: ' + IntToStr(round(Food)) +
    ' P: ' + IntToStr(Pos.x) + ',' + IntToStr(Pos.Y);
end;
//------------------------------------------------------------------------------
// Return position
//
function TFood.InqPos: TPoint;
begin
  InqPos := Self.Pos;
end;
//------------------------------------------------------------------------------
// Return amount of food
//
function TFood.InqFood: real;
begin
  InqFood := Self.Food;
end;
//------------------------------------------------------------------------------
// Feed sombody some of your food
//
function TFood.Feed (pObj : TBaseObject): real ;
var
  fFood : real;
begin
  Feed :=0;
  if pObj <> nil then
    begin
      // Decide how much to give away (not more than you got)

      fFood := Min (5, Self.Food);

      // Tell the other object to eat it (return what he eat)

      fFood := pObj.Eat(fFood);
      Feed := fFood;
      // Decrease your own food

      Self.Food := Self.Food - fFood;
      if DebugOn then Self.Debug.Items.Add('Food ' + intToStr(round(Self.Food)) + ' left');
    end;
end;
//------------------------------------------------------------------------------
// Accept the food
//
function TFood.Eat (fFood : real): real;
begin

  // We are just hapy to get what we get

  Self.Food := Self.Food + fFood;
  Eat := fFood;
end;
//------------------------------------------------------------------------------
// Accept beeing robbed
//
function TFood.Rob (fFood : real) : real;
var
  fLost : real;
begin

  // We give all what we got if asked for

  fLost := Min (fFood, Self.Food);
  Self.Food := Self.Food - fLost;

  if DebugOn then Self.Debug.Items.Add('Food Unit [' + IntToStr(Self.Id) + '] eaten ' +
                        IntToStr(round(Self.Food)) + ' left');

  Rob := fLost;
end;
//------------------------------------------------------------------------------
// Act
//
procedure TFood.Act(bDebug : boolean);
begin
  Self.DebugOn := bDebug;

  // Handle the status

  if Self.Food < 0.5 then
    begin
      Self.State := stDead;
      if DebugOn then Self.Debug.Items.Add('Food Unit [' + IntToStr(Self.Id) + '] eaten up');
    end;
end;
//------------------------------------------------------------------------------
// Draw
//
procedure TFood.Draw(Can : TCanvas);
var
  wdt : integer;
  dr,sr : TRect;
begin

  // Calc how big the food should be

  wdt := round(Max(Self.Food, 6.0));

  // Draw the symbol in the middle (Bitmap is 16x16x256 color)

  dr.Left   := pos.X - wdt;
  dr.Right  := pos.X + wdt;
  dr.Top    := pos.Y - wdt;
  dr.Bottom := pos.Y + wdt;

  sr.Left   := 0;
  sr.Right  := 16;
  sr.Top    := 0;
  sr.Bottom := 16;

  Can.CopyRect(dr,Bitmap.Canvas,sr);end;
end.
