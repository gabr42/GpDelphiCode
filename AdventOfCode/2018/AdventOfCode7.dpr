program AdventOfCode7;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes;

type
  TDependencies = array ['A'..'Z', '@'..'Z'] of boolean; //'@' = 'needs to run' flag

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

function SelectStep(const dependencies: TDependencies): string;

  function CanStart(ch: char): boolean;
  var
    dep: char;
  begin
    Result := dependencies[ch, '@'];
    if Result then
      for dep := 'A' to 'Z' do
        if dependencies[ch, dep] then
          Exit(false);
  end;

var
  ch: char;
begin
  Result := '';
  for ch := 'A' to 'Z' do
    if CanStart(ch) then
      Exit(ch);
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

begin
  try
    Assert(PartA('..\..\AdventOfCode7test.txt') = 'CABDFE', 'PartA(test) failed');
    Writeln('PartA: ', PartA('..\..\AdventOfCode7.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
