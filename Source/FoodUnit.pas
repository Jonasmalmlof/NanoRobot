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

  PrefUnit,
  BaseUnit;     // Base object

const
  FoodStartFood = 400; // Amount of food to start with

type TFood = class(TBaseObject)
  private

    Bitmap  : TBitmap;      // Loaded queen bitmap
  public

    //---  constructors / destructors and such ---------------------------------

    constructor Create(pPos : TPoint; pPref  : TPref ); override;

    //--- General procedures ---------------------------------------------------

    // Act in the world

    procedure   Act (bDebug : boolean); override;

    //--- Drawing routines -----------------------------------------------------

    procedure   Draw (); override;
  end;

implementation

//------------------------------------------------------------------------------
// Constructor
//
constructor TFood.Create(pPos : TPoint; pPref  : TPref );
begin
  Self.Name := 'F';

  inherited;

  // Start with a bigger food load

  Self.Food  := FoodStartFood;

  // Load the bitmap to draw

  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Food.bmp');

  Pref.Debug.Items.Add(InqInfo('Created'));
end;
//------------------------------------------------------------------------------
// Act
//
procedure TFood.Act(bDebug : boolean);
begin
  inherited;

  // Handle the status

  if Self.Food < 0.5 then
    begin
      Self.State := stDead;

      if DebugOn then
        Pref.Debug.Items.Add(InqInfo('Eaten'));
    end;
end;
//------------------------------------------------------------------------------
// Draw
//
procedure TFood.Draw();
var
  wdt : integer;
  dr,sr : TRect;
begin

  // Calc how big the food should be

  wdt := Max(6,InqRad());

  // Draw the symbol in the middle (Bitmap is 16x16x256 color)

  dr.Left   := pos.X - wdt;
  dr.Right  := pos.X + wdt;
  dr.Top    := pos.Y - wdt;
  dr.Bottom := pos.Y + wdt;

  sr.Left   := 0;
  sr.Right  := Bitmap.Width;
  sr.Top    := 0;
  sr.Bottom := Bitmap.Height;

  Pref.Can.CopyRect(dr,Bitmap.Canvas,sr);end;
end.
