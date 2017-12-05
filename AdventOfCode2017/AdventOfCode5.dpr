program AdventOfCode5;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Generics.Collections,
  GpStreams,
  GpTextStream;

function LoadJumps(const fileName: string): TArray<integer>;
var
  jumps: TList<integer>;
  sJump: string;
begin
  jumps := TList<integer>.Create;
  try
    for sJump in EnumLines(AutoDestroyStream(SafeCreateFileStream(fileName, fmOpenRead)).Stream) do
      jumps.Add(StrToInt(sJump));
    Result := jumps.ToArray;
  finally FreeAndNil(jumps); end;
end;

function PartA(const jumps: TArray<integer>): integer;
var
  ip: integer;
begin
  Result := 0;
  ip := 0;
  while (ip >= Low(jumps)) and (ip <= High(jumps)) do begin
    jumps[ip] := jumps[ip] + 1;
    ip := ip + jumps[ip] - 1;
    Inc(Result);
  end;
end;

function PartB(const jumps: TArray<integer>): integer;
var
  ip: integer;
  newIp: integer;
begin
  Result := 0;
  ip := 0;
  while (ip >= Low(jumps)) and (ip <= High(jumps)) do begin
    newIp := ip + jumps[ip];
    if jumps[ip] >= 3 then
      jumps[ip] := jumps[ip] - 1
    else
      jumps[ip] := jumps[ip] + 1;
    ip := newIp;
    Inc(Result);
  end;
end;

begin
  try
    Assert(PartA(TArray<integer>.Create(0, 3, 0, 1, -3)) = 5, 'PartA test <> 5');
    Assert(PartB(TArray<integer>.Create(0, 3, 0, 1, -3)) = 10, 'PartB test <> 10');

    Writeln('PartA: ', PartA(LoadJumps('..\..\AdventOfCode5.txt')));
    Writeln('PartB: ', PartB(LoadJumps('..\..\AdventOfCode5.txt')));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
