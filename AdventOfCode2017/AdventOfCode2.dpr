program AdventOfCode2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  GpString;

type
  TLine = TArray<integer>;
  TMatrix = TArray<TLine>;

function ConvertToLine(const s: string): TLine;
var
  el: TElements;
  i: Integer;
begin
  Split(s, #9, -1, el);
  SetLength(Result, Length(el));
  for i := Low(el) to High(el) do
    Result[i] := StrToInt(el[i]);
end;

function ReadMatrixFromFile(const fileName: string): TMatrix;
var
  sl: TStringList;
  i: Integer;
begin
  SetLength(Result, 0);
  sl := TStringList.Create;
  try
    sl.LoadFromFile(fileName);
    for i := 0 to sl.Count - 1 do begin
      SetLength(Result, i+1);
      Result[i] := ConvertToLine(sl[i]);
    end;
  finally FreeAndNil(sl); end;
end;

procedure GetMinMax(const line: TLine; var min, max: integer);
var
  i: integer;
begin
  Assert(Length(line) > 0);
  min := line[0];
  max := line[0];
  for i := 1 to High(line) do begin
    if line[i] < min then
      min := line[i];
    if line[i] > max then
      max := line[i];
  end;
end;

function PartA(const mat: TMatrix): integer;
var
  line: TLine;
  max : integer;
  min : integer;
begin
  Result := 0;
  for line in mat do begin
    GetMinMax(line, min, max);
    Inc(Result, max-min);
  end;
end;

function GetQuot(const line: TLine): integer;
var
  i: integer;
  j: integer;
begin
  Result := 0;
  for i := Low(line) to High(line) do
    for j := Low(line) to High(line) do
      if (i <> j) and ((line[i] mod line[j]) = 0) then
        Exit(line[i] div line[j]);
end;

function PartB(const mat: TMatrix): integer;
var
  line: TLine;
begin
  Result := 0;
  for line in mat do
    Inc(Result, GetQuot(line));
end;

var
  mat: TMatrix;
  line1: TLine;
  line2: TLine;
  line3: TLine;

begin
  try
    line1 := TLine.Create(5, 1, 9, 5);
    line2 := TArray<integer>.Create(7, 5, 3);
    line3 := TArray<integer>.Create(2, 4, 6, 8);
    SetLength(mat, 3);
    mat[0] := line1; mat[1] := line2; mat[2] := line3;
    Assert(PartA(mat) = 18, 'PartA(test) <> 18');

    line1 := TLine.Create(5, 9, 2, 8);
    line2 := TArray<integer>.Create(9, 4, 7, 3);
    line3 := TArray<integer>.Create(3, 8, 6, 5);
    SetLength(mat, 3);
    mat[0] := line1; mat[1] := line2; mat[2] := line3;
    Assert(PartB(mat) = 9, 'PartB(test) <> 9');

    mat := ReadMatrixFromFile('..\..\AdventOfCode2.txt');
    Assert(Length(mat) = 16, 'Invalid length of matrix');
    Assert(mat[0,0] = 493, 'Invalid element [0,0]');
    Assert(mat[High(mat), High(mat[High(mat)])] = 385, 'Invalid element [last,last]');
    Writeln('PartA: ', PartA(mat));
    Writeln('PartB: ', PartB(mat));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
