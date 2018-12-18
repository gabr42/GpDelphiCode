program AdventOfCode18;

{$APPTYPE CONSOLE}
{$RANGECHECKS OFF}

{$R *.res}

uses
  System.SysUtils,
  System.Classes;

type
  {$SCOPEDENUMS ON}
  Ground = (Open, Trees, Lumberyard);
  {$SCOPEDENUMS OFF}

  TAcre = array [0..51, 0..51] of Ground;

function LoadAcre(const fileName: string): TAcre;
var
  outCol: integer;
  outRow: integer;
  reader: TStreamReader;
  row   : string;
begin
  FillChar(Result, SizeOf(Result), Ground.Open);
  reader := TStreamReader.Create(fileName);
  try
    outRow := 1;
    while not reader.EndOfStream do begin
      row := reader.ReadLine;
      for outCol := 1 to Length(row) do
        case row[outCol] of
          '.': Result[outRow, outCol] := Ground.Open;
          '|': Result[outRow, outCol] := Ground.Trees;
          '#': Result[outRow, outCol] := Ground.Lumberyard;
        end;
      Inc(outRow);
    end;
  finally FreeAndNil(reader); end;
end;

procedure CountAcre(const acre: TAcre; size: integer; var trees, lumber: integer);
var
  row: integer;
  col: integer;
begin
  trees := 0;
  lumber := 0;
  for row := 1 to size do
    for col := 1 to size do
      case acre[row,col] of
        Ground.Open: ;
        Ground.Trees: Inc(trees);
        Ground.Lumberyard: Inc(lumber);
      end;
end;

procedure DumpAcre(const acre: TAcre; size: integer);
var
  row: integer;
  col: integer;
begin
  for row := 1 to size do begin
    for col := 1 to size do
      case acre[row,col] of
        Ground.Open: Write('.');
        Ground.Trees: Write('|');
        Ground.Lumberyard: Write('#');
      end;
    Writeln;
  end;
end;

function SameAcre(const acre1, acre2: TAcre; size: integer): boolean;
var
  row: integer;
  col: integer;
begin
  Result := true;
  for row := 1 to size do
    for col := 1 to size do
      if acre1[row,col] <> acre2[row,col] then
        Exit(false);
end;

procedure Grow(var acre: TAcre; size, steps: integer);
var
  i: integer;
  newAcre: TAcre;
  numLumber: integer;
  numTree: integer;
  row: Integer;
  col: Integer;
  y: Integer;
  x: Integer;
begin
//  DumpAcre(acre, size); Readln;
  for i := 1 to steps do begin
    newAcre := acre;
    for row := 1 to size do
      for col := 1 to size do begin
        numTree := 0;
        numLumber := 0;
        for y := row - 1 to row + 1 do
          for x := col - 1 to col + 1 do
            if (y <> row) or (x <> col) then
              case acre[y,x] of
                Ground.Open: ;
                Ground.Trees: Inc(numTree);
                Ground.Lumberyard: Inc(numLumber);
              end;
        case acre[row,col] of
          Ground.Open:
            if numTree >= 3 then
              newAcre[row,col] := Ground.Trees;
          Ground.Trees:
            if numLumber >= 3 then
              newAcre[row,col] := Ground.Lumberyard;
          Ground.Lumberyard:
            if (numTree < 1) or (numLumber < 1) then
              newAcre[row,col] := Ground.Open;
        end;
      end;
    acre := newAcre;
//    DumpAcre(acre, size); // Readln;
  end;
end;

function PartA(const fileName: string; size, steps: integer): integer;
var
  acre: TAcre;
  lumber: integer;
  trees: integer;
begin
  acre := LoadAcre(fileName);
  Grow(acre, size, steps);
  CountAcre(acre, size, trees, lumber);
  Result := trees * lumber;
end;

function PartB(const fileName: string; size, steps: integer): integer;
var
  acre1: TAcre;
  acre2: TAcre;
  gotloop: boolean;
  lumber: integer;
  step: integer;
  trees: integer;
begin
  acre1 := LoadAcre(fileName);
  acre2 := acre1;
  step := 1;
  gotloop := false;
  while step <= steps do begin
    Grow(acre1, size, 1);
    if not gotloop then begin
      Grow(acre2, size, 1);
      Grow(acre2, size, 1);
      if SameAcre(acre1, acre2, size) then begin
        //  Writeln('Loop detected at ', step);
        // could find a tighter loop here, but it doesn't matter ...
        step := steps div step * step;
        gotloop := true;
      end;
    end;
    Inc(step);
  end;
  CountAcre(acre1, size, trees, lumber);
  Result := trees * lumber;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode18test.txt', 10, 10) = 1147, 'PartA(test) <> 1147');
    Writeln('PartA: ', PartA('..\..\AdventOfCode18.txt', 50, 10));

    Writeln('PartB: ', PartB('..\..\AdventOfCode18.txt', 50, 1000000000));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
