program AdventOfCode12;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

procedure ReadInitialState(const fileName: string; var plants: string;
  rules: TList<string>);
var
  parts : TArray<string>;
  reader: TStreamReader;
begin
  reader := TStreamReader.Create(fileName);
  try
    plants := reader.ReadLine.Split([':'])[1].Trim;
    reader.ReadLine;
    while not reader.EndOfStream do begin
      parts := reader.ReadLine.Split([' ']);
      if parts[2] = '#' then
        rules.Add(parts[0]);
    end;
  finally FreeAndNil(reader); end;
end;

function Grow(const fileName: string; numSteps: integer;
  var left: integer; var plants: string): integer;
var
  i        : integer;
  newPlants: string;
  rules    : TList<string>;
  value    : integer;
  x        : integer;

  function MatchesRules(x: integer): boolean;
  var
    rule  : string;

    function MatchesRule: boolean;
    var
      i     : integer;
      ruleCh: integer;
    begin
      Result := true;
      ruleCh := 1;
      for i := x-2 to x+2 do begin
        if plants[i] <> rule[ruleCh] then
          Exit(false);
        Inc(ruleCh);
      end;
    end;

  begin
    Result := false;
    for rule in rules do
      if MatchesRule then
        Exit(true);
  end;

begin
  rules := TList<string>.Create;
  try
    ReadInitialState(fileName, plants, rules);
    plants :=  '....' + plants + '....';
    newPlants := plants;
    left := -4;
    for i := 1 to numSteps do begin
      for x := 3 to Length(plants) - 2 do begin
        if MatchesRules(x) then
          newPlants[x] := '#'
        else
          newPlants[x] := '.';
      end;
      if newPlants.IndexOf('#') < 4 then begin
        newPlants := '....' + newPlants;
        Dec(left, 4);
      end;
      if newPlants.LastIndexOf('#') > (Length(newPlants) - 5) then
        newPlants := newPlants + '....';
      plants := newPlants;
    end;

    plants := plants.TrimRight(['.']);
    while (plants[1] = '.') do begin
      Delete(plants, 1, 1);
      Inc(left);
    end;

    Result := 0;
    value := left;
    for x := 1 to Length(plants) do begin
      if plants[x] = '#' then
        Inc(Result, value);
      Inc(value);
    end;
  finally FreeAndNil(rules); end;
end;

function PartA(const fileName: string; numSteps: int64): integer;
var
  left  : integer;
  plants: string;
begin
  Result := Grow(fileName, numSteps, left, plants);
end;

function PartB(const fileName: string; numSteps: int64): int64;
var
  bigLeft: int64;
  left   : integer;
  plants : string;
  x      : integer;
{$IFDEF DEBUG}
  leftN  : integer;
  plantsN: string;
{$ENDIF}
begin
  // cheating a bit; did run a few tests and found out that my combination
  // starts repeating (and shifting right) after 184 steps
  Grow(fileName, 184, left, plants);

  {$IFDEF DEBUG}
  // sanity test - next step must be the same except that 'left' must be 1 larger
  Grow(fileName, 185, leftN, plantsN);
  Assert(plantsN = plants);
  Assert(leftN = left + 1);
  {$ENDIF}

  bigLeft := left + (numSteps - 184);
  Result := 0;
  for x := 1 to Length(plants) do begin
    if plants[x] = '#' then
      Inc(Result, bigLeft);
    Inc(bigLeft);
  end;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode12test.txt', 20) = 325, 'PartA(test) <> 325');
    Writeln('PartA: ', PartA('..\..\AdventOfCode12.txt', 20));

    Writeln('PartB: ', PartB('..\..\AdventOfCode12.txt', 50000000000));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
