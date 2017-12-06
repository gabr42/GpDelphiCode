program AdventOfCode6;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Generics.Collections;

type
  TMemoryBanks = TArray<integer>;

  function FindMaximumBank(const memory: TMemoryBanks): integer;
  var
    i: integer;
  begin
    Result := Low(memory);
    for i := Low(memory) + 1 to High(memory) do
      if memory[i] > memory[Result] then
        Result := i;
  end;

  procedure Redistribute(var memory: TMemoryBanks; idx: integer);
  var
    num: integer;
  begin
    num := memory[idx];
    memory[idx] := 0;
    while num > 0 do begin
      idx := (idx + 1) mod Length(memory);
      memory[idx] := memory[idx] + 1;
      Dec(num);
    end;
  end;

  function PartA(memory: TMemoryBanks): integer;
  var
    states: TDictionary<TMemoryBanks,boolean>;
  begin
    Result := 0;
    states := TDictionary<TMemoryBanks,boolean>.Create;
    try
      try
        repeat
          states.Add(memory, true);
          Inc(Result);
          Redistribute(memory, FindMaximumBank(memory));
        until false;
      except
        on E: EListError do
          ; //duplicate found, exit
      end;
    finally FreeAndNil(states); end;
  end;

  function PartB(memory: TMemoryBanks): integer;
  var
    idx   : integer;
    states: TDictionary<TMemoryBanks,integer>;
  begin
    Result := 0;
    states := TDictionary<TMemoryBanks,integer>.Create;
    try
      try
        repeat
          Inc(Result);
          if states.TryGetValue(memory, idx) then
            Exit(Result - idx)
          else
            states.Add(memory, Result);
          Redistribute(memory, FindMaximumBank(memory));
        until false;
      except
        on E: EListError do
          ; //duplicate found, exit
      end;
    finally FreeAndNil(states); end;
  end;

var
  puzzle: TMemoryBanks;

begin
  try
    Assert(PartA(TMemoryBanks.Create(0, 2, 7, 0)) = 5, 'PartA test failed');
    Assert(PartB(TMemoryBanks.Create(0, 2, 7, 0)) = 4, 'PartB test failed');

    puzzle := TMemoryBanks.Create(4, 1, 15, 12, 0, 9, 9, 5, 5, 8, 7, 3, 14, 5, 12, 3);
    Writeln('PartA: ', PartA(puzzle));

    puzzle := TMemoryBanks.Create(4, 1, 15, 12, 0, 9, 9, 5, 5, 8, 7, 3, 14, 5, 12, 3);
    Writeln('PartB: ', PartB(puzzle));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
