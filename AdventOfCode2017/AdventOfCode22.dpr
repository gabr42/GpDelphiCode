program AdventOfCode22;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Types, System.SysUtils, System.Classes, System.Generics.Collections;

type
  TNodeState = (nsClean, nsWeakened, nsInfected, nsFlagged);

  TGrid = class(TDictionary<TPoint,TNodeState>)
  strict private
  var
    FCurrent  : TPoint;
    FMoveDir  : TPoint;
    FNumInfect: integer;
  strict protected
    function Reverse(const pt: TPoint): TPoint; inline;
    function TurnLeft(const pt: TPoint): TPoint; inline;
    function TurnRight(const pt: TPoint): TPoint; inline;
  public
    constructor Create(const fileName: string);
    procedure Burst;
    procedure ImprovedBurst;
    property NumInfections: integer read FNumInfect;
  end;

function PartA(const fileName: string): integer;
var
  grid: TGrid;
  step: integer;
begin
  grid := TGrid.Create(fileName);
  try
    for step := 1 to 10000 do
      grid.Burst;
    Result := grid.NumInfections;
  finally FreeAndNil(grid); end;
end;

function PartB(const fileName: string; numSteps: integer = 10000000): integer;
var
  grid: TGrid;
  step: integer;
begin
  grid := TGrid.Create(fileName);
  try
    for step := 1 to numSteps do
      grid.ImprovedBurst;
    Result := grid.NumInfections;
  finally FreeAndNil(grid); end;
end;

{ TGrid }

constructor TGrid.Create(const fileName: string);
var
  s  : string;
  sl : TStringList;
  x,y: integer;
begin
  inherited Create;
  sl := TStringList.Create;
  try
    sl.LoadFromFile(fileName);
    for y := 0 to sl.Count - 1 do begin
      s := sl[y];
      for x := 1 to Length(s) do
        if s[x] = '#' then
          Add(Point(x,y+1), nsInfected);
    end;
    FCurrent := Point((Length(sl[0]) + 1) div 2, (sl.Count + 1) div 2);
    FMoveDir := Point(0, -1);
  finally FreeAndNil(sl); end;
end;

function TGrid.Reverse(const pt: TPoint): TPoint; //inline
begin
  // 0, -1 => 0, 1
  Result.X := - pt.X;
  Result.Y := - pt.Y;
end;

function TGrid.TurnLeft(const pt: TPoint): TPoint; //inline
begin
  // 0, -1 => -1, 0
  Result.X := pt.Y;
  Result.Y := - pt.X;
end;

function TGrid.TurnRight(const pt: TPoint): TPoint; //inline
begin
  // 0, -1 => 1, 0
  Result.X := - pt.Y;
  Result.Y := pt.X;
end;

procedure TGrid.Burst;
var
  value: TNodeState;
begin
  value := nsClean;
  if TryGetValue(FCurrent, value) then
    FMoveDir := TurnRight(FMoveDir)
  else
    FMoveDir := TurnLeft(FMoveDir);

  if value = nsInfected then
    Remove(FCurrent)
  else begin
    Add(FCurrent, nsInfected);
    Inc(FNumInfect);
  end;

  FCurrent := FCurrent + FMoveDir;
end;

procedure TGrid.ImprovedBurst;
var
  value: TNodeState;
begin
  if not TryGetValue(FCurrent, value) then
    value := nsClean;

  case value of
    nsClean:    FMoveDir := TurnLeft(FMoveDir);
    nsWeakened: ;
    nsInfected: FMoveDir := TurnRight(FMoveDir);
    nsFlagged:  FMoveDir := Reverse(FMoveDir);
  end;

  if value = nsFlagged then
    value := nsClean
  else
    value := Succ(value);

  if value = nsClean then
    Remove(FCurrent)
  else begin
    if value = nsInfected then
      Inc(FNumInfect);
    AddOrSetValue(FCurrent, value);
  end;

  FCurrent := FCurrent + FMoveDir;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode22test.txt') = 5587);
    Assert(PartB('..\..\AdventOfCode22test.txt', 100) = 26);
    Assert(PartB('..\..\AdventOfCode22test.txt') = 2511944);

    Writeln(PartA('..\..\AdventOfCode22.txt'));
    Writeln(PartB('..\..\AdventOfCode22.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
