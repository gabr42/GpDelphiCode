program AdventOfCode7;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  TDependencies = array ['A'..'Z', '@'..'Z'] of boolean; //'@' = 'needs to run' flag
  TWorkers = array of TPair<integer, char>;

function LoadDependencies(const fileName: string): TDependencies;
var
  parts : TArray<string>;
  reader: TStreamReader;
begin
  FillChar(Result, SizeOf(Result), false);
  reader := TStreamReader.Create(fileName);
  try
    while not reader.EndOfStream do begin
      parts := reader.ReadLine.Split([' ']);
      if Length(parts) = 0 then
        continue;
      Assert(Length(parts) = 10);
      Result[parts[7][1], parts[1][1]] := true;
      Result[parts[1][1], '@'] := true;
      Result[parts[7][1], '@'] := true;
    end;
  finally FreeAndNil(reader); end;
end;

function CanStart(const dependencies: TDependencies; ch: char): boolean;
var
  dep: char;
begin
  Result := dependencies[ch, '@'];
  if Result then
    for dep := 'A' to 'Z' do
      if dependencies[ch, dep] then
        Exit(false);
end;

function SelectStep(const dependencies: TDependencies): string;
var
  ch: char;
begin
  Result := '';
  for ch := 'A' to 'Z' do
    if CanStart(dependencies, ch) then
      Exit(ch);
end;

function SelectSteps(const dependencies: TDependencies): string;
var
  ch: char;
begin
  Result := '';
  for ch := 'A' to 'Z' do
    if CanStart(dependencies, ch) then
      Result := Result + ch;
end;

function MarkCompleted(var dependencies: TDependencies; step: char): string;
var
  ch: char;
begin
  for ch := 'A' to 'Z' do
    dependencies[ch, step] := false;
  dependencies[step, '@'] := false;
end;

function PartA(const fileName: string): string;
var
  dependencies: TDependencies;
  step        : string;
begin
  dependencies := LoadDependencies(fileName);
  Result := '';
  repeat
    step := SelectStep(dependencies);
    if step = '' then
      Exit;
    Result := Result + step;
    MarkCompleted(dependencies, step[1]);
  until false;
end;

procedure AllocateWorkers(var dependencies: TDependencies; var workers: TWorkers;
  nextSteps: string; fixedTime: integer);
var
  i: integer;
begin
  for i := Low(workers) to High(workers) do
    if nextSteps = '' then
      Exit
    else if workers[i].Value = #0 then begin
      workers[i] := TPair<integer,char>.Create(fixedTime + Ord(nextSteps[1]) - Ord('A') + 1, nextSteps[1]);
      dependencies[nextSteps[1], '@'] := false;
      nextSteps := nextSteps.Remove(0, 1);
    end;
end;

function ForwardWorkers(var workers: TWorkers): integer;
var
  i: integer;
begin
  Result := 0;
  for i := Low(workers) to High(workers) do
    if (workers[i].Value <> #0) and ((Result = 0) or (workers[i].Key < Result)) then
      Result := workers[i].Key;
  for i := Low(workers) to High(workers) do
    if workers[i].Value <> #0 then
      workers[i].Key := workers[i].Key - Result;
end;

function PartB(const fileName: string; numWorkers, fixedTime: integer): integer;
var
  advance     : integer;
  dependencies: TDependencies;
  i           : integer;
  nextSteps   : string;
  step        : string;
  workers     : TWorkers;
begin
  Result := 0;
  dependencies := LoadDependencies(fileName);
  repeat
    SetLength(workers, numWorkers);

    nextSteps := SelectSteps(dependencies);
    if nextSteps <> '' then
      AllocateWorkers(dependencies, workers, nextSteps, fixedTime);
    advance := ForwardWorkers(workers);
    if advance = 0 then
      Exit;
    Inc(Result, advance);

    for i := Low(workers) to High(workers) do
      if (workers[i].Key = 0) and (workers[i].Value <> #0) then begin
        MarkCompleted(dependencies, workers[i].Value);
        workers[i].Value := #0;
      end;
  until false;
end;


begin
  try
    Assert(PartA('..\..\AdventOfCode7test.txt') = 'CABDFE', 'PartA(test) failed');
    Writeln('PartA: ', PartA('..\..\AdventOfCode7.txt'));

    Assert(PartB('..\..\AdventOfCode7test.txt', 2, 0) = 15, 'PartB(test) failed');
    Writeln('PartB: ', PartB('..\..\AdventOfCode7.txt', 5, 60));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
