program AdventOfCode11;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Math,
  GpStuff, GpStreams;

var
  s: AnsiString;

procedure Walk(const directions: string; var distance, maxDistance: integer);
var
  step: string;
  x   : integer;
  y   : integer;
  z   : integer;
begin
  // http://keekerdc.com/2011/03/hexagon-grids-coordinate-systems-and-distance-calculations/
  x := 0; y := 0; z := 0;
  maxDistance := 0;
  for step in SplitList(directions, ',') do begin
    if step = 'se' then
      Inc(x)
    else if step = 'ne' then
      Inc(y)
    else if step = 'n' then begin
      Dec(x);
      Inc(y);
    end
    else if step = 'nw' then
      Dec(x)
    else if step = 'sw' then
      Dec(y)
    else if step = 's' then begin
      Inc(x);
      Dec(y);
    end
    else
      raise Exception.Create('Invalid step: ' + step);
    z := 0 - x - y;
    distance := Max(Max(Abs(x), Abs(y)), Abs(z));
    if distance > maxDistance then
      maxDistance := distance;
  end; //for step
end;

function PartA(const directions: string): integer;
var
  distance   : integer;
  maxDistance: integer;
begin
  Walk(directions, distance, maxDistance);
  Result := distance;
end;

function PartB(const directions: string): integer;
var
  distance   : integer;
  maxDistance: integer;
begin
  Walk(directions, distance, maxDistance);
  Result := maxDistance;
end;

begin
  try
    Assert(PartA('ne,ne,ne') = 3, 'PartA test #1 failed');
    Assert(PartA('ne,ne,sw,sw') = 0, 'PartA test #2 failed');
    Assert(PartA('ne,ne,s,s') = 2, 'PartA test #3 failed');
    Assert(PartA('se,sw,se,sw,sw') = 3, 'PartA test #4 failed');

    if not ReadFromFile('..\..\AdventOfCode11.txt', s) then
      raise Exception.Create('Failed to read from file');
    Writeln(PartA(string(s)));
    Writeln(PartB(string(s)));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
