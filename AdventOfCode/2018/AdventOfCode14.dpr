program AdventOfCode14;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Generics.Collections;

function PartA(prerun: integer): int64;
var
  elf1: integer;
  elf2: integer;
  i: integer;
  recipes: TList<integer>;
  sum: integer;

begin
  recipes := TList<integer>.Create;
  try
    recipes.Add(3);
    recipes.Add(7);
    elf1 := 0;
    elf2 := 1;
    while recipes.Count < (prerun + 10) do begin
      sum := recipes[elf1] + recipes[elf2];
      if (sum div 10) <> 0 then
        recipes.Add(sum div 10);
      recipes.Add(sum mod 10);
      elf1 := (elf1 + recipes[elf1] + 1) mod recipes.Count;
      elf2 := (elf2 + recipes[elf2] + 1) mod recipes.Count;
    end;

    Result := 0;
    for i := 1 to 10 do begin
      Result := Result * 10 + recipes[prerun];
      Inc(prerun);
    end;
  finally FreeAndNil(recipes); end;
end;

function PartB(const pattern: string): int64;
var
  elf1: integer;
  elf2: integer;
  i: integer;
  patInt: TArray<integer>;
  recipes: TList<integer>;
  sum: integer;

  function MatchesAtEnd: boolean;
  var
    i: integer;
  begin
    Result := false;
    if recipes.Count >= Length(patInt) then begin
      Result := true;
      for i := Low(patInt) to High(patInt) do
        if recipes[recipes.Count - Length(pattern) + i] <> patInt[i] then
          Exit(false);
    end;
  end;

begin
  SetLength(patInt, Length(pattern));
  for i := 1 to Length(pattern) do
    patInt[i-1] := Ord(pattern[i]) - Ord('0');

  recipes := TList<integer>.Create;
  try
    recipes.Add(3);
    recipes.Add(7);
    elf1 := 0;
    elf2 := 1;
    repeat
      sum := recipes[elf1] + recipes[elf2];
      if (sum div 10) <> 0 then begin
        recipes.Add(sum div 10);
        if MatchesAtEnd then
          Exit(recipes.Count - Length(pattern));
      end;

      recipes.Add(sum mod 10);
      if MatchesAtEnd then
        Exit(recipes.Count - Length(pattern));

      elf1 := (elf1 + recipes[elf1] + 1) mod recipes.Count;
      elf2 := (elf2 + recipes[elf2] + 1) mod recipes.Count;
    until false;
  finally FreeAndNil(recipes); end;
end;

begin
  try
    Assert(PartA(9) = 5158916779, 'PartA(9) <> 5158916779');
    Assert(PartA(5) = 0124515891, 'PartA(5) <> 0124515891');
    Assert(PartA(18) = 9251071085, 'PartA(18) <> 9251071085');
    Assert(PartA(2018) = 5941429882, 'PartA(2018) <> 5941429882');
    Writeln('PartA: ', PartA(306281));

    Assert(PartB('51589') = 9, 'PartB(51589) <> 9');
    Assert(PartB('01245') = 5, 'PartB(01245) <> 5');
    Assert(PartB('92510') = 18, 'PartB(92510) <> 18');
    Assert(PartB('59414') = 2018, 'PartB(59414) <> 2018');
    Writeln('PartB: ', PartB('306281'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln
end.
