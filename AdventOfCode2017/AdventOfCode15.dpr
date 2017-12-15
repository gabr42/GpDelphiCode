program AdventOfCode15;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

function GenA(val: cardinal): cardinal; inline;
begin
  Result := int64(val) * 16807 mod 2147483647;
end;

function GenB(val: cardinal): cardinal; inline;
begin
  Result := int64(val) * 48271 mod 2147483647;
end;

function PartA(startA, startB: cardinal): cardinal;
var
  i: cardinal;
begin
  Result := 0;
  for i := 1 to 40000000 do begin
    startA := GenA(startA);
    startB := GenB(startB);
    if LongRec(startA).Lo = LongRec(startB).Lo then
      Inc(Result);
  end;
end;

function GenA4(val: cardinal): cardinal; inline;
begin
  repeat
    val := GenA(val);
  until (val AND 3) = 0;
  Result := val;
end;

function GenB8(val: cardinal): cardinal; inline;
begin
  repeat
    val := GenB(val);
  until (val and 7) = 0;
  Result := val;
end;

function PartB(startA, startB: cardinal): cardinal;
var
  i: cardinal;
begin
  Result := 0;
  for i := 1 to 5000000 do begin
    startA := GenA4(startA);
    startB := GenB8(startB);
    if LongRec(startA).Lo = LongRec(startB).Lo then
      Inc(Result);
  end;
end;

begin
  try
    Assert(PartA(65, 8921) = 588);
    Assert(PartB(65, 8921) = 309);

    Writeln(PartA(883, 879));
    Writeln(PartB(883, 879));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
