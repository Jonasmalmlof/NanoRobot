program NanoRobot;

uses
  Forms,
  NanoMain in 'NanoMain.pas' {MainForm},
  QueenUnit in 'QueenUnit.pas',
  FoodUnit in 'FoodUnit.pas',
  RobotUnit in 'RobotUnit.pas',
  ScentUnit in 'ScentUnit.pas',
  BaseUnit in 'BaseUnit.pas',
  PrefUnit in 'PrefUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
