unit ScentUnit;

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
  ScentCreateValue    = 10;    // Initate value for new scent
  ScentDecreaseValue  = 0.009; // Decrease value for each lifecycle
  ScentIncreaseValue  = 1;     // How much to increase the scent by a robot
  ScentSnuffValue     = -20;   // How much to decrease when no food left
  ScentMaxVolume      = 20;    // Max volume a scent can have

  // Types of scent there is

type TScentType = (stFood,   // Scent containing food
                   stQueen); // Scent containing queen

type TScentTypeSet = Set of TScentType;

type TScent = class(TBaseObject)
  private
    Volume    : Real;          // The volume of the scent (also its radie)
    ScentType : TScentTypeSet; // Waht scent types the scent contains
    Happiness : integer;       // How happy the robot was that laid this scent
    FoodLeft  : integer;       // Food left when robot took a bite
    RobotId   : integer;       // Pointer to robot that laid the scent
  public

    //--- constructors / destructors and such ----------------------------------

    constructor Create
                  (rRobotId  : integer;    // Robot identifier
                   pPos      : TPoint;     // Position to place scent
                   tType     : TScentType; // The kind of scent it has
                   nFoodLeft : integer;    // Food left if food scent
                   hHappy    : integer;    // Robot happiness
                   pPref     : TPref       // Debug
                   ); overload;

    //--- Genreal Functions ----------------------------------------------------

    // Let the scent do it stuff

    procedure   Act(bDebug : boolean); override;

    // Return info about this object

    function InqInfo (w : string) : string; override;

    // Draw the scent

    procedure   Draw (); override;

    //---- Specific functions --------------------------------------------------

    // Return the volume of the scent (also its radie)

    function    InqVolume : real;

    // Add more volume to the scent

    procedure   IncVolume (aScent : real);

    // Return how happy the robot was that laid the scent

    function    InqHappiness : integer;

    // Set happiness of the scent if this is bigger

    procedure   SetHappiness (hHappy : integer);

    // Return type of scent contained

    function    InqScentType : TScentTypeSet;

    function    InqFoodLeft : integer;
    procedure   SetFoodLeft (fLeft : integer);

    // Return pointer to robot that laid scent

    function    InqRobotId  : integer;
  end;

implementation

//------------------------------------------------------------------------------
// Create a new scent
//
constructor TScent.Create
                  (rRobotId  : integer;    // Robot identifier
                   pPos      : TPoint;     // Position to place scent
                   tType     : TScentType; // The kind of scent it has
                   nFoodLeft : integer;    // Food left if food scent
                   hHappy    : integer;    // Robot happiness
                   pPref     : TPref       // Debug
                   );
begin
  Self.Name := 'S';

  Self.Create (pPos, pPref);

  Self.Volume    := ScentCreateValue;
  Self.ScentType := [tType];
  Self.FoodLeft  := nFoodLeft;
  Self.Happiness := hHappy;
  Self.RobotId   := rRobotId;
end;
//------------------------------------------------------------------------------
// Return Information about the queen
//
function TScent.InqInfo (w : string): string;
var
  s : string;
begin
  s := 'S[' + IntToStr(Id) + '] W:' + w +
    ' V: ' + IntToStr(round(Volume)) +
    ' P: ' + IntToStr(Pos.x) + ',' + IntToStr(Pos.Y) +
    ' H: ' + IntToStr(Happiness);

  if stFood in ScentType then
    s := s + ' S=F';
  if stQueen in ScentType then
    s := s + ' S=Q';

  InqInfo := s;
end;
//------------------------------------------------------------------------------
// Return volume of scent
//
function TScent.InqVolume: real;
begin
  InqVolume := Self.Volume;
end;
//------------------------------------------------------------------------------
// Increase volume of scent
//
procedure TScent.IncVolume (aScent : real);
begin

  // Dont increase over Max volume

  if (Self.Volume + aScent) > Pref.ScentMax then
    Self.Volume := Pref.ScentMax
  else
    Self.Volume := Self.Volume + aScent;

  // Dont let it go under 0 either

  if  Self.Volume < 0 then
    Self.Volume := 0;
end;
//------------------------------------------------------------------------------
// Return how happy the robot was that laid the scent
//
function TScent.InqHappiness: integer;
begin
  InqHappiness := Self.Happiness;
end;
//------------------------------------------------------------------------------
// Increase happiness of scent if bigger
//
procedure TScent.SetHappiness (hHappy : integer);
begin
  if hHappy > Self.Happiness then
    Self.Happiness := hHappy;
end;
//------------------------------------------------------------------------------
// Return Pointer to Robot that laid this scent
//
function TScent.InqRobotId : integer;
begin
  InqRobotId := Self.RobotId;
end;
//------------------------------------------------------------------------------
// Return true if the scent was dropped by a robot carrying ffod
//
function TScent.InqScentType : TScentTypeSet;
begin
  InqScentType := Self.ScentType;
end;
//------------------------------------------------------------------------------
// Return true if the scent was dropped by a robot carrying ffod
//
function TScent.InqFoodLeft: integer;
begin
  InqFoodLeft := Self.FoodLeft;
end;
//------------------------------------------------------------------------------
// Return true if the scent was dropped by a robot carrying ffod
//
procedure TScent.SetFoodLeft (fLeft : integer);
begin
  Self.FoodLeft := fLeft;
end;
//------------------------------------------------------------------------------
// Let the scent do it stuff
//
procedure TScent.Act;
begin
  // Behave like a scent, decrease volume until dead

  if Self.Volume < ScentDecreaseValue then
    Self.State := stDead
  else
    Self.Volume := Self.Volume - Pref.Wind;
end;
//------------------------------------------------------------------------------
// Draw the scent
//
procedure TScent.Draw();
var
  wdt : integer;
begin

  // Draw an empty ring

  Pref.Can.Brush.Style := bsClear;
  Pref.Can.Pen.Style   := psSolid;

  //--- Draw how big the scent is -----------------------------------

  // If a scent has food draw it green, otherwise light gray

  //if bVol then
  //  begin
      if stFood in Self.ScentType then
        begin
          if Self.FoodLeft > 0 then
            Pref.Can.Pen.Color := clLime
          else
            Pref.Can.Pen.Color := clGreen
        end
      else
        begin
          Pref.Can.Pen.Color := clLtGray;
        end;

      wdt := round(Max(Self.Volume , 3));
      Pref.Can.Ellipse(pos.X - wdt, pos.Y - wdt, pos.X + wdt, pos.Y + wdt);
  //end;

  {if bHapp then
    begin
      //--- Draw how big the Hapiness is ---------------------------------

      if Self.Happiness > 0 then
        begin
          Can.Pen.Color := clRed;
          wdt := Max(Self.Happiness Div 100,3);
          Can.Ellipse(pos.X - wdt, pos.Y - wdt, pos.X + wdt, pos.Y + wdt);
        end;
    end  }
end;
end.
