program AdventOfCode13;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Generics.Collections,
  GpStreams, GpTextStream;

type
  TFirewallState = record
    Depth: integer;
    Range: integer;
    Direction: integer;
  end;
  TFirewalls = TArray<TFirewallState>;

function ReadFirewalls(const fileName: string): TFirewalls;
var
  kv : TArray<string>;
  num: integer;
  s  : string;
begin
  for s in EnumLines(AutoDestroyStream(SafeCreateFileStream(fileName, fmOpenRead)).Stream) do begin
    kv := s.Split([': ']);
    Assert(Length(kv) = 2);
    num := StrToInt(kv[0]);
    while Length(Result) < num do begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)].Depth := 0;
    end;
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)].Depth := StrToInt(kv[1]);
    Result[High(Result)].Range := 0;
    Result[High(Result)].Direction := 1;
  end;
end;

procedure IncrementFirewallState(var firewalls: TFirewalls; startAt: integer = 0);
var
  i: integer;
begin
  for i := startAt to High(firewalls) do
    if firewalls[i].Depth > 0 then begin
      firewalls[i].Range := firewalls[i].Range + firewalls[i].Direction;
      if firewalls[i].Range = 0 then
        firewalls[i].Direction := 1
      else if firewalls[i].Range = (firewalls[i].Depth - 1) then
        firewalls[i].Direction := -1;
    end;
end;

function PartA(const fileName: string): integer;
var
  firewalls: TFirewalls;
  pos      : integer;
begin
  Result := 0;
  firewalls := ReadFirewalls(fileName);
  for pos := Low(firewalls) to High(firewalls) do begin
    if (firewalls[pos].Depth > 0) and (firewalls[pos].Range = 0) then
      Inc(Result, pos * firewalls[pos].Depth);
    IncrementFirewallState(firewalls);
  end;
end;

function AnyInRange(const firewalls: TFirewalls; range: integer): boolean;
var
  pos: integer;
begin
  Result := false;
  for pos:= Low(firewalls) to High(firewalls) do
    if (firewalls[pos].Depth > 0) and (firewalls[pos].Range = 0) then
      Exit(true);
end;

function PartB(const fileName: string): integer;
var
  firewalls: TFirewalls;
  pos      : integer;
begin
  Result := 0;
  firewalls := ReadFirewalls(fileName);
  for pos := Low(firewalls)+1 to High(firewalls) do
    IncrementFirewallState(firewalls, pos);
  while AnyInRange(firewalls, 0) do begin
    Inc(Result);
    IncrementFirewallState(firewalls);
  end;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode13test.txt') = 24, 'PartA test failed');
    Assert(PartB('..\..\AdventOfCode13test.txt') = 10, 'PartB test failed');

    Writeln(PartA('..\..\AdventOfCode13.txt'));
    Writeln(PartB('..\..\AdventOfCode13.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
