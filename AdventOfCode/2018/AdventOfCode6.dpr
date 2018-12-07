program AdventOfCode6;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Types,
  System.SysUtils,
  System.Classes,
  System.Math,
  System.Generics.Collections;

type
  TLocations = TList<TPoint>;
  TArea = array of array of integer; // 0 = empty, -1 = undecided, 1+ = coordinate or nearest to coordinate

procedure LoadLocations(const fileName: string; locList: TLocations);
var
  parts : TArray<string>;
  reader: TStreamReader;
begin
  reader := TStreamReader.Create(fileName);
  try
    while not reader.EndOfStream do begin
      parts := reader.ReadLine.Trim.Replace(' ', '', [rfReplaceAll]).Split([',']);
      if Length(parts) = 0 then
        continue;
      locList.Add(Point(parts[0].ToInteger, parts[1].ToInteger));
    end;
  finally FreeAndNil(reader); end;
end;

function FindMinMax(locList: TLocations): TRect;
var
  loc: TPoint;
begin
  Result := Rect(locList[0].X, locList[0].Y, locList[0].X, locList[0].Y);
  for loc in locList do
    Result := Rect(Min(Result.Left, loc.X), Min(Result.Top, loc.Y),
                   Max(Result.Right, loc.X), Max(Result.Bottom, loc.Y));
end;

procedure OffsetLoc(locList: TLocations; var locRect: TRect);
var
  i  : integer;
  loc: TPoint;
begin
  for i := 0 to locList.Count - 1 do begin
    loc := locList[i];
    loc.Offset(-locRect.Left, -locRect.Top);
    locList[i] := loc;
  end;
  locRect.Offset(-locRect.Left, -locRect.Top);
end;

function CreateArea(locList: TLocations; const locRect: TRect): TArea;
var
  i: integer;
begin
  SetLength(Result, locRect.Height + 1, locRect.Width + 1);

  if assigned(locList) then
    for i := 0 to locList.Count - 1 do
      Result[locList[i].Y, locList[i].X] := i + 1;
end;

(*
procedure DumpArea(const area: TArea);
var
  i : integer;
  id: integer;
begin
  for i := Low(area) to High(area) do begin
    for id in area[i] do
      Write(id:4);
    Writeln;
  end;
  Writeln;
end;
*)

function CountIslands(const area: TArea; locList: TLocations;
  const locRect: TRect): TArray<integer>;
var
  borderRow: boolean;
  col      : integer;
  id       : integer;
  row      : integer;
begin
  SetLength(Result, locList.Count);
  for row := locRect.Top to locRect.Bottom do begin
    borderRow := (row = locRect.Top) or (row = locRect.Bottom);
    for col := locRect.Left to locRect.Right do begin
      id := area[row,col];
      if id > 0 then begin
        if borderRow or (col = locRect.Left) or (col = locRect.Right) then
          Result[id-1] := -1
        else if id > 0 then
          Result[id-1] := Result[id-1] + 1;
      end;
    end;
  end;
end;

function PartA(const fileName: string): integer;
var
  area     : TArea;
  col      : integer;
  dist     : integer;
  i        : integer;
  id       : integer;
  locList  : TLocations;
  locRect  : TRect;
  minDist  : integer;
  row      : integer;
  size     : integer;
  sizeList : TArray<integer>;
begin
  locList := TLocations.Create;
  try
    LoadLocations(fileName, locList);
    locRect := FindMinMax(locList);
    OffsetLoc(locList, locRect);
    area := CreateArea(locList, locRect);

    for row := locRect.Top to locRect.Bottom do
      for col := locRect.Left to locRect.Right do
        if area[row,col] = 0 then begin
          minDist := locRect.Width + locRect.Height;
          id := 0;
          for i := 0 to locList.Count - 1 do begin
            dist := Abs(locList[i].Y - row) + Abs(locList[i].X - col);
            if dist < minDist then begin
              minDist := dist;
              id := i + 1;
            end
            else if (dist = minDist) and (id > 0) and (id <> (i+1)) then
              id := -1;
          end;
          area[row,col] := id;
        end;

    sizeList := CountIslands(area, locList, locRect);
    Result := 0;
    for size in sizeList do
      if size > Result then
        Result := size;
  finally FreeAndNil(locList); end;
end;

function PartB(const fileName: string; cutoffDistance: integer): integer;
var
  col    : integer;
  dist   : integer;
  i      : integer;
  locList: TLocations;
  locRect: TRect;
  row    : integer;
begin
  locList := TLocations.Create;
  try
    LoadLocations(fileName, locList);
    locRect := FindMinMax(locList);
    OffsetLoc(locList, locRect);

    Result := 0;
    for row := locRect.Top to locRect.Bottom do
      for col := locRect.Left to locRect.Right do begin
        dist := 0;
        for i := 0 to locList.Count - 1 do
          dist := dist + Abs(locList[i].Y - row) + Abs(locList[i].X - col);
        if dist < cutoffDistance then
          Inc(Result);
      end;
  finally FreeAndNil(locList); end;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode6test.txt') = 17, 'PartA(test) failed');
    Writeln('PartA: ', PartA('..\..\AdventOfCode6.txt'));

    Assert(PartB('..\..\AdventOfCode6test.txt', 32) = 16, 'PartB(test) failed');
    Writeln('PartB: ', PartB('..\..\AdventOfCode6.txt', 10000));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
