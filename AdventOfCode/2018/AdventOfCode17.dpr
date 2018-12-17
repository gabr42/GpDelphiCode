program AdventOfCode17;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Types,
  System.SysUtils,
  System.AnsiStrings,
  System.Classes,
  System.Math,
  System.Generics.Collections;

type
  TAnsiChars = set of AnsiChar;

  TSlice = class
  strict private
    FLeft: AnsiString;
    FRight: AnsiString;
  strict protected
    function GetCell(idx: integer): AnsiChar;
    procedure SetCell(idx: integer; value: AnsiChar);
    function GetLeft: integer;
    function GetRight: integer;
    function GetText: AnsiString;
  public
    function Count(valid: TAnsiChars): integer;
    function Find(above: TAnsiChars): TArray<integer>;
    procedure FindLimits(col: integer; nextLine: TSlice;
      var limits: TPoint; var isOpen: boolean);
    procedure MakeClay(left, right: integer);
    property Cell[idx: integer]: AnsiChar read GetCell write SetCell;
    property Left: integer read GetLeft;
    property Right: integer read GetRight;
    property Text: AnsiString read GetText;
  end;

  TGround = class(TObjectList<TSlice>)
  strict protected
    function GetRow(idx: integer): TSlice;
    procedure MakeClay(rowRange, colRange: TPoint);
    function Split(const s: string): TPoint;
  public
    procedure Dump(step: integer);
    function Find(const above, below: TAnsiChars): TArray<TPoint>;
    procedure Read(const fileName: string);
    property Row[idx: integer]: TSlice read GetRow;
  end;

  TSimulator = class
  strict private
    FGround: TGround;
  strict protected
    function Spread: boolean;
    function Waterfall: boolean;
  public
    constructor Create(ground: TGround);
    function CountWater: integer;
    procedure Run;
  end;

{ TSlice }

function TSlice.Count(valid: TAnsiChars): integer;
var
  ch: AnsiChar;
begin
  Result := 0;
  for ch in FLeft do
    if ch in valid then
      Inc(Result);
  for ch in FRight do
    if ch in valid then
      Inc(Result);
end;

function TSlice.Find(above: TAnsiChars): TArray<integer>;
var
  col: integer;
  list: TList<integer>;
begin
  list := TList<integer>.Create;
  try
    for col := Left to Right do
      if Cell[col] in above then
        list.Add(col);
    Result := list.ToArray;
  finally FreeAndNil(list); end;
end;

procedure TSlice.FindLimits(col: integer; nextLine: TSlice;
 var limits: TPoint; var isOpen: boolean);
var
  openLeft: boolean;
  openRight: boolean;
  x: integer;
begin
  limits := Point(col, col);

  openLeft := true;
  for x := col - 1 downto Left do
    if not (nextLine.Cell[x] in ['#', '~']) then begin
      limits.X := x;
      break; //for x
    end
    else if Cell[x] = '#' then begin
      limits.X := x + 1;
      openLeft := false;
      break; //for x
    end;

  openRight := true;
  for x := col + 1 to Right do
    if not (nextLine.Cell[x] in ['#', '~']) then begin
      limits.Y := x;
      break; //for x
    end
    else if Cell[x] = '#' then begin
      limits.Y := x - 1;
      openRight := false;
      break; //for x
    end;

  isOpen := openLeft or openRight;
end;

function TSlice.GetCell(idx: integer): AnsiChar;
begin
  if idx >= 500 then
    Result := FRight[idx-499]
  else
    Result := FLeft[500-idx];
end;

function TSlice.GetLeft: integer;
begin
  Result := 500 - Length(FLeft);
end;

function TSlice.GetRight: integer;
begin
  Result := 499 + Length(FRight);
end;

function TSlice.GetText: AnsiString;
begin
  Result := ReverseString(FLeft) + FRight;
end;

procedure TSlice.MakeClay(left, right: integer);
var
  x: integer;
begin
  for x := left to right do
    Cell[x] := '#';
end;

procedure TSlice.SetCell(idx: integer; value: AnsiChar);
begin
  if idx >= 500 then begin
    if Length(FRight) < (idx-499) then
      FRight := FRight + StringOfChar(AnsiChar('.'), idx - 499 - Length(FRight));
    FRight[idx-499] := value;
  end
  else begin
    if Length(FLeft)< (500-idx) then
      FLeft := FLeft + StringOfChar(AnsiChar('.'), 500 - idx - Length(FLeft));
    FLeft[500-idx] := value;
  end;
end;

{ TGround }

procedure TGround.Dump(step: integer);
var
  slice: TSlice;
  tf: textfile;
begin
Exit;
  Assign(tf, Format('c:\0\waterfall-%.4d.txt', [step]));
  Rewrite(tf);
  for slice in Self do
    Writeln(tf, slice.Text);
  Close(tf);
end;

function TGround.Find(const above, below: TAnsiChars): TArray<TPoint>;
var
  col: integer;
  iRow: integer;
  points: TList<TPoint>;
begin
  points := TList<TPoint>.Create;
  try
    for iRow := 0 to Count - 2 do
      for col in Items[iRow].Find(above) do
        if Items[iRow+1].Cell[col] in below then
          points.Add(Point(col, iRow));
    Result := points.ToArray;
  finally FreeAndNil(points); end;
end;

function TGround.GetRow(idx: integer): TSlice;
begin
  while Count <= idx do
    Add(TSlice.Create);
  Result := Items[idx];
end;

procedure TGround.MakeClay(rowRange, colRange: TPoint);
var
  iRow: integer;
begin
  for iRow := rowRange.X to rowRange.Y do
    Row[iRow].MakeClay(colRange.X, colRange.Y);
end;

procedure TGround.Read(const fileName: string);
var
  bounds: TPoint;
  parts : TArray<string>;
  reader: TStreamReader;
  slice : TSlice;
begin
  reader := TStreamReader.Create(fileName);
  try
    while not reader.EndOfStream do begin
      parts := reader.ReadLine.Split([', ']);
      if Length(parts) = 0 then
        continue; //while
      if UpCase(parts[0][1]) = 'X' then
        MakeClay(Split(parts[1]), Split(parts[0]))
      else
        MakeClay(Split(parts[0]), Split(parts[1]));
    end;
  finally FreeAndNil(reader); end;

  Row[0].Cell[500] := '+';
  bounds := Point(500, 500);
  for slice in Self do
    bounds := Point(Min(bounds.X, slice.Left), Max(bounds.Y, slice.Right));
  for slice in Self do begin
    slice.Cell[bounds.X-1] := '.';
    slice.Cell[bounds.Y+1] := '.';
  end;
end;

function TGround.Split(const s: string): TPoint;
var
  parts: TArray<string>;
begin
  parts := s.Split(['='])[1].Split(['..']);
  if Length(parts) = 2 then
    Result := Point(parts[0].ToInteger, parts[1].ToInteger)
  else
    Result := Point(parts[0].ToInteger, parts[0].ToInteger);
end;

{ TSimulator }

function TSimulator.CountWater: integer;
var
  slice: TSlice;
begin
  Result := 0;
  for slice in FGround do
    Result := Result + slice.Count(['~', '|']);
end;

constructor TSimulator.Create(ground: TGround);
begin
  inherited Create;
  FGround := ground;
end;

procedure TSimulator.Run;
var
  anything: boolean;
  step: integer;
begin
  step := 1;
  FGround.Dump(0); //Readln;
  repeat
    anything := Waterfall;
    if anything then begin
      FGround.Dump(step); //Readln;
      Inc(step);
    end;
    anything := Spread or anything;
    if anything then begin
      FGround.Dump(step); //Readln;
      Inc(step);
    end;
  until not anything;
end;

function TSimulator.Spread: boolean;
var
  col: integer;
  isOpen: boolean;
  limits: TPoint;
  pt: TPoint;
  slice: TSlice;
begin
  Result := false;
  for pt in FGround.Find(['+', '|'], ['#', '~']) do begin
    slice := FGround.Row[pt.Y];
    if (slice.Cell[pt.X-1] = '|') or (slice.Cell[pt.X+1] = '|') then begin
      if not ((slice.Cell[pt.X-1] = '.') or (slice.Cell[pt.X+1] = '.')) then
        continue; //for pt
    end;

    Result := true;
    slice.FindLimits(pt.X, FGround.Row[pt.Y+1], limits, isOpen);
    for col := limits.X to limits.Y do
      if not isOpen then
        slice.Cell[col] := '~'
      else
        slice.Cell[col] := '|';
  end;
end;

function TSimulator.Waterfall: boolean;
var
  pt: TPoint;
  row: integer;
begin
  Result := false;
  for pt in FGround.Find(['+', '|'], ['.']) do begin
    Result := true;
    row := pt.Y + 1;
    while (row < FGround.Count) and(FGround.Row[row].Cell[pt.X] = '.') do begin
      FGround.Row[row].Cell[pt.X] := '|';
      Inc(row);
    end;
  end;
end;

{ main }

function PartA(const fileName: string): integer;
var
  ground: TGround;
  simulator: TSimulator;
begin
  ground := TGround.Create;
  try
    ground.Read(fileName);
    simulator := TSimulator.Create(ground);
    try
      simulator.Run;
      Result := simulator.CountWater;
    finally FreeAndNil(simulator); end;
  finally FreeAndNil(ground); end;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode17test.txt') = 57, 'PartA(test) <> 57');
    Writeln('PartA: ', PartA('..\..\AdventOfCode17.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
