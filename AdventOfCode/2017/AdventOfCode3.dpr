program AdventOfCode3;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Types, System.SysUtils, System.Math;

  function RotateLeft(dir: TPoint): TPoint;
  begin
    Result.Y := dir.X;
    Result.X := -dir.Y;
  end;

  function GeneratePosition(el: integer): TPoint;
  var
    bounds: TRect;
    dir   : TPoint;
    i     : integer;
    moved : TRect;
  begin
    Result := Point(0, 0);
    bounds := Rect(0, 0, 1, 1); //Delphi TRect doesn't "contain" bottom/right
    dir := Point(1, 0);
    for i := 2 to el do begin
      Result.Offset(dir);
      if not bounds.Contains(Result) then begin
        moved := bounds;
        moved.Offset(dir);
        bounds.Union(moved);
        dir := RotateLeft(dir);
      end;
    end;
  end;

  function PartA(el: integer): integer;
  var
    pt: TPoint;
  begin
    pt := GeneratePosition(el);
    Result := Abs(pt.X) + Abs(pt.Y);
  end;

type
  TMemory = array [-20..20, -20..20] of integer;

  function SumAround(const mem: TMemory; const pt: TPoint): integer;
  var
    dx: integer;
    dy: integer;
  begin
    Result := 0;
    for dx := -1 to 1 do
      for dy := -1 to 1 do
        Inc(Result, mem[pt.X + dx,pt.Y + dy]);
  end;

  function PartB(el: integer): integer;
  var
    bounds: TRect;
    dir   : TPoint;
    i     : integer;
    mem   : TMemory;
    moved : TRect;
    pos   : TPoint;
    sum   : integer;
  begin
    FillChar(mem, SizeOf(mem), 0);
    pos := Point(0, 0);
    bounds := Rect(0, 0, 1, 1); //Delphi TRect doesn't "include" bottom/right
    dir := Point(1, 0);
    mem[0, 0] := 1;
    repeat
      pos.Offset(dir);
      sum := SumAround(mem, pos);
      if sum > el then
        Exit(sum);
      mem[pos.X, pos.Y] := sum;
      if not bounds.Contains(pos) then begin
        moved := bounds;
        moved.Offset(dir);
        bounds.Union(moved);
        dir := RotateLeft(dir);
      end;
    until false;
  end;

begin
  try
    Assert(PartA(1) = 0, 'PartA(1) <> 0');
    Assert(PartA(12) = 3, 'PartA(12) <> 3');
    Assert(PartA(23) = 2, 'PartA(23) <> 2');
    Assert(PartA(1024) = 31, 'PartA(1024) <> 31');

    Assert(PartB(1) = 2, 'PartB(1) <> 2');
    Assert(PartB(4) = 5, 'PartB(4) <> 5');
    Assert(PartB(5) = 10, 'PartB(5) <> 10');
    Assert(PartB(58) = 59, 'PartB(58) <> 59');
    Assert(PartB(59) = 122, 'PartB(59) <> 122');

    Writeln('PartA: ', PartA(277678));
    Writeln('PartB: ', PartB(277678));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
