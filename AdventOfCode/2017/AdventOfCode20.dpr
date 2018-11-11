program AdventOfCode20;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Math,
  System.Generics.Defaults, System.Generics.Collections,
  GpStreams, GpTextStream;

type
  Vector3 = array [1..3] of integer;

  TParticleData = record
    ID      : integer;
    Position: Vector3;
    Velocity: Vector3;
    Accel   : Vector3;
  end;

  TParticles = class(TList<TParticleData>)
  strict protected
    function ParseParticle(const line: string): TParticleData;
    function ParseVector(const vect: string): Vector3;
    function Move(const part: TParticleData): TParticleData;
  public
    procedure LoadFromFile(const fileName: string);
    procedure MoveParticles;
    procedure RemoveCollisions;
    procedure SortByPosition;
  end;

function AbsVec(const vec: Vector3): integer;
begin
  Result := Abs(vec[1]) + Abs(vec[2]) + Abs(vec[3]);
end;

function SameVec(const vec1, vec2: Vector3): boolean;
begin
  Result := (vec1[1] = vec2[1]) and (vec1[2] = vec2[2]) and (vec1[3] = vec2[3]);
end;

function PartA(const fileName: string): integer;
var
  i   : integer;
  part: TParticles;
begin
  part := TParticles.Create;
  try
    part.LoadFromFile(fileName);
    // stupid approach, but it is simple and it works for this puzzle
    for i := 1 to 1000 do begin
      part.MoveParticles;
      part.SortByPosition;
    end;
    Result := part[0].ID;
  finally FreeAndNil(part); end;
end;

function PartB(const fileName: string): integer;
var
  i   : integer;
  part: TParticles;
begin
  part := TParticles.Create;
  try
    part.LoadFromFile(fileName);
    // stupid approach, but it is simple and it works for this puzzle
    for i := 1 to 1000 do begin
      part.MoveParticles;
      part.SortByPosition;
      part.RemoveCollisions;
    end;
    Result := part.Count;
  finally FreeAndNil(part); end;
end;

{ TParticles }

procedure TParticles.LoadFromFile(const fileName: string);
var
  id  : integer;
  line: string;
  part: TParticleData;
begin
  id := 0;
  for line in EnumLines(AutoDestroyStream(SafeCreateFileStream(fileName, fmOpenRead)).Stream) do
  begin
    part := ParseParticle(line);
    part.ID := id;
    Inc(id);
    Add(part);
  end;
end;

function TParticles.Move(const part: TParticleData): TParticleData;
var
  i: integer;
begin
  Result := part;
  for i := 1 to 3 do
    Result.Velocity[i] := Result.Velocity[i] + Result.Accel[i];
  for i := 1 to 3 do
    Result.Position[i] := Result.Position[i] + Result.Velocity[i];
end;

procedure TParticles.MoveParticles;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i] := Move(Items[i]);
end;

function TParticles.ParseParticle(const line: string): TParticleData;
var
  parts: TArray<string>;
begin
  parts := line.Split([', ']);
  Result.Position := ParseVector(parts[0]);
  Result.Velocity := ParseVector(parts[1]);
  Result.Accel := ParseVector(parts[2]);
end;

function TParticles.ParseVector(const vect: string): Vector3;
var
  parts: TArray<string>;
begin
  parts := vect.Substring(3).Split([',', '>']);
  Result[1] := parts[0].Trim.ToInteger;
  Result[2] := parts[1].Trim.ToInteger;
  Result[3] := parts[2].Trim.ToInteger;
end;

procedure TParticles.RemoveCollisions;
var
  badPos: TList<Vector3>;
  i: integer;
begin
  badPos := TList<Vector3>.Create;
  try
    for i := Count - 1 downto 1 do
      if SameVec(Items[i-1].Position, Items[i].Position) then
        badPos.Add(Items[i].Position);
    for i := Count - 1 downto 0 do
      if badPos.IndexOf(Items[i].Position) >= 0 then
        Delete(i);
  finally FreeAndNil(badPos); end;
end;

procedure TParticles.SortByPosition;
begin
  Sort(TComparer<TParticleData>.Construct(
    function (const Left, Right: TParticleData): integer
    begin
      Result := Comparevalue(AbsVec(Left.Position), AbsVec(Right.Position));
    end));
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode20testA.txt') = 0, 'PartA test failed');
    Assert(PartB('..\..\AdventOfCode20testB.txt') = 1, 'PartB test failed');

    Writeln(PartA('..\..\AdventOfCode20.txt'));
    Writeln(PartB('..\..\AdventOfCode20.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
