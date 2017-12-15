program AdventOfCode14;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes,
  GpStuff;

procedure Reverse(var list: TArray<integer>; position, segmentLength: integer);
var
  i      : integer;
  last   : integer;
  listLen: integer;
  tmp    : integer;
begin
  listLen := Length(list);
  last := position + segmentLength - 1;
  for i := position to position + (segmentLength div 2) - 1 do begin
    tmp := list[i mod listLen];
    list[i mod listLen] := list[last mod listLen];
    list[last mod listLen] := tmp;
    Dec(last);
  end;
end;
procedure OneRound(var list: TArray<integer>; var position, skip: integer;
  const lengths: TArray<integer>);
var
  i: integer;
begin
  for i := 0 to Length(lengths) - 1 do begin
    Reverse(list, position, lengths[i]);
    position := (position + lengths[i] + skip) mod Length(list);
    Inc(skip);
  end;
end;

function HashKnot(const s: string): string;
var
  i       : integer;
  lenghts : TArray<integer>;
  list    : TArray<integer>;
  position: integer;
  round   : integer;
  skip    : integer;
  xors    : array [0..15] of integer;
begin
  SetLength(list, 256);
  for i := 0 to 255 do
    list[i] := i;
  SetLength(lenghts, Length(s) + 5);
  for i := 1 to Length(s) do
    lenghts[i-1] := Ord(s[i]);
  i := Length(s);
  lenghts[i] := 17; lenghts[i+1] := 31; lenghts[i+2] := 73; lenghts[i+3] := 47; lenghts[i+4] := 23;
  position := 0;
  skip := 0;
  for round := 1 to 64 do
    OneRound(list, position, skip, lenghts);
  FillChar(xors, SizeOf(xors), 0);
  for i := 0 to 255 do
    xors[i div 16] := xors[i div 16] XOR list[i];
  Result := '';
  for i := 0 to 15 do
    Result := Result + LowerCase(Format('%.2x', [xors[i]]));
end;

function CountBits(const hex: string): integer;
var
  ch: string;
  i : integer;
  nb: byte;
begin
  Result := 0;
  for ch in hex do begin
    nb := StrToInt('$' + ch);
    for i := 1 to 4 do begin
      if Odd(nb) then
        Inc(Result);
      nb := nb SHR 1;
    end;
  end;
end;

function PartA(const key: string): integer;
var
  i: integer;
  s: string;
begin
  Result := 0;
  for i := 0 to 127 do begin
    s := HashKnot(key + '-' + IntToStr(i));
    Inc(Result, CountBits(s));
  end;
end;

type
  TField = array [0..127, 0..127] of integer;

procedure FillLine(var field: TField; line: integer; const hex: string);
var
  ch : char;
  col: integer;
  i  : integer;
  nb : integer;
begin
  col := 0;
  for ch in hex do begin
    nb := StrToInt('$' + ch);
    for i := 1 to 4 do begin
      field[line,col] := IFF((nb AND 8) = 8, -1, 0);
      nb := nb SHL 1;
      Inc(col);
    end;
  end;
end;

procedure FillRegion(var field: TField; i, j, id: integer);
begin
  if (i < 0) or (i > 127) or (j < 0) or (j > 127) or (field[i,j] <> -1) then
    Exit;
  field[i,j] := id;
  FillRegion(field, i-1, j, id);
  FillRegion(field, i+1, j, id);
  FillRegion(field, i, j-1, id);
  FillRegion(field, i, j+1, id);
end;

function CountRegions(field: TField): integer;
var
  i,j: integer;
begin
  Result := 0;
  for i := 0 to 127 do
    for j := 0 to 127 do
      if field[i,j] = -1 then begin
        Inc(Result);
        FillRegion(field, i, j, Result);
      end;
end;

function PartB(const key: string): integer;
var
  field: TField;
  i    : integer;
  s    : string;
begin
  Result := 0;
  for i := 0 to 127 do begin
    s := HashKnot(key + '-' + IntToStr(i));
    FillLine(field, i, s);
  end;
  Result := CountRegions(field);
end;

begin
  try
    Assert(HashKnot('AoC 2017') = '33efeb34ea91902bb2f59c9920caa6cd', 'HashKnot test failed');
    Assert(PartA('flqrgnkx') = 8108, 'PartA test failed');
    Assert(PartB('flqrgnkx') = 1242, 'PartB test failed');

    Writeln(PartA('hfdlxzhv'));
    Writeln(PartB('hfdlxzhv'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
