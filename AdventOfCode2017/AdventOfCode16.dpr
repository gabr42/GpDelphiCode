program AdventOfCode16;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  GpStreams;

type
  TDanceMove = record
    MoveType: (Spin, Exchange, Partner);
    Size: integer;
    Idx1, Idx2: integer;
    Prog1, Prog2: char;
  end;
  PDanceMove = ^TDanceMove;

  TDance = class
  strict private
    FDanceMoves: TArray<TDanceMove>;
  public type
    TDanceEnumerator = record
    private
      FDanceMoves: TArray<TDanceMove>;
      FIndex     : integer;
      FLast      : integer;
      function GetCurrent: PDanceMove; inline;
    public
      function MoveNext: boolean; inline;
      property Current: PDanceMove read GetCurrent;
    end;
  public
    constructor Create(const s: string);
    function GetEnumerator: TDanceEnumerator;
  end;

function GenerateLine(lastProg: char):  string;
var
  ch: char;
begin
  Result := '';
  for ch := 'a' to lastProg do
    Result := Result + ch;
end;

procedure SpinMove(const line: string; size: integer); inline;
var
  buf    : array [1..25] of char;
  lenLine: integer;
  pLine  : PChar;
begin
  lenLine := Length(line);
  pLine := PChar(PDWord(@line)^);
  Move(pLine^, buf[1], (lenLine - size) * 2);
  Move(pLine[lenLine - size], pLine^, size * 2);
  Move(buf[1], pLine[size], (lenLine - size) * 2);
end;

procedure ExchangeMove(var line: string; idx1, idx2: integer); inline;
var
  pLine: PChar;
  tmp  : char;
begin
  pLine := PChar(PDWord(@line)^);
  tmp := pLine[idx1];
  pLine[idx1] := pLine[idx2];
  pLine[idx2] := tmp;
end;

function Pos(prog: char; const line: string): integer; inline;
var
  i: integer;
begin
  for i := 1 to Length(line) do
    if line[i] = prog then
      Exit(i-1);
  raise Exception.Create('Program not found');
end;

function PartA(const line: string; const dance: TDance): string;
var
  danceMove: PDanceMove;
begin
  Result := line;
  for danceMove in dance do
    case danceMove.MoveType of
      Spin:      SpinMove(Result, danceMove.Size);
      Exchange:  ExchangeMove(Result, danceMove.Idx1, danceMove.Idx2);
      Partner:   ExchangeMove(Result, Pos(danceMove.Prog1, Result), Pos(danceMove.Prog2, Result));
    end;
end;

function PartB(const line: string; const dance: TDance): string;
var
  danceMove: PDanceMove;
  i        : integer;
  memo     : TStringList;
  steps    : integer;
begin
  Result := line;
  memo := TStringList.Create;
  try
    steps := 1000000000;

    memo.Sorted := true;
    repeat
      memo.Add(Copy(Result, 1, Length(Result)));
      Result := PartA(Result, dance);
    until memo.IndexOf(Result) >= 0;

    Dec(steps, memo.Count);

    memo.Clear;
    repeat
      memo.Add(Copy(Result, 1, Length(Result)));
      Result := PartA(Result, dance);
    until memo.IndexOf(Result) >= 0;

    Dec(steps, memo.Count);

    // Cycle of memo.Count found
    Result := memo[0];

    for i := 1 to steps mod memo.Count do
      Result := PartA(Result, dance);
  finally FreeAndNil(memo); end;
end;

var
  s: AnsiString;

{ TDance }

constructor TDance.Create(const s: string);
var
  i     : integer;
  nums  : TArray<string>;
  sMove : string;
  sMoves: TArray<string>;
begin
  sMoves := s.Split([',']);
  SetLength(FDanceMoves, Length(sMoves));
  for i := Low(sMoves) to High(sMoves) do begin
    sMove := sMoves[i];
    case sMove[1] of
      's':
        begin
          FDanceMoves[i].MoveType := Spin;
          FDanceMoves[i].Size := StrToInt(sMove.Substring(1{zero-based}));
        end;
      'x':
        begin
          nums := sMove.Substring(1{zero-based}).Split(['/']);
          FDanceMoves[i].MoveType := Exchange;
          FDanceMoves[i].Idx1 := StrToInt(nums[0]);
          FDanceMoves[i].Idx2 := StrToInt(nums[1]);
        end;
      'p':
        begin
          FDanceMoves[i].MoveType := Partner;
          FDanceMoves[i].Prog1 := sMove[2];
          FDanceMoves[i].Prog2 := sMove[4];
        end;
     else
       raise Exception.Create('Invalid dance move: ' + sMove);
    end;
  end;
end;

function TDance.GetEnumerator: TDanceEnumerator;
begin
  Result.FDanceMoves := FDanceMoves;
  Result.FIndex := -1;
  Result.FLast := High(FDanceMoves);
end;

{ TDance.TDanceEnumerator }

function TDance.TDanceEnumerator.GetCurrent: PDanceMove;
begin
  Result := @FDanceMoves[FIndex];
end;

function TDance.TDanceEnumerator.MoveNext: boolean;
begin
  Inc(FIndex);
  Result := (FIndex <= FLast);
end;

begin
  try
    Assert(PartA(GenerateLine('e'), TDance.Create('s1,x3/4,pe/b')) = 'baedc');

    if not ReadFromFile('..\..\AdventOfCode16.txt', s) then
      raise Exception.Create('Can''t read file');
    Writeln(PartA(GenerateLine('p'), TDance.Create(string(s))));
    Writeln(PartB(GenerateLine('p'), TDance.Create(string(s))));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
