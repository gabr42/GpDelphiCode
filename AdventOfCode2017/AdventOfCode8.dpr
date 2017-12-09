program AdventOfCode8;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Generics.Collections, System.RegularExpressions, System.Math,
  GpStreams, GpTextStream;

type
  TRegisters = class(TDictionary<string, integer>)
  public
    function Max: integer;
  end;

  TInstruction = class
  strict private
    FParser: TRegEx;
    FRegister: string;
    FIncrement: integer;
    FCondReg: string;
    FCondOper: string;
    FCondValue: integer;
  protected
    function Test(reg: TRegisters): boolean;
  public
    constructor Create;
    procedure Parse(const s: string);
    function Execute(reg: TRegisters): integer;
  end;

{ TRegisters }

function TRegisters.Max: integer;
var
  i: Integer;
begin
  Result := 0;
  for i in Values do
    if i > Result then
      Result := i;
end;

{ TInstruction }

constructor TInstruction.Create;
begin
  FParser := TRegEx.Create('([a-z]+)\s+(dec|inc)\s+([\-0-9]+)\s+if\s+([a-z]+)\s+([^\s]+)+\s+([\-0-9]+)', [roIgnoreCase]);
end;

function TInstruction.Execute(reg: TRegisters): integer;
var
  regValue: integer;
begin
  if Test(reg) then begin
    if not reg.TryGetValue(FRegister, regValue) then
      regValue := 0;
    Result := regValue + FIncrement;
    reg.AddOrSetValue(FRegister, Result);
  end;
end;

procedure TInstruction.Parse(const s: string);
var
  match: TMatch;
  mult : integer;
begin
  match := FParser.Match(s);
  if not match.Success then
    raise Exception.Create('Invalid input: ' + s);
  FRegister := match.Groups[1].Value;
  mult := 1;
  if SameText(match.Groups[2].Value, 'dec') then
    mult := -1;
  FIncrement := StrToInt(match.Groups[3].Value) * mult;
  FCondReg := match.Groups[4].Value;
  FCondOper := match.Groups[5].Value;
  FCondValue := StrToInt(match.Groups[6].Value);
end;

function TInstruction.Test(reg: TRegisters): boolean;
var
  regValue: integer;
begin
  if not reg.TryGetValue(FCondReg, regValue) then
    regValue := 0;
  if FCondOper = '==' then
    Result := regValue = FCondValue
  else if FCondOper = '!=' then
    Result := regValue <> FCondValue
  else if FCondOper = '<' then
    Result := regValue < FCondValue
  else if FCondOper = '<=' then
    Result := regValue <= FCondValue
  else if FCondOper = '>' then
    Result := regValue > FCondValue
  else if FCondOper = '>=' then
    Result := regValue >= FCondValue
  else
    raise Exception.Create('Invalid conditional test: ' + FCondOper);
end;

  function PartA(const fileName: string): integer;
  var
    inst: TInstruction;
    reg : TRegisters;
    s   : string;
  begin
    reg := TRegisters.Create;
    try
      inst := TInstruction.Create;
      try
        for s in EnumLines(AutoDestroyStream(SafeCreateFileStream(fileName, fmOpenRead)).Stream) do begin
          inst.Parse(s);
          inst.Execute(reg);
        end;
      finally FreeAndNil(inst); end;
      Result := reg.Max;
    finally FreeAndNil(reg); end;
  end;

  function PartB(const fileName: string): integer;
  var
    inst: TInstruction;
    reg : TRegisters;
    s   : string;
  begin
    Result := 0;
    reg := TRegisters.Create;
    try
      inst := TInstruction.Create;
      try
        for s in EnumLines(AutoDestroyStream(SafeCreateFileStream(fileName, fmOpenRead)).Stream) do begin
          inst.Parse(s);
          Result := Max(Result, inst.Execute(reg));
        end;
      finally FreeAndNil(inst); end;
    finally FreeAndNil(reg); end;
  end;

begin
  try
    Assert(PartA('..\..\AdventOfCode8test.txt') = 1, 'PartA test failed');
    Assert(PartB('..\..\AdventOfCode8test.txt') = 10, 'PartB test failed');

    Writeln(PartA('..\..\AdventOfCode8.txt'));
    Writeln(PartB('..\..\AdventOfCode8.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
