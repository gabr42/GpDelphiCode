program AdventOfCode10;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Types,
  System.SysUtils,
  System.Classes,
  System.Generics.Defaults,
  System.Generics.Collections;

type
  TLight = record
    X, Y, dX, dY: integer;
    constructor Create(AX, AY, AdX, AdY: integer);
  end;
  TLights = TArray<TLight>;
  TLine = TArray<integer>;

constructor TLight.Create(AX, AY, AdX, AdY: integer);
begin
  X := AX;
  Y := AY;
  dX := AdX;
  dY := AdY;
end;

function LoadLights(const fileName: string): TLights;
var
  lights: TList<TLight>;
  parts : TArray<string>;
  reader: TStreamReader;
  s     : string;
begin
  lights := TList<TLight>.Create;
  try
    reader := TStreamReader.Create(fileName);
    try
      while not reader.EndOfStream do begin
        s := reader.ReadLine;
        if Trim(s) = '' then
          continue;
        parts := s.Replace(' ', '', [rfReplaceAll]).Split(['<', ',', '>']);
        lights.Add(TLight.Create(parts[1].ToInteger, parts[2].ToInteger,
                                 parts[4].ToInteger, parts[5].ToInteger));
      end;
    finally FreeAndNil(reader); end;
    Result := lights.ToArray;
  finally FreeAndNil(lights); end;
end;

function AdvanceLights(const lights: TLights): TLights;
var
  i: integer;
begin
  SetLength(Result, Length(lights));
  for i := Low(lights) to High(lights) do
    Result[i] := TLight.Create(lights[i].X + lights[i].dX,
                               lights[i].Y + lights[i].dY,
                               lights[i].dX, lights[i].dY);
end;

function Rect(const lights: TLights): TRect;
var
  light: TLight;
  max  : TRect;
begin
  max := System.Types.Rect(lights[Low(lights)].X, lights[Low(lights)].Y,
                           lights[Low(lights)].X, lights[Low(lights)].Y);
  for light in lights do begin
    if light.X < max.Left then
      max.Left := light.X;
    if light.X > max.Right then
      max.Right := light.X;
    if light.Y < max.Top then
      max.Top := light.Y;
    if light.Y > max.Bottom then
      max.Bottom := light.Y;
  end;
  Result := max;
end;

function IsSmaller(const rect1, rect2: TRect): boolean;
begin
  Result := (rect1.Width * rect1.Height) < (rect2.Width * rect2.Height);
end;

function GetLine(const lights: TLights; y: integer): TLine;
var
  iOut : integer;
  light: TLight;
  line : TList<integer>;
  x    : integer;
begin
  line := TList<integer>.Create;
  try
    for light in lights do
      if light.Y = y then
        line.Add(light.X);
    line.Sort;
    SetLength(Result, line.Count);
    iOut := 0;
    for x in line do begin
      if (iOut = 0) or (Result[iOut-1] < x) then begin
        Result[iOut] := x;
        Inc(iOut);
      end;
    end;
    SetLength(Result, iOut);
  finally FreeAndNil(line); end;
end;

procedure ShowLights(const lights: TLights);
var
  iLine: integer;
  line : TLine;
  r    : TRect;
  x    : integer;
  y    : integer;
begin
  r := Rect(lights);
  for y := r.Top to r.Bottom do begin
    line := GetLine(lights, y);
    iLine := 0;
    for x := r.Left to r.Right do begin
      if iLine > High(line) then
        break; //for x
      if x = line[iLine] then begin
        Write('*');
        Inc(iLine);
      end
      else
       Write(' ');
    end;
    Writeln;
  end;
end;

function PartA(const fileName: string): integer;
var
  lights   : TLights;
  newLights: TLights;
  newRect  : TRect;
  oldRect  : TRect;
begin
  Result := -1;
  lights := LoadLights(fileName);
  oldRect := Rect(lights);
  repeat
    Inc(Result);
    newLights := AdvanceLights(lights);
    newRect := Rect(newLights);
    if (oldRect.Width < 100) and IsSmaller(oldRect, newRect) then
      break; //repeat
    lights := newLights;
    oldRect := newRect;
  until false;
  ShowLights(lights);
end;

var
  sec: integer;

begin
  try
    Assert(PartA('..\..\AdventOfCode10test.txt') = 3, 'PartA(test) <> 3');
    sec := PartA('..\..\AdventOfCode10.txt');
    Writeln('PartB: ', sec);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
