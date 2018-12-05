program AdventOfCode5;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes;

function IsPair(ch1, ch2: char): boolean; inline;
begin
  Result := Abs(Ord(ch1) - Ord(ch2)) = 32;
end;

function React(const polymer: string): string;
var
  idx: integer;
begin
  Result := polymer;
  idx := 1;
  while idx < Length(Result) do begin
    if not IsPair(Result[idx], Result[idx+1]) then
      Inc(idx)
    else begin
      Delete(Result, idx, 2);
      if idx > 1 then
        Dec(idx);
    end
  end;
end;

function PartA(const fileName: string): integer;
var
  polymer: string;
  reader : TStreamReader;
begin
  reader := TStreamReader.Create(fileName);
  try
    polymer := React(reader.ReadLine);
    Result := Length(polymer);
  finally FreeAndNil(reader); end;
end;

function PartB(const fileName: string): integer;
var
  ch     : AnsiChar;
  len    : integer;
  polymer: string;
  reader : TStreamReader;
begin
  reader := TStreamReader.Create(fileName);
  try
    polymer := reader.ReadLine;
    Result := Length(polymer);
    for ch := 'a' to 'z' do begin
      len := React(polymer.Replace(ch, '', [rfReplaceAll, rfIgnoreCase])).Length;
      if len < Result then
        Result := len;
    end;
  finally FreeAndNil(reader); end;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode5test.txt') = 10, 'PartA(test) <> 10');
    Writeln('PartA: ', PartA('..\..\AdventOfCode5.txt'));

    Assert(PartB('..\..\AdventOfCode5test.txt') = 4, 'PartB(test) <> 4');
    Writeln('PartB: ', PartB('..\..\AdventOfCode5.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
