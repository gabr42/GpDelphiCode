program AdventOfCode16;

{$APPTYPE CONSOLE}
{$RANGECHECKS ON}

{$R *.res}

uses
  System.SysUtils,
  System.Math,
  System.Classes,
  System.Generics.Collections;

type
  TTemplate = TProc<integer,integer,integer>;
  TInstruction = record
    Name: string;
    Sig : string;
    Exec: TTemplate;
  end;

  TInstructions = set of 0..15;

  TCPU = class
  strict private
    FRegisters: array [0..3] of integer;
    FInstructions: TList<TInstruction>;
  strict protected
    function CanHandle(const signature: string; inst: TArray<integer>): boolean;
    function CompareRegisters(const regs: TArray<integer>): boolean;
    procedure DefineInstruction(const name, signature: string; exec: TTemplate);
    function GetRegister(idx: integer): integer;
    procedure SetRegisters(const regs: TArray<integer>);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute(inst: TArray<integer>);
    function PossibleInstructions(const regsIn, inst, regsOut: TArray<integer>): TInstructions;
    function WaysToExecute(const regsIn, inst, regsOut: TArray<integer>): integer;
    property Register[idx: integer]: integer read GetRegister;
  end;

{ TCPU }

constructor TCPU.Create;
begin
  inherited Create;
  FInstructions := TList<TInstruction>.Create;
  DefineInstruction('addr', 'rrr', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] + FRegisters[b]; end);
  DefineInstruction('addi', 'rir', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] + b; end);
  DefineInstruction('mulr', 'rrr', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] * FRegisters[b]; end);
  DefineInstruction('muli', 'rir', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] * b; end);
  DefineInstruction('banr', 'rrr', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] AND FRegisters[b]; end);
  DefineInstruction('bani', 'rir', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] AND b; end);
  DefineInstruction('borr', 'rrr', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] OR FRegisters[b]; end);
  DefineInstruction('bori', 'rir', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a] OR b; end);
  DefineInstruction('setr', 'rxr', procedure (a, b, c: integer) begin FRegisters[c] := FRegisters[a]; end);
  DefineInstruction('seti', 'ixr', procedure (a, b, c: integer) begin FRegisters[c] := a; end);
  DefineInstruction('gtir', 'irr', procedure (a, b, c: integer) begin FRegisters[c] := IfThen(a > FRegisters[b], 1, 0); end);
  DefineInstruction('gtri', 'rir', procedure (a, b, c: integer) begin FRegisters[c] := IfThen(FRegisters[a] > b, 1, 0); end);
  DefineInstruction('gtrr', 'rrr', procedure (a, b, c: integer) begin FRegisters[c] := IfThen(FRegisters[a] > FRegisters[b], 1, 0); end);
  DefineInstruction('eqir', 'irr', procedure (a, b, c: integer) begin FRegisters[c] := IfThen(a = FRegisters[b], 1, 0); end);
  DefineInstruction('eqri', 'rir', procedure (a, b, c: integer) begin FRegisters[c] := IfThen(FRegisters[a] = b, 1, 0); end);
  DefineInstruction('eqrr', 'rrr', procedure (a, b, c: integer) begin FRegisters[c] := IfThen(FRegisters[a] = FRegisters[b], 1, 0); end);
end;

destructor TCPU.Destroy;
begin
  FreeAndNil(FInstructions);
  inherited;
end;

function TCPU.CanHandle(const signature: string;
  inst: TArray<integer>): boolean;
var
  i: integer;
begin
  Result := true;
  for i := 1 to 3 do
    if (signature[i] = 'r') and (not (inst[i] in [0..3])) then
      Exit(false);
end;

function TCPU.CompareRegisters(const regs: TArray<integer>): boolean;
var
  i: Integer;
begin
  Result := true;
  for i := 0 to 3 do
    if FRegisters[i] <> regs[i] then
      Exit(false);
end;

procedure TCPU.DefineInstruction(const name, signature: string; exec: TTemplate);
var
  inst: TInstruction;
begin
  inst.Name := name;
  inst.Sig := signature;
  inst.Exec := exec;
  FInstructions.Add(inst);
end;

procedure TCPU.Execute(inst: TArray<integer>);
begin
  FInstructions[inst[0]].Exec(inst[1], inst[2], inst[3]);
end;

function TCPU.GetRegister(idx: integer): integer;
begin
  Result := FRegisters[idx];
end;

function TCPU.PossibleInstructions(const regsIn, inst,
  regsOut: TArray<integer>): TInstructions;
var
  i: integer;
  instruction: TInstruction;
begin
  Result := [];
  for i := 0 to 15 do begin
    instruction := FInstructions[i];
    if CanHandle(instruction.Sig, inst) then begin
      SetRegisters(regsIn);
      instruction.Exec(inst[1], inst[2], inst[3]);
      if CompareRegisters(regsOut) then
        Include(Result, i);
    end;
  end;
end;

procedure TCPU.SetRegisters(const regs: TArray<integer>);
var
  i: integer;
begin
  for i := 0 to 3 do
    FRegisters[i] := regs[i];
end;

function TCPU.WaysToExecute(const regsIn, inst,
  regsOut: TArray<integer>): integer;
var
  i: integer;
  insts: TInstructions;
begin
  insts := PossibleInstructions(regsIn, inst, regsOut);
  Result := 0;
  for i := 0 to 15 do
    if i in insts then
      Inc(Result);
end;

{ main }

function ToIntArray(const s: string): TArray<integer>;
var
  i: integer;
  sParts: TArray<string>;
begin
  // accepts: "[3, 2, 1, 1]" and "9 2 1 2"
  sParts := s.Trim.Replace('[', '', []).Replace(']', '', []).Split([', ', ' ']);
  SetLength(Result, Length(sParts));
  for i := Low(sParts) to High(sParts) do
    Result[i] := sParts[i].ToInteger;
end;

function PartA(const fileName: string): integer;
var
  cpu: TCPU;
  inst: TArray<integer>;
  reader: TStreamReader;
  regs: TArray<integer>;
  ways: integer;
begin
  Result := 0;
  reader := TStreamReader.Create(fileName);
  try
    cpu := TCPU.Create;
    try
      while not reader.EndOfStream do begin
        regs := ToIntArray(reader.ReadLine.Split([':'])[1]);
        inst := ToIntArray(reader.ReadLine);
        ways := cpu.WaysToExecute(regs, inst, ToIntArray(reader.ReadLine.Split([':'])[1]));
        if ways >= 3 then
          Inc(Result);
        reader.ReadLine;
      end;
    finally FreeAndNil(cpu); end;
  finally FreeAndNil(reader); end;
end;

function IsSingleton(insts: TInstructions; var inst: integer): boolean;
var
  i: integer;
begin
  Result := true;
  inst := -1;
  for i := 0 to 15 do
    if i in insts then
      if inst < 0 then
        inst := i
      else
        Exit(false);
end;

function PartB(const fileNameSamples, fileNameCode: string): integer;
var
  cpu: TCPU;
  i: integer;
  inst: TArray<integer>;
  instMap: array [0..15] of integer;
  potentials: array [0..15] of TInstructions;
  reader: TStreamReader;
  regs: TArray<integer>;

  procedure SimplifyPotentials;
  var
    any: boolean;
    val: integer;
    i,j: integer;
  begin
    repeat
      any := false;
      for i := 0 to 15 do
        if IsSingleton(potentials[i], val) then
          for j := 0 to 15 do
            if i <> j then begin
              if val in potentials[j] then begin
                potentials[j] := potentials[j] - [val];
                any := true;
              end;
            end;
    until not any;

    for i := 0 to 15 do
      if not IsSingleton(potentials[i], j) then
        raise Exception.Create('Bad mapping!')
      else
        instMap[i] := j;
  end;

begin
  for i := 0 to 15 do
    potentials[i] := [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];

  reader := TStreamReader.Create(fileNameSamples);
  try
    cpu := TCPU.Create;
    try
      while not reader.EndOfStream do begin
        regs := ToIntArray(reader.ReadLine.Split([':'])[1]);
        inst := ToIntArray(reader.ReadLine);
        potentials[inst[0]] :=
          potentials[inst[0]] *
          cpu.PossibleInstructions(regs, inst, ToIntArray(reader.ReadLine.Split([':'])[1]));
        reader.ReadLine;
      end;
    finally FreeAndNil(cpu); end;
  finally FreeAndNil(reader); end;
  
  SimplifyPotentials;

  reader := TStreamReader.Create(fileNameCode);
  try
    cpu := TCPU.Create;
    try
      while not reader.EndOfStream do begin
        inst := ToIntArray(reader.ReadLine);
        inst[0] := instMap[inst[0]];
        cpu.Execute(inst);
      end;
      Result := cpu.Register[0];
    finally FreeAndNil(cpu); end;
  finally FreeAndNil(reader); end;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode16test.txt') = 1, 'PartA(test) <> 1');
    Writeln('PartA: ', PartA('..\..\AdventOfCode16samples.txt'));

    Writeln('PartB: ', PartB('..\..\AdventOfCode16samples.txt', '..\..\AdventOfCode16code.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
