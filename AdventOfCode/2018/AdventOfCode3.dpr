program AdventOfCode3;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes;

procedure Split(const s: string; var id, left, top, width, height: integer);
var
  parts: TArray<string>;
begin
  parts := s.Replace(' ', '', [rfReplaceAll]).Split(['#', '@', ',', ':', 'x']);
  Assert(Length(parts) = 6);
  id := StrToInt(parts[1]);
  left := StrToInt(parts[2]);
  top := StrToInt(parts[3]);
  width := StrToInt(parts[4]);
  height := StrToInt(parts[5]);
end;

function PartA(const fileName: string): integer;
var
  fabric: array of array of integer;
  height: integer;
  i     : integer;
  id    : integer;
  left  : integer;
  reader: TStreamReader;
  s     : string;
  top   : integer;
  width : integer;
  x     : integer;
  y     : Integer;
begin
  Result := 0;
  SetLength(fabric, 1500);
  for i := Low(fabric) to High(fabric) do
    SetLength(fabric[i], 1500);

  reader := TStreamReader.Create(fileName);
  try
    while not reader.EndOfStream do begin
      s := Trim(reader.ReadLine);
      if s = '' then
        break; //while
      Split(s, id, left, top, width, height);
      for x := left to left + width - 1 do
        for y := top to top + height - 1 do begin
          fabric[x,y] := fabric[x,y] + 1;
          if fabric[x,y] = 2 then
            Inc(Result);
        end;
    end;
  finally FreeAndNil(reader); end;
end;

function PartB(const fileName: string): integer;
var
  fabric: array of array of integer;
  height: integer;
  i     : integer;
  id    : integer;
  isOK: boolean;
  left  : integer;
  reader: TStreamReader;
  s     : string;
  top   : integer;
  width : integer;
  x     : integer;
  y     : Integer;
begin
  SetLength(fabric, 1500);
  for i := Low(fabric) to High(fabric) do
    SetLength(fabric[i], 1500);

  reader := TStreamReader.Create(fileName);
  try
    while not reader.EndOfStream do begin
      s := Trim(reader.ReadLine);
      if s = '' then
        break; //while
      Split(s, id, left, top, width, height);
      for x := left to left + width - 1 do
        for y := top to top + height - 1 do
          fabric[x,y] := fabric[x,y] + 1;
    end;
  finally FreeAndNil(reader); end;

  reader := TStreamReader.Create(fileName);
  try
    while not reader.EndOfStream do begin
      s := Trim(reader.ReadLine);
      if s = '' then
        break; //while
      Split(s, id, left, top, width, height);
      isOK := true;
      for x := left to left + width - 1 do
        for y := top to top + height - 1 do
          if fabric[x,y] <> 1 then
            isOK := false;
      if isOK then
        Exit(id);
    end;
  finally FreeAndNil(reader); end;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode3test.txt') = 4, 'PartA(test) <> 4');
    Writeln('PartA: ', PartA('..\..\AdventOfCode3.txt'));

    Assert(PartB('..\..\AdventOfCode3test.txt') = 3, 'PartB(test) <> 3');
    Writeln('PartB: ', PartB('..\..\AdventOfCode3.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
