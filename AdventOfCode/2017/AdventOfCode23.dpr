program AdventOfCode23;

{$APPTYPE CONSOLE}
{$OPTIMIZATION ON}

{$R *.res}

uses
  System.SysUtils, System.Generics.Collections,
  GpStreams, GpTextStream;

type
  TInstruction = record
    Inst: string;
    Reg : string;
    Val : string;
  end;

  TCPU = class
  strict protected
    FIP       : integer;
    FMulCount : integer;
    FProgram  : TList<TInstruction>;
    FRegisters: array ['a'..'z'] of int64;
    procedure Execute(const instr: TInstruction); virtual;
    function Value(const regVal: string): int64;
  public
    constructor Create(const fileName: string);
    destructor Destroy; override;
    function Run: int64;
  end;

function PartA(const fileName: string): integer;
var
  cpu: TCPU;
begin
  cpu := TCPU.Create(fileName);
  try
    Result := cpu.Run;
  finally FreeAndNil(cpu); end;
end;

function PartB: integer;
var
  a,b,c,d,e,f,g,h: int64;

  function IsPrime(num: integer): boolean;
  var
    i: integer;
  begin
    Result := true;
    for i := 2 to Round(Sqrt(num)) do
      if (num mod i) = 0 then
        Exit(false);
//    Result := f;
//    repeat
//      e := 2;
//      repeat
//        if d * e = b then
//          Exit(0);
//        e := e + 1;
//        g := e - b;
//      until g = 0;
//      d := d + 1;
//      g := d - b;
//    until g = 0;
  end;

begin
  a := 1;
  h := 0;
  b := 65;
  c := b;
  if a <> 0 then begin
    b := b * 100 + 100000;
    c := b + 17000;
  end;
  while true do begin
    f := 1;
    d := 2;
    if not IsPrime(b) then
      h := h + 1;
    g := b - c;
    if g = 0 then
      Exit(h);
    b := b + 17;
  end;
end;

{ TCPU }

constructor TCPU.Create(const fileName: string);
var
  instr: TInstruction;
  line : string;
  parts: TArray<string>;
begin
  inherited Create;
  FProgram := TList<TInstruction>.Create;
  for line in EnumLines(AutoDestroyStream(SafeCreateFileStream(fileName, fmOpenRead)).Stream) do
  begin
    parts := line.Split([' ']);
    instr.Inst := parts[0];
    instr.Reg := parts[1];
    if High(parts) > 1 then
      instr.Val := parts[2]
    else
      instr.Val := '';
    FProgram.Add(instr);
  end;
end;

destructor TCPU.Destroy;
begin
  FreeAndNil(FProgram);
  inherited;
end;

procedure TCPU.Execute(const instr: TInstruction);
begin
  if instr.Inst = 'set' then
    FRegisters[instr.Reg[1]] := Value(instr.Val)
  else if instr.Inst = 'sub' then
    FRegisters[instr.Reg[1]] := FRegisters[instr.Reg[1]] - Value(instr.Val)
  else if instr.Inst = 'mul' then begin
    FRegisters[instr.Reg[1]] := FRegisters[instr.Reg[1]] * Value(instr.Val);
    Inc(FMulCount);
  end
  else if instr.Inst = 'jnz' then begin
    if Value(instr.Reg) <> 0 then
      FIP := FIP + Value(instr.Val) - 1 {compensate};
  end
  else
    raise Exception.Create('Invalid instruction ' + instr.Inst);
  Inc(FIP);
end;

function TCPU.Run: int64;
var
  instr: TInstruction;
begin
  FIP := 0;
  FillChar(FRegisters, SizeOf(FRegisters), 0);
  repeat
    instr := FProgram[FIP];
    Execute(instr);
  until (FIP < 0) or (FIP >= FProgram.Count);
  Result := FMulCount;
end;

function TCPU.Value(const regVal: string): int64;
begin
  if regVal[1] in ['a'..'z'] then
    Result := FRegisters[regVal[1]]
  else
    Result := StrToInt64(regVal);
end;

begin
  try
    Writeln(PartA('..\..\AdventOfCode23.txt'));
    Writeln(PartB);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
