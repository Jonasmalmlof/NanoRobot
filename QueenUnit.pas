unit QueenUnit;

interface

uses
  Math,         // Min, Max
  ComCtrls,     // TStatusBar
  Classes,      // TList
  Graphics,     // TCanvas
  Types,        // TPoint
  Forms,        // TApplication
  SysUtils,     // ExtractFilePath
  StdCtrls,     // TListBox

  PrefUnit,
  BaseUnit;     // Base object

const
  QueenStartFood   = 200;     // How much the queen gets from her queen
  QueenBirthTime   = 200;    // How long until next birth
  QueenBirthFood   = 0.5;    // Amount of food it consumes to give birth
  QueenHibernate   = 8;      // How much food there has to be for giving birth
  QueenConsumption = 0.0001; // How much the quuen consumes her self
  QueenDeadValue   = 1;      // When the queen dies


type TQueen = class(TBaseObject)
  private
    BirthTime  : integer;      // Last time the queen gave birth
    Bitmap     : TBitmap;      // Loaded queen bitmap
  public

    //---  constructors / destructors and such ---------------------------------

    constructor Create (pPos : TPoint; pPref  : TPref ); override;

    // Let the queen act

    procedure   Act(bDebug : boolean); override;

    // Eat some of the food you get feed, return how much you ate

    function    Eat (fFood : real) : real; override;

    // Draw the queen

    procedure   Draw (); override;
  end;

implementation

uses
  RobotUnit;

//------------------------------------------------------------------------------
// Create a queen
//
constructor TQueen.Create(pPos : TPoint; pPref  : TPref );// Debug listbox
begin
  Self.Name := 'Q';

  inherited;

  // Initate how much food there is

  Self.Food := QueenStartFood;

  // Start the birth timer

  Self.BirthTime := Random(QueenBirthTime);

  // Load the bitmap to draw

  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Queen.bmp');

  Pref.Debug.Items.Add(InqInfo('Created'))
end;
//------------------------------------------------------------------------------
// Create a queen
//
function TQueen.Eat (fFood : real): real;
begin
  Self.Food := Self.Food + (fFood / 2);

  // Tell about it

  if DebugOn then
    Pref.Debug.Items.Add(InqInfo('Eat'));

  Eat := fFood;
end;
//------------------------------------------------------------------------------
// Lett the queen do her things
//
procedure TQueen.Act(bDebug : boolean);
var
  p : TPoint;
  f : integer;
begin
  inherited;

  // First test if we are actualle dead a little bit

  if Self.Food < QueenDeadValue then
    begin
      Self.State := stDead;
      Pref.Debug.Items.Add(InqInfo('Died'));
      exit;
    end;

  // Decrease the food a nibble, the queen eats too

  Self.Food := Self.Food - QueenConsumption;

  // If we got food then give birth to an ant now and then

  if Self.Food < QueenHibernate then
    begin
      if Self.State <> stHibernate then
        Pref.Debug.Items.Add(InqInfo('Hibernating'));
      Self.State := stHibernate;
    end
  else
    begin
      if Self.State = stHibernate then
        Pref.Debug.Items.Add(InqInfo('Alive'));
      Self.State := stRunning;
    end;

  if Self.State = stRunning then
    begin
      if Self.BirthTime < 0 then
        begin
          f := InqRad();

          // Give birth to a new baby (somewhere inside you)

          p.X := Self.Pos.X + Random(f) - (f Div 2);
          p.Y := Self.Pos.Y + Random(f) - (f Div 2);

          // Create the new robot and add give it to the world

          Pref.World.Add (TRobot.Create(p, Pref));

          // It costs some food

          Self.Food := Self.Food - QueenBirthFood;

          // Set the timer for next birth

          Self.BirthTime := Random(QueenBirthTime);
          if DebugOn then Pref.Debug.Items.Add(InqInfo('Gave Birth'))
        end;
      Self.BirthTime := Self.BirthTime - 1;
    end;
end;
//------------------------------------------------------------------------------
// Draw the queen
//
procedure TQueen.Draw();
var
  wdt : integer;
  dr,sr : TRect;
begin

  // Calc how big the queen should be

  wdt := Max(8,InqRad());

  // Draw the symbol in the middle (Bitmap is 16x16x256 color)

  dr.Left   := pos.X - wdt;
  dr.Right  := pos.X + wdt;
  dr.Top    := pos.Y - wdt;
  dr.Bottom := pos.Y + wdt;

  sr.Left   := 0;
  sr.Right  := Bitmap.Width;
  sr.Top    := 0;
  sr.Bottom := Bitmap.Height;

  Pref.Can.CopyRect(dr,Bitmap.Canvas,sr);
end;
end.
