program AdventOfCode21;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Generics.Collections,
  GpStreams, GpTextStream;

type
  TGrid = class(TList<string>)
  strict private type
    TSquare = TArray<string>;
    TGridSquares = TArray<TArray<TSquare>>;
  strict private
    FRules: TDictionary<string,string>;
    FState: TList<string>;
  strict protected
    function ApplyRulesToSquare(const square: TSquare): TSquare;
    function ExtractSquare(x, y, squareSize: integer): TSquare;
    procedure MergeSquares(const squares: TGridSquares);
    function MirrorSquare(const sq: TSquare): TSquare;
    function RotateSquare(const sq: TSquare): TSquare;
    function SplitIntoSquares(squareSize: integer): TGridSquares;
    function SquareToString(const sq: TSquare): string; inline;
    function StringToSquare(const s: string): TSquare; inline;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure ApplyRules;
    function  CountPixels(const pixel: char): integer;
    procedure LoadRules(const fileName: string);
  end;

function PartA(const fileName: string; generations: integer): integer;
var
  grid: TGrid;
  i   : Integer;
begin
  grid := TGrid.Create;
  try
    grid.LoadRules(fileName);
    for i := 1 to generations do
      grid.ApplyRules;
    Result := grid.CountPixels('#');
  finally FreeAndNil(grid); end;
end;

{ TGrid }

function TGrid.SquareToString(const sq: TSquare): string; //inline
begin
  Result := ''.Join('/', sq);
end;

function TGrid.StringToSquare(const s: string): TSquare;
begin
  Result := s.Split(['/']);
end;

procedure TGrid.ApplyRules;
var
  squares: TGridSquares;
  x,y    : integer;
begin
  if (FState.Count mod 2) = 0 then
    squares := SplitIntoSquares(2)
  else
    squares := SplitIntoSquares(3);
  for y := 0 to High(squares) do
    for x := 0 to High(squares) do
      squares[y,x] := ApplyRulesToSquare(squares[y,x]);
  MergeSquares(squares);
end;

function TGrid.ApplyRulesToSquare(const square: TSquare): TSquare;
var
  m,r: integer;
  map: string;
  sq : TSquare;
begin
  sq := square;
  for m := 1 to 2 do begin
    for r := 1 to 4 do begin
      if FRules.TryGetValue(SquareToString(sq), map) then begin
        Result := StringToSquare(map);
        Exit;
      end;
      sq := RotateSquare(sq);
    end;
    sq := MirrorSquare(sq);
  end;
end;

function TGrid.CountPixels(const pixel: char): integer;
var
  s: string;
begin
  Result := 0;
  for s in FState do
    Inc(Result, s.CountChar(pixel));
end;

constructor TGrid.Create;
begin
  FRules := TDictionary<string,string>.Create;
  FState := TList<string>.Create;
  FState.Add('.#.');
  FState.Add('..#');
  FState.Add('###');
end;

destructor TGrid.Destroy;
begin
  FreeAndNil(FState);
  FreeAndNil(FRules);
  inherited;
end;

function TGrid.ExtractSquare(x, y, squareSize: integer): TSquare;
var
  i: integer;
begin
  SetLength(Result, squareSize);
  for i := Low(Result) to High(Result) do
    Result[i] := FState[y + i].Substring(x, squareSize);
end;

procedure TGrid.LoadRules(const fileName: string);
var
  line : string;
  parts: TArray<string>;
begin
  for line in EnumLines(AutoDestroyStream(SafeCreateFileStream(fileName, fmOpenRead)).Stream) do
  begin
    parts := line.Split([' => ']);
    FRules.Add(parts[0], parts[1]);
  end;
end;

procedure TGrid.MergeSquares(const squares: TGridSquares);
var
  i,y   : integer;
  s     : string;
  sqLine: TArray<TSquare>;
  sq    : TSquare;
begin
  FState.Clear;
  for y := Low(squares) to High(squares) do begin
    sqLine := squares[y];
    for i := Low(sqLine[0]) to High(sqLine[0]) do begin
      s := '';
      for sq in sqLine do
        s := s + sq[i];
      FState.Add(s);
    end;
  end;
end;

function TGrid.MirrorSquare(const sq: TSquare): TSquare;
var
  i,j   : integer;
  sqSize: integer;
begin
  sqSize := Length(sq);
  SetLength(Result, sqSize);
  for i := 0 to High(Result) do
    Result[i] := string.Create(' ', sqSize);
  for i := 0 to High(Result) do
    for j := 0 to High(Result) do
      Result[i,j+1] := sq[i, sqSize-j];
end;

function TGrid.RotateSquare(const sq: TSquare): TSquare;
var
  i,j   : integer;
  sqSize: integer;
begin
  sqSize := Length(sq);
  SetLength(Result, sqSize);
  for i := 0 to High(Result) do
    Result[i] := string.Create(' ', sqSize);
  for i := 0 to High(Result) do
    for j := 0 to High(Result) do
      Result[i,j+1] := sq[j, sqSize-i];
end;

function TGrid.SplitIntoSquares(squareSize: integer): TGridSquares;
var
  x,y: integer;
begin
  SetLength(Result, FState.Count div squareSize);
  for y := 0 to High(Result) do begin
    SetLength(Result[y], Length(Result));
    for x := 0 to High(Result) do
      Result[y,x] := ExtractSquare(x * squareSize, y * squareSize, squareSize);
  end;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode21test.txt', 2) = 12);

    Writeln(PartA('..\..\AdventOfCode21.txt', 5));
    Writeln(PartA('..\..\AdventOfCode21.txt', 18));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
