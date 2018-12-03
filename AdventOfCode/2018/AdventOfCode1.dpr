program AdventOfCode1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

function PartA(const fileName: string): integer;
var
  reader: TStreamReader;
  value : integer;
begin
  Result := 0;
  reader := TStreamReader.Create(fileName);
  while not reader.EndOfStream do begin
    if TryStrToInt(reader.ReadLine, value) then
      Inc(Result, value);
  end;
end;

function PartB(const fileName: string): integer;
var
  freq  : integer;
  reader: TStreamReader;
  seenHz: TDictionary<integer,boolean>;
  value: integer;
begin
  freq := 0;
  reader := nil;
  seenHz := TDictionary<integer,boolean>.Create;
  try
    seenHz.Add(0, true);
    repeat
      if (not assigned(reader)) or reader.EndOfStream then begin
        FreeAndNil(reader);
        reader := TStreamReader.Create(fileName);
      end;
      if TryStrToInt(reader.ReadLine, value) then
        Inc(freq, value);
      if seenHz.ContainsKey(freq) then
        Exit(freq);
      seenHz.Add(freq, true);
    until false;
  finally FreeAndNil(seenHz); end;
end;


begin
  try
    Assert(PartA('..\..\AdventOfCode1testA.txt') = 3, 'A(testA) <> 3');
    Assert(PartA('..\..\AdventOfCode1testB.txt') = 0, 'A(testB) <> 0');
    Assert(PartA('..\..\AdventOfCode1testC.txt') = -6, 'A(testC) <> -6');
    Writeln('PartA: ', PartA('..\..\AdventOfCode1.txt'));

    Assert(PartB('..\..\AdventOfCode1testD.txt') = 0, 'B(testD) <> 0');
    Assert(PartB('..\..\AdventOfCode1testE.txt') = 10, 'B(testE) <> 10');
    Assert(PartB('..\..\AdventOfCode1testF.txt') = 5, 'B(testF) <> 5');
    Assert(PartB('..\..\AdventOfCode1testG.txt') = 14, 'B(testG) <> 14');
    Writeln('PartB: ', PartB('..\..\AdventOfCode1.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
