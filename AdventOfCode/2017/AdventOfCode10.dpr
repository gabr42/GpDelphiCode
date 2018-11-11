program AdventOfCode10;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Generics.Collections;

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

function PartA(maxElement: integer; const lengths: TArray<integer>): integer;
var
  i       : Integer;
  list    : TArray<integer>;
  position: integer;
  skip    : Integer;
begin
  SetLength(list, maxElement+1);
  for i := 0 to maxElement do
    list[i] := i;
  position := 0;
  skip := 0;
  OneRound(list, position, skip, lengths);
  Result := list[0] * list[1];
end;

function PartB(const s: string): string;
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

begin
  try
    Assert(PartA(4, TArray<integer>.Create(3, 4, 1, 5)) = 12, 'PartA test failed');
    Assert(PartB('') = 'a2582a3a0e66e6e86e3812dcb672a272', 'PartB test #1 failed');
    Assert(PartB('AoC 2017') = '33efeb34ea91902bb2f59c9920caa6cd', 'PartB test #2 failed');
    Assert(PartB('1,2,3') = '3efbe78a8d82f29979031a4aa0b16a9d', 'PartB test #3 failed');
    Assert(PartB('1,2,4') = '63960835bcdc130f0b66d7ff4f6a5a8e', 'PartB test #4 failed');

    Writeln(PartA(255, TArray<integer>.Create(102,255,99,252,200,24,219,57,103,2,226,254,1,0,69,216)));
    Writeln(PartB('102,255,99,252,200,24,219,57,103,2,226,254,1,0,69,216'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
