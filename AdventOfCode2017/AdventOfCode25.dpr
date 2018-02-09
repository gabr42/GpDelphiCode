program AdventOfCode25;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Generics.Collections;

type
  TStateValue = record
    State: char;
    Value: word;
    constructor Create(AState: char; AValue: byte);
  end;

  TOperation = record
    NewValue: byte;
    Move    : shortint;
    NewState: char;
    constructor Create(ANewValue: byte; AMove: shortint; ANewState: char);
  end;

  TTuringBase = class
  strict private
    FState       : char;
    FTransitions : TDictionary<TStateValue,TOperation>;
    FTapeZeroPlus: TList<byte>;
    FTapeMinus   : TList<byte>;
    FTapePosition: integer;
  strict protected
    function  GetTape: byte; inline;
    procedure SetTape(const value: byte); inline;
    property Tape: byte read GetTape write SetTape;
  public
    constructor Create; virtual;
    destructor  Destroy; override;
    function  Checksum: integer;
    procedure Define(state: char; newValue0: byte; move0: shortint; newState0: char;
                                  newValue1: byte; move1: shortint; newState1: char);
    procedure Run(numSteps: integer);
  end;

  TTuringClass = class of TTuringBase;

  TTuringTest = class(TTuringBase)
  public
    constructor Create; override;
  end;

  TTuring = class(TTuringBase)
  public
    constructor Create; override;
  end;

{ TStateValue }

constructor TStateValue.Create(AState: char; AValue: byte);
begin
  State := AState;
  Value := AValue;
end;

{ TOperation }

constructor TOperation.Create(ANewValue: byte; AMove: shortint; ANewState: char);
begin
  NewValue := ANewValue;
  Move := AMove;
  NewState := ANewState;
end;

{ TTuringBase }

constructor TTuringBase.Create;
begin
  inherited Create;
  FTransitions := TDictionary<TStateValue, TOperation>.Create;
  FTapeZeroPlus := TList<byte>.Create;
  FTapeMinus := TList<byte>.Create;
  FTapeZeroPlus.Add(0);
  FState := 'A';
  FTapePosition := 0;
end;

destructor TTuringBase.Destroy;
begin
  FreeAndNil(FTransitions);
  FreeAndNil(FTapeZeroPlus);
  FreeAndNil(FTapeMinus);
  inherited;
end;

function TTuringBase.Checksum: integer;
var
  b: byte;
begin
  Result := 0;
  for b in FTapeMinus do
    Result := Result + b;
  for b in FTapeZeroPlus do
    Result := Result + b;
end;

procedure TTuringBase.Define(state: char;
  newValue0: byte; move0: shortint; newState0: char;
  newValue1: byte; move1: shortint; newState1: char);
begin
  FTransitions.Add(TStateValue.Create(state, 0), TOperation.Create(newValue0, move0, newState0));
  FTransitions.Add(TStateValue.Create(state, 1), TOperation.Create(newValue1, move1, newState1));
end;

function TTuringBase.GetTape: byte;
begin
  if FTapePosition >= 0 then begin
    if FTapeZeroPlus.Count = FTapePosition then
      FTapeZeroPlus.Add(0);
    Result := FTapeZeroPlus[FTapePosition];
  end
  else begin
    if FTapeMinus.Count = (-FTapePosition - 1) then
      FTapeMinus.Add(0);
    Result := FTapeMinus[-FTapePosition - 1];
  end;
end;

procedure TTuringBase.Run(numSteps: integer);
var
  i : integer;
  op: TOperation;
begin
  for i := 1 to numSteps do begin
    op := FTransitions[TStateValue.Create(FState, Tape)];
    Tape := op.NewValue;
    FTapePosition := FTapePosition + op.Move;
    FState := op.NewState;
  end;
end;

procedure TTuringBase.SetTape(const value: byte);
begin
  if FTapePosition >= 0 then
    FTapeZeroPlus[FTapePosition] := value
  else
    FTapeMinus[-FTapePosition - 1] := value;
end;

{ TTuringTest }

constructor TTuringTest.Create;
begin
  inherited Create;
  Define('A', 1, +1, 'B', 0, -1, 'B');
  Define('B', 1, -1, 'A', 1, +1, 'A');
end;

{ TTuring }

constructor TTuring.Create;
begin
  inherited Create;
  Define('A', 1, +1, 'B', 0, -1, 'C');
  Define('B', 1, -1, 'A', 1, -1, 'D');
  Define('C', 1, +1, 'D', 0, +1, 'C');
  Define('D', 0, -1, 'B', 0, +1, 'E');
  Define('E', 1, +1, 'C', 1, -1, 'F');
  Define('F', 1, -1, 'E', 1, +1, 'A');
end;

{ globals }

function PartA(turingClass: TTuringClass; numSteps: integer): integer;
var
  turing: TTuringBase;
begin
  turing := turingClass.Create;
  try
    turing.Run(numSteps);
    Result := turing.Checksum;
  finally FreeAndNil(turing); end;
end;

begin
  try
    Assert(PartA(TTuringTest, 6) = 3);

    Writeln(PartA(TTuring, 12172063));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
