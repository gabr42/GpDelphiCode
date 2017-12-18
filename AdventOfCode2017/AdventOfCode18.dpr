program AdventOfCode18;

{$APPTYPE CONSOLE}

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
  strict private
    FRecovered: integer;
    FSound    : int64;
  strict protected
    FIP       : integer;
    FProgram  : TList<TInstruction>;
    FRegisters: array ['a'..'z'] of int64;
    procedure Execute(const instr: TInstruction); virtual;
    function Value(const regVal: string): int64;
  public
    constructor Create(const fileName: string);
    destructor Destroy; override;
    function Run: int64;
  end;

  TCPU2 = class(TCPU)
  strict private
    FIsReceiveWait: boolean;
    FIsTerminated : boolean;
    FReceiveFrom  : TList<integer>;
    FQueue        : TList<integer>;
    FSendCount    : integer;
  strict protected
    procedure Execute(const instr: TInstruction); override;
  public
    constructor Create(const fileName: string; id: integer);
    destructor Destroy; override;
    procedure Step;
    property Queue: TList<integer> read FQueue;
    property ReceiveFrom: TList<integer> read FReceiveFrom write FReceiveFrom;
    property SendCount: integer read FSendCount;
    property IsReceiveWait: boolean read FIsReceiveWait;
    property IsTerminated: boolean read FIsTerminated;
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

function PartB(const fileName: string): integer;
var
  cpu0: TCPU2;
  cpu1: TCPU2;
begin
  cpu0 := TCPU2.Create(fileName, 0);
  try
    cpu1 := TCPU2.Create(fileName, 1);
    try
      cpu0.ReceiveFrom := cpu1.Queue;
      cpu1.ReceiveFrom := cpu0.Queue;
      repeat
        cpu0.Step;
        cpu1.Step;
      until (cpu0.IsTerminated and cpu1.IsTerminated) or
            (cpu0.IsReceiveWait and cpu1.IsReceiveWait);
      Result := cpu1.SendCount;
    finally FreeAndNil(cpu1); end;
  finally FreeAndNil(cpu0); end;
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
  if instr.Inst = 'snd' then
    FSound := Value(instr.Reg)
  else if instr.Inst = 'set' then
    FRegisters[instr.Reg[1]] := Value(instr.Val)
  else if instr.Inst = 'add' then
    FRegisters[instr.Reg[1]] := FRegisters[instr.Reg[1]] + Value(instr.Val)
  else if instr.Inst = 'mul' then
    FRegisters[instr.Reg[1]] := FRegisters[instr.Reg[1]] * Value(instr.Val)
  else if instr.Inst = 'mod' then
    FRegisters[instr.Reg[1]] := FRegisters[instr.Reg[1]] mod Value(instr.Val)
  else if instr.Inst = 'rcv' then begin
    if Value(instr.Reg) <> 0 then
      FRecovered := FSound;
  end
  else if instr.Inst = 'jgz' then begin
    if Value(instr.Reg) > 0 then
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
  until (instr.Inst = 'rcv') and (Value(instr.Reg) <> 0);
  Result := FRecovered;
end;

function TCPU.Value(const regVal: string): int64;
begin
  if regVal[1] in ['a'..'z'] then
    Result := FRegisters[regVal[1]]
  else
    Result := StrToInt64(regVal);
end;

{ TCPU2 }

constructor TCPU2.Create(const fileName: string; id: integer);
begin
  inherited Create(fileName);
  FQueue := TList<integer>.Create;
  FRegisters['p'] := id;
end;

destructor TCPU2.Destroy;
begin
  FreeAndNil(FQueue);
  inherited;
end;

procedure TCPU2.Execute(const instr: TInstruction);
begin
  if instr.Inst = 'snd' then begin
    Inc(FSendCount);
    FQueue.Add(Value(instr.Reg));
    Inc(FIP);
  end
  else if instr.Inst = 'rcv' then begin
    FIsReceiveWait := (FReceiveFrom.Count = 0);
    if not FIsReceiveWait then begin
      FRegisters[instr.Reg[1]] := FReceiveFrom[0];
      FReceiveFrom.Delete(0);
      Inc(FIP);
    end
    else
      sleep(0);
  end
  else
    inherited;
end;

procedure TCPU2.Step;
begin
  if IsTerminated then
    Exit;
  Execute(FProgram[FIP]);
  FIsTerminated := (FIP < 0) or (FIP >= FProgram.Count);
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode18testA.txt') = 4, 'PartA test failed');
    Assert(PartB('..\..\AdventOfCode18testB.txt') = 3, 'PartB test failed');

    Writeln(PartA('..\..\AdventOfCode18.txt'));
    Writeln(PartB('..\..\AdventOfCode18.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
