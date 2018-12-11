program AdventOfCode11;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Types,
  System.SysUtils,
  System.Generics.Collections;

function PartA(serial: integer): TPoint;
var
  grid: array [1..300, 1..300] of integer;
  i   : integer;
  j   : integer;
  max : integer;
  sum : integer;
  y   : integer;
  x   : integer;
begin
  for y := 1 to 300 do
    for x := 1 to 300 do
      grid[x,y] := ((((x + 10) * y + serial) * (x + 10)) div 100) mod 10 - 5;
  max := 0;
  Result := Point(-1, -1);
  for y := 1 to 298 do
    for x := 1 to 298 do begin
      sum := 0;
      for j := y to y + 2 do
        for i := x to x + 2 do
          Inc(sum, grid[i,j]);
      if sum > max then begin
        max := sum;
        Result := Point(x, y);
      end;
    end;
end;

function PartB(serial: integer): TPair<TPoint,integer>;
var
  grid: array [1..300, 1..300] of integer;
  i   : integer;
  j   : integer;
  max : integer;
  size: integer;
  sq1 : integer;
  sqx : integer;
  x   : integer;
  x2  : integer;
  y   : integer;
  y2  : integer;
begin
  for y := 1 to 300 do
    for x := 1 to 300 do
      grid[x,y] := ((((x + 10) * y + serial) * (x + 10)) div 100) mod 10 - 5;
  max := 0;
  Result := TPair<TPoint,integer>.Create(Point(-1, -1), 0);

// Brute force, quite slow
//  for size := 1 to 300 do
//    for y := 1 to 300 - size + 1 do
//      for x := 1 to 300 - size + 1 do begin
//        sum := 0;
//        for j := y to y + size - 1 do
//          for i := x to x + size - 1 do
//            Inc(sum, grid[i,j]);
//        if sum > max then begin
//          max := sum;
//          Result := TPair<TPoint,integer>.Create(Point(x, y), size);
//        end;
//      end;

  for size := 300 downto 1 do begin
    if (size*size*9) < max then
      break; //for

    sq1 := 0;
    for j := 1 to size do
      for i := 1 to size do
        Inc(sq1, grid[i,j]);

    for y := size+1 to 300 do begin
      sqx := sq1;
      for x := size+1 to 300 do begin
        if sqx > max then begin
          max := sqx;
          Result := TPair<TPoint,integer>.Create(Point(x-size, y-size), size);
        end;
        // remove left column, add right column
        for y2 := y - size to y - 1 do
          sqx := sqx - grid[x - size, y2] + grid[x, y2];
      end; //for x

      // remove top row, add bottom row
      for x2 := 1 to size do
        sq1 := sq1 - grid[x2, y - size] + grid[x2 , y];
    end; //for y

  end; //for size
end;

begin
  try
    Assert(PartA(18) = Point(33,45), 'PartA(18) <> 33,45');
    Assert(PartA(42) = Point(21,61), 'PartA(42) <> 21,61');
    with PartA(4151) do
      Writeln('PartA: ', X, ',', Y);

    with PartB(18) do begin
      Assert(Key = Point(90,269), 'PartB(18).Point <> 90,269');
      Assert(Value = 16, 'PartB(18).Size <> 16');
    end;
    with PartB(42) do begin
      Assert(Key = Point(232,251), 'PartB(42).Point <> 232,251');
      Assert(Value = 12, 'PartB(42).Size <> 12');
    end;
    with PartB(4151) do
      Writeln('PartB: ', Key.X, ',', Key.Y, ',', Value);
   except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
