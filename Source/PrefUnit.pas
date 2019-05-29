unit PrefUnit;

interface

uses
  SysUtils,     // IntToStr
  ComCtrls,     // TStatusBar
  Math,         // Min, Max
  Classes,      // TList
  Graphics,     // TCanvas
  Types,        // TPoint
  Forms,        // TApplication
  StdCtrls;     // TListBox

type TPref = class(TObject)
  public
    World   : TList;      // Pointer to the world
    Area    : TRect;      // The world Area
    Debug   : TListBox;   // Pointer to the Debug ListBox
    DebugOn : boolean;    // True if debugging is on
    Can     : TCanvas;

    Wind     : real;      // Amount of wind blowing
    ScentMax : integer;   // Max scent volume
  public

    //---  constructors / destructors and such ---------------------------------

    constructor Create
                  (pWorld : TList;    // TList with all objects
                   lDebug : TListBox; // Pointer to the Debug ListBox
                   bDebug : boolean;  // Debug
                   pCan   : TCanvas;
                   Wind   : real     // Amount of wind
                  ); Overload;


  end;
implementation

constructor TPref.Create(
                   pWorld : TList;    // TList with all objects
                   lDebug : TListBox; // Pointer to the Debug ListBox
                   bDebug : boolean;  // Debug
                   pCan   : TCanvas;
                   Wind   : real      // Amount of wind
                  );
begin
  inherited Create();

  Self.World   := pWorld;
  Self.Debug   := lDebug;
  Self.DebugOn := bDebug;
  Self.Can     := pCan;
  Self.Wind    := Wind;
end;

end.
