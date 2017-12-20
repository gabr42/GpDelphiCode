program AdventOfCode19;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Types, System.SysUtils,
  GpStreams, GpTextStream;

type
  TMaze = TArray<string>;

function LoadMaze(const fileName: string): TMaze;
var
  line: string;
begin
  for line in EnumLines(AutoDestroyStream(SafeCreateFileStream(fileName, fmOpenRead)).Stream) do
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := line;
  end;
end;

function Turn(const maze: TArray<string>; const pos, dir: TPoint): TPoint;
begin
  Result.X := dir.Y;
  Result.Y := - dir.X;
  if maze[pos.Y + Result.Y][pos.X + Result.X] = ' ' then begin
    Result.X := - Result.X;
    Result.Y := - Result.Y;
  end;
end;

procedure Walk(const fileName: string; var letters: string; var steps: integer);
var
  dir : TPoint;
  loc : TPoint;
  maze: TMaze;
begin
  maze := LoadMaze(fileName);
  letters := '';
  steps := 0;
  loc := Point(Pos('|', maze[0]), 0);
  dir := Point(0, 1);
  repeat
    if not (maze[loc.Y][loc.X] in [' ', '+', '-', '|']) then
      letters := letters + maze[loc.Y][loc.X]
    else if maze[loc.Y][loc.X] = '+' then
      dir := Turn(maze, loc, dir);
    loc := Point(loc.X + dir.X, loc.Y + dir.Y);
    Inc(steps);
  until maze[loc.Y][loc.X] = ' ';
end;

function PartA(const fileName: string): string;
var
  steps: integer;
begin
  Walk(fileName, Result, steps);
end;

function PartB(const fileName: string): integer;
var
  letters: string;
begin
  Walk(fileName, letters, Result);
end;


begin
  try
    Assert(PartA('..\..\AdventOfCode19test.txt') = 'ABCDEF');
    Assert(PartB('..\..\AdventOfCode19test.txt') = 38);

    Writeln(PartA('..\..\AdventOfCode19.txt'));
    Writeln(PartB('..\..\AdventOfCode19.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
