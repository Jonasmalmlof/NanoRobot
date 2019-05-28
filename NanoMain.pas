unit NanoMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ActnList, ExtCtrls, ComCtrls, ToolWin, ImgList, StdCtrls,

  PrefUnit,
  BaseUnit,
  FoodUnit,
  RobotUnit,
  QueenUnit,
  ScentUnit;

type
  TMainForm = class(TForm)
    ActionList: TActionList;
    MainMenu1: TMainMenu;
    ActionExit: TAction;
    ActionRun: TAction;
    ActionFood: TAction;
    ActionQueen: TAction;
    File1: TMenuItem;
    MenuExit: TMenuItem;
    ools1: TMenuItem;
    MenuAddQueen: TMenuItem;
    MenuAddFood: TMenuItem;
    Help1: TMenuItem;
    MenuAbout: TMenuItem;
    MenuRun: TMenuItem;
    ActionAbout: TAction;
    RunTimer: TTimer;
    ActionAccelerate: TAction;
    Accelerate1: TMenuItem;
    StatusBar: TStatusBar;
    ActionTrace: TAction;
    race1: TMenuItem;
    ToolBar: TToolBar;
    ToolButton1: TToolButton;
    ImageList: TImageList;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ActionDrawQueenScent: TAction;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ActionDrawFoodScent: TAction;
    ActionDebugQueen: TAction;
    ActionDebugFood: TAction;
    ActionDebugRobot: TAction;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ActionGetObjInfo: TAction;
    ToolButton14: TToolButton;
    Splitter: TSplitter;
    LeftPanel: TPanel;
    DebugList: TListBox;
    DebugPanel: TPanel;
    Label1: TLabel;
    WindBar: TTrackBar;
    WindLabel: TLabel;
    Label2: TLabel;
    ScentMax: TTrackBar;
    ScentMaxLabel: TLabel;
    procedure ActionExitExecute(Sender: TObject);
    procedure ActionRunExecute(Sender: TObject);
    procedure ActionFoodExecute(Sender: TObject);
    procedure ActionQueenExecute(Sender: TObject);
    procedure ActionAboutExecute(Sender: TObject);
    procedure RunTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ActionAccelerateExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ActionTraceExecute(Sender: TObject);
    procedure ActionDrawQueenScentExecute(Sender: TObject);
    procedure ActionDrawFoodScentExecute(Sender: TObject);
    procedure ActionDebugQueenExecute(Sender: TObject);
    procedure ActionDebugFoodExecute(Sender: TObject);
    procedure ActionDebugRobotExecute(Sender: TObject);
    procedure ActionGetObjInfoExecute(Sender: TObject);
    procedure SplitterMoved(Sender: TObject);
    procedure SplitterCanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure FormClick(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure WindBarChange(Sender: TObject);
    procedure ScentMaxChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function InqDist (p1,p2 : TPoint) : real;
var
  MainForm: TMainForm;

  WorldObjects : TList;
  TraceOn      : boolean = false;
  CurPos       : TPoint;
  Pref         : TPref;

implementation

{$R *.dfm}
//------------------------------------------------------------------------------
// Create the form and initialize all things
//
procedure TMainForm.FormCreate(Sender: TObject);
begin
  Randomize;
  WorldObjects        := TList.Create;
  RunTimer.Enabled    := true;
  ActionRun.Checked   := RunTimer.Enabled;
  ActionTrace.Checked := TraceOn;

  // Create Preference object and set its data

  Pref := TPref.Create(WorldObjects, DebugList,
      false, Self.Canvas, ScentDecreaseValue);

  Pref.ScentMax := ScentMaxVolume;

  // Update the debug window with preference data

  WindBar.Position := round(Pref.Wind * (WindBar.Max - WindBar.Min));
  WindLabel.Caption := FloatToStr( round(Pref.Wind*1000)/1000 );

  ScentMax.Position := Pref.ScentMax;
  ScentMaxLabel.Caption := IntToStr(Pref.ScentMax);
end;
//------------------------------------------------------------------------------
// Keep track of mouse in form
//
procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  CurPos.X := X;
  CurPos.Y := Y;

  if ActionGetObjInfo.Checked then
    FormClick(nil);
end;
//------------------------------------------------------------------------------
// Get the object nearest
//
procedure TMainForm.FormClick(Sender: TObject);
var
  i : integer;
  ThisPos    : TPoint;
  ThisObj    : TBaseObject;
  NearestPos : TPoint;
  NearestObj : TBaseObject;
  ThisDist   : real;
  NearestDist: real;
begin

  NearestObj := nil;
  NearestDist := 999999;
  for i := 0 to Pref.World.Count - 1do
    begin
      ThisObj := Pref.World.Items[i];
      if ThisObj <> nil then
        begin

          ThisPos := ThisObj.InqPos();

          ThisDist := InqDist(ThisPos, CurPos);
          if (ThisDist < 20) then
            begin
              if (NearestObj = nil) then
                begin
                  NearestObj  := ThisObj;
                  NearestPos  := ThisPos;
                  NearestDist := ThisDist;
                end
              else if (ThisDist < NearestDist) then
                begin
                  NearestObj  := ThisObj;
                  NearestPos  := ThisPos;
                  NearestDist := ThisDist;
                end
            end
        end
    end;

  // Get infor from the nearest object

  if NearestObj <> nil then
    StatusBar.Panels[0].Text := NearestObj.InqInfo('N');
end;
//------------------------------------------------------------------------------
// Handle resizing the world
//
procedure TMainForm.FormResize(Sender: TObject);
var
  i : integer;
  r : TRect;
begin

  // Calaculate the panels in StatusBar

  i := Self.ClientWidth Div 10;
  StatusBar.Panels[0].Width := i*4;
  StatusBar.Panels[1].Width := i*2;
  StatusBar.Panels[2].Width := i*2;
  StatusBar.Panels[3].Width := i*2;

  // Calculate the Debug listbox

  Pref.Debug.Height := LeftPanel.Height - DebugPanel.Height;

  // Calculate the right drawing area and draw it fresh

  r.Left   := LeftPanel.Width + Splitter.Width;
  r.Right  := Self.ClientWidth;
  r.Top    := ToolBar.Height;
  r.Bottom := Self.ClientHeight - StatusBar.Height;

  Pref.Can.Brush.Color := clBtnFace;
  Pref.Can.Brush.Style := bsSolid;
  Pref.Can.Pen.Style := psClear;
  Pref.Can.Rectangle(r);

  Pref.Area.Left   := LeftPanel.Width + Splitter.Width + 1;
  Pref.Area.Right  := Self.ClientWidth -  2;
  Pref.Area.Top    := ToolBar.Height + 1;
  Pref.Area.Bottom := Self.ClientHeight - StatusBar.Height - 2;

  // Redraw the world if not running already

  if not RunTimer.Enabled then
    RunTimerTimer(nil);
end;
procedure TMainForm.SplitterMoved(Sender: TObject);
begin
  FormResize(nil)
end;
procedure TMainForm.SplitterCanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
begin
  Accept := (NewSize < Self.ClientWidth Div 2);
end;
//------------------------------------------------------------------------------
// Action Exit
//
procedure TMainForm.ActionExitExecute(Sender: TObject);
begin
  Self.Close;
end;
//------------------------------------------------------------------------------
// Stop and Start running the world
//
procedure TMainForm.ActionRunExecute(Sender: TObject);
begin
  RunTimer.Enabled := not RunTimer.Enabled;
  ActionRun.Checked := RunTimer.Enabled;
end;
//------------------------------------------------------------------------------
// Place a food object randomly
//
procedure TMainForm.ActionFoodExecute(Sender: TObject);
var
  p : TPoint;
  r : TRect;
begin
  // Add new Food Object

  r.Left   := Pref.Area.Left   + 20;
  r.Right  := Pref.Area.Right  - 20;
  r.Top    := Pref.Area.Top    + 20;
  r.Bottom := Pref.Area.Bottom - 20;

  p.X := r.Left + Random(r.Right - r.Left);
  p.Y := r.Top +  Random(r.Bottom - r.Top);

  Pref.World.Add(TFood.Create(p, Pref));
end;
//------------------------------------------------------------------------------
// Place a new food object with mouse
//
procedure TMainForm.FormDblClick(Sender: TObject);
begin

  // Add new Food Object

  Pref.World.Add(TFood.Create(CurPos, Pref));
end;
//------------------------------------------------------------------------------
// Place a queen object randomly
//
procedure TMainForm.ActionQueenExecute(Sender: TObject);
var
  p : TPoint;
  r : TRect;
begin
  // Add new Food Object

  r.Left   := Pref.Area.Left   + 20;
  r.Right  := Pref.Area.Right  - 20;
  r.Top    := Pref.Area.Top    + 20;
  r.Bottom := Pref.Area.Bottom - 20;

  p.X := r.Left + Random(r.Right - r.Left);
  p.Y := r.Top +  Random(r.Bottom - r.Top);

  Pref.World.Add(TQueen.Create(p, Pref));
end;
//------------------------------------------------------------------------------
// Open the about dialog
//
procedure TMainForm.ActionAboutExecute(Sender: TObject);
begin
  // Open the About Dialog
end;
//------------------------------------------------------------------------------
// Toggle the speed of the world
//
procedure TMainForm.ActionAccelerateExecute(Sender: TObject);
begin
  ActionAccelerate.Checked := not ActionAccelerate.Checked;
  if ActionAccelerate.Checked then
    RunTimer.Interval := 30
  else
    RunTimer.Interval := 500;
end;
//------------------------------------------------------------------------------
// Toggle redrawing background on/off
//
procedure TMainForm.ActionTraceExecute(Sender: TObject);
begin
  TraceOn := not TraceOn;
  ActionTrace.Checked := TraceOn;
end;
//------------------------------------------------------------------------------
// The main world action loop
//
procedure TMainForm.RunTimerTimer(Sender: TObject);
var
  i : integer;
  t : TBaseObject;
  q, f, r, s: integer;
  a : boolean;
begin

  q := 0;
  f := 0;
  r := 0;
  s := 0;

  //--- Tell each object to do their thing -------------------------------------

  a := RunTimer.Enabled;
  for i := Pref.World.Count - 1 downto 0 do
    begin
      t := Pref.World.Items[i];
      if t <> nil then
        begin

          if t.InqState = stDead then
            begin
              Pref.World.Delete(i);
              t.Free;
            end
          else if (t is TQueen) then
            begin
              if a then TQueen(t).Act(ActionDebugQueen.Checked);
              q := q + 1;
            end
          else if (t is TFood) then
            begin
              if a then TFood(t).Act(ActionDebugFood.Checked);
              f := f + 1;
            end
          else if (t is TRobot) then
            begin
              if a then TRobot(t).Act(ActionDebugRobot.Checked);
              r := r + 1;
            end
          else if (t is TScent) then
            begin
              if a then TScent(t).Act(ActionDrawFoodScent.Checked or
                                      ActionDrawQueenScent.Checked);
              s := s + 1;
            end
        end;
    end;

  //--- Draw all objects -------------------------------------------------------

  // Refresh the window

  if not TraceOn then
    begin
      // First draw all client area white

      Pref.Can.Brush.Style := bsSolid;
      Pref.Can.Pen.Color := clBlack;
      Pref.Can.Pen.Style := psSolid;
      Pref.Can.Pen.Width := 1;
      Pref.Can.Brush.Color := clWhite;
      Pref.Can.Rectangle(Pref.Area);
    end;

  // Draw all objects (The queen last)

  for i := 0 to Pref.World.Count - 1 do
    begin
      t := Pref.World.Items[i];
      if t <> nil then
        if (t is TScent) then
          begin
            if ActionDrawQueenScent.Checked and
              (stQueen in TScent(t).InqScentType) then
              t.Draw()
            else 
            if ActionDrawFoodScent.Checked and
              (stFood in TScent(t).InqScentType) then
              t.Draw();
          end
        else
          t.Draw();
    end;

  // Give feedbak to the user

  StatusBar.Panels[1].Text := 'Queens: '   + IntToStr(q);
  StatusBar.Panels[2].Text := 'Food: '     + IntToStr(f);
  StatusBar.Panels[3].Text := 'BabyAnts: ' + IntToStr(r) +
                              ' Scents: '  + IntToStr(s) ;
end;

procedure TMainForm.ActionDrawQueenScentExecute(Sender: TObject);
begin
  ActionDrawQueenScent.Checked := not ActionDrawQueenScent.Checked;
end;

procedure TMainForm.ActionDrawFoodScentExecute(Sender: TObject);
begin
  ActionDrawFoodScent.Checked := not ActionDrawFoodScent.Checked;
end;

procedure TMainForm.ActionDebugQueenExecute(Sender: TObject);
begin
  ActionDebugQueen.Checked := not ActionDebugQueen.Checked;
end;

procedure TMainForm.ActionDebugFoodExecute(Sender: TObject);
begin
  ActionDebugFood.Checked := not ActionDebugFood.Checked;
end;

procedure TMainForm.ActionDebugRobotExecute(Sender: TObject);
begin
  ActionDebugRobot.Checked := not ActionDebugRobot.Checked;
end;

procedure TMainForm.ActionGetObjInfoExecute(Sender: TObject);
begin
  ActionGetObjInfo.Checked := not ActionGetObjInfo.Checked;
end;

//------------------------------------------------------------------------------
// find distance between two points
//
function InqDist (p1,p2 : TPoint) : real;
begin
  InqDist := ABS(SQRT(ABS(abs(SQR(p2.X - p1.X)) + abs(SQR(p2.Y - p1.Y)))));
end;

procedure TMainForm.WindBarChange(Sender: TObject);
begin
  Pref.Wind := (1 / (WindBar.Max - WindBar.Position + WindBar.Min));
  WindLabel.Caption := FloatToStr( round(Pref.Wind*1000)/1000 );
end;

procedure TMainForm.ScentMaxChange(Sender: TObject);
begin
  Pref.ScentMax := ScentMax.Position;
  ScentMaxLabel.Caption := IntToStr(Pref.ScentMax);
end;

end.
