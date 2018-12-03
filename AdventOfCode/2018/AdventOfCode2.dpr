program AdventOfCode2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

procedure Count23(const ln: string; out has2, has3: boolean);
var
  ch      : char;
  count   : integer;
  counters: TDictionary<char, integer>;
begin
  has2 := false;
  has3 := false;
  counters := TDictionary<char, integer>.Create;
  try
    for ch in ln do
      if not counters.TryGetValue(ch, count) then
        counters.Add(ch, 1)
      else
        counters.AddOrSetValue(ch, count + 1);

    for ch in ln do
      if counters[ch] = 2 then
        has2 := true
      else if counters[ch] = 3 then
        has3 := true;
  finally FreeAndNil(counters); end;
end;

function PartA(const fileName: string): integer;
var
  has2: boolean;
  has3: boolean;
  num2: integer;
  num3: integer;
  reader: TStreamReader;
begin
  reader := TStreamReader.Create(fileName);
  try
    num2 := 0;
    num3 := 0;
    while not reader.EndOfStream do begin
      Count23(Trim(reader.ReadLine), has2, has3);
      if has2 then
        Inc(num2);
      if has3 then
        Inc(num3);
    end;
  finally FreeAndNil(reader); end;
  Result := num2 * num3;
end;

function OneCharDiff(const s1, s2: string; var posDiff: integer): boolean;
var
  i: integer;
begin
  if Length(s1) <> Length(s2) then
    Exit(false);
  posDiff := 0;
  for i := 1 to Length(s1) do
    if s1[i] = s2[i] then
      continue //for i
    else if posDiff > 0 then
      Exit(false)
    else
      posDiff := i;
  Result := true;
end;

function PartB(const fileName: string): string;
var
  i      : integer;
  ids    : TStringList;
  j      : integer;
  posDiff: integer;
  reader : TStreamReader;
  s      : string;
begin
  ids := TStringList.Create;
  try
    reader := TStreamReader.Create(fileName);
    try
      while not reader.EndOfStream do begin
        s := Trim(reader.ReadLine);
        if s <> '' then
          ids.Add(s);
      end;
    finally FreeAndNil(reader); end;

    for i := 0 to ids.Count - 2 do
      for j := i + 1 to ids.Count - 1 do
        if OneCharDiff(ids[i], ids[j], posDiff) then begin
          Result := ids[i];
          Delete(Result, posDiff, 1);
        end;
  finally FreeAndNil(ids); end;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode2testA.txt') = 12, 'PartA(test) <> 12');
    Writeln('PartA: ', PartA('..\..\AdventOfCode2.txt'));

    Assert(PartB('..\..\AdventOfCode2testB.txt') = 'fgij', 'PartB(test) <> fgij');
    Writeln('PartB: ', PartB('..\..\AdventOfCode2.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
