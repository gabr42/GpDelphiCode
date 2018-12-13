program AdventOfCode13;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Types,
  System.SysUtils,
  System.Math,
  System.Classes;

type
  TTrack = array of AnsiString;

  ICar = interface
    function GetVelocity: TPoint;
    function GetTickNum: integer;
    procedure SetVelocity(const value: TPoint);
    procedure SetTickNum(value: integer);
  //
    procedure Crossing;
    procedure TurnLeft;
    procedure TurnRight;
    property Velocity: TPoint read GetVelocity write SetVelocity;
    property TickNum: integer read GetTickNum write SetTickNum;
  end;

  TCar = class(TInterfacedObject, ICar)
  public type
    {$SCOPEDENUMS ON}
    Turn = (Left, Straight, Right);
    {$SCOPEDENUMS OFF}
  strict private
    FVelocity: TPoint;
    FTickNum: integer;
    FTurn: Turn;
  strict protected
    function GetVelocity: TPoint;
    function GetTickNum: integer;
    procedure SetVelocity(const value: TPoint);
    procedure SetTickNum(value: integer);
  public
    constructor Create(const direction: AnsiChar);
    procedure Crossing;
    procedure TurnLeft;
    procedure TurnRight;
    property Velocity: TPoint read GetVelocity write SetVelocity;
    property TickNum: integer read GetTickNum write SetTickNum;
  end;

  TCars = array of array of ICar;

constructor TCar.Create(const direction: AnsiChar);
begin
  inherited Create;
  case direction of
    '<': FVelocity := Point(-1, 0);
    '^': FVelocity := Point(0, -1);
    '>': FVelocity := Point(1, 0);
    'v': FVelocity := Point(0, 1);
    else raise Exception.CreateFmt('Invalid direction: %s', [direction]);
  end;
  FTurn := Turn.Left;
end;

function TCar.GetTickNum: integer;
begin
  Result := FTickNum;
end;

function TCar.GetVelocity: TPoint;
begin
  Result := FVelocity;
end;

procedure TCar.SetTickNum(value: integer);
begin
  FTickNum := value;
end;

procedure TCar.SetVelocity(const value: TPoint);
begin
  FVelocity := value;
end;

procedure TCar.Crossing;
begin
  case FTurn of
    Turn.Left: TurnLeft;
    Turn.Right: TurnRight;
  end;

  if FTurn = High(FTurn) then
    FTurn := Low(FTurn)
  else
    FTurn := Succ(FTurn);
end;

procedure TCar.TurnLeft;
begin
  //   1,  0  ->   0, -1
  //   0, -1  ->  -1,  0
  //  -1,  0  ->   0,  1
  //   0,  1  ->   1,  0

  FVelocity := Point(FVelocity.Y, - FVelocity.X);
end;

procedure TCar.TurnRight;
begin
  //   1,  0  ->   0,  1
  //   0,  1  ->  -1,  0
  //  -1,  0  ->   0, -1
  //   0, -1  ->   1,  0

  FVelocity := Point(- FVelocity.Y, FVelocity.X);
end;

procedure ReadTrack(const fileName: string; var track: TTrack;
  var cars: TCars; var numCars: integer);
var
  i       : integer;
  line    : string;
  maxLen  : integer;
  numLines: integer;
  reader  : TStreamReader;
begin
  reader := TStreamReader.Create(fileName);
  try
    maxLen := 0;
    numLines := 0;
    while not reader.EndOfStream do begin
      maxLen := Max(maxLen, Length(reader.ReadLine));
      Inc(numLines);
    end;
  finally FreeAndNil(reader); end;

  SetLength(track, numLines);
  SetLength(cars, numLines, maxLen);
  numLines := 0;
  numCars := 0;
  reader := TStreamReader.Create(fileName);
  try
    while not reader.EndOfStream do begin
      line := reader.ReadLine.PadRight(maxLen, ' ');
      for i := 1 to Length(line) do
        if CharInSet(line[i], ['<', '^', '>', 'v']) then begin
          cars[numLines, i-1] := TCar.Create(AnsiChar(line[i]));
          Inc(numCars);
        end;
      track[numLines] := AnsiString(line.Replace('v', '|', [rfReplaceAll])
                                        .Replace('^', '|', [rfReplaceAll])
                                        .Replace('<', '-', [rfReplaceAll])
                                        .Replace('>', '-', [rfReplaceAll]));
      Inc(numLines);
    end;
  finally FreeAndNil(reader); end;
end;

procedure AdvanceCar(const car: ICar; const track: TTrack; X, Y: integer;
  var newX, newY: integer);
begin
  newX := x + car.Velocity.X;
  newY := y + car.Velocity.Y;
  case track[newY, newX+1] of
    '\':
      if car.Velocity.Y = 0 then
        car.TurnRight
      else
        car.TurnLeft;
    '/':
      if car.Velocity.X = 0 then
        car.TurnRight
      else
        car.TurnLeft;
    '+':
      car.Crossing;
  end;
  car.TickNum := car.TickNum + 1;
end;

function PartA(const fileName: string): TPoint;
var
  cars   : TCars;
  col    : integer;
  newCol : integer;
  newRow : integer;
  numCars: integer;
  row    : integer;
  tick   : integer;
  track  : TTrack;
begin
  ReadTrack(fileName, track, cars, numCars);

  tick := 0;
  repeat
    for row := Low(cars) to High(cars) do
      for col := Low(cars[row]) to High(cars[row]) do
        if assigned(cars[row, col]) and (cars[row, col].TickNum = tick) then begin
          AdvanceCar(cars[row, col], track, col, row, newCol, newRow);
          if assigned(cars[newRow, newCol]) then
            Exit(Point(newCol, newRow));
          cars[newRow, newCol] := cars[row, col];
          cars[row, col] := nil;
        end;
    Inc(tick);
  until false;
end;

function PartB(const fileName: string): TPoint;
var
  cars   : TCars;
  col    : integer;
  newCol : integer;
  newRow : integer;
  numCars: integer;
  row    : integer;
  tick   : integer;
  track  : TTrack;

  function FindLastCar: TPoint;
  var
    col: integer;
    row: integer;
  begin
    Result := Point(-1, -1);
    for row := Low(cars) to High(cars) do
      for col := Low(cars[row]) to High(cars[row]) do
        if assigned(cars[row, col]) then
          Exit(Point(col, row));
  end;

begin
  ReadTrack(fileName, track, cars, numCars);

  tick := 0;
  repeat
    for row := Low(cars) to High(cars) do
      for col := Low(cars[row]) to High(cars[row]) do
        if assigned(cars[row, col]) and (cars[row, col].TickNum = tick) then begin
          AdvanceCar(cars[row, col], track, col, row, newCol, newRow);
          if assigned(cars[newRow, newCol]) then begin
            cars[newRow, newCol] := nil;
            Dec(numCars, 2);
          end
          else
            cars[newRow, newCol] := cars[row, col];
          cars[row, col] := nil;
        end;
    Inc(tick);
  until numCars = 1;

  Result := FindLastCar;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode13test.txt') = Point(7,3), 'PartA(test) <> (7,3)');
    with PartA('..\..\AdventOfCode13.txt') do
      Writeln(X, ',', Y);

    Assert(PartB('..\..\AdventOfCode13test2.txt') = Point(6,4), 'PartB(test) <> (6,4)');
    with PartB('..\..\AdventOfCode13.txt') do
      Writeln(X, ',', Y);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
