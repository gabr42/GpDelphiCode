program AdventOfCode1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  GpStreams;

  function PartA(s: AnsiString): integer;
  var
    i: integer;
  begin
    s := s + s[1];
    Result := 0;
    for i := 1 to Length(s) - 1 do
      if s[i] = s[i+1] then
        Inc(Result, StrToInt(s[i]));
  end;

  function PartB(s: AnsiString): integer;
  var
    i: integer;
    halfLen: integer;
  begin
    halfLen := Length(s) div 2;
    s := s + Copy(s, 1, halfLen);
    Result := 0;
    for i := 1 to halfLen * 2 do
      if s[i] = s[i+halfLen] then
        Inc(Result, StrToInt(s[i]));
  end;

var
  s: AnsiString;

begin
  try
    Assert(PartA('1122') = 3, 'A("1122") <> 3');
    Assert(PartA('1111') = 4, 'A("1111") <> 4');
    Assert(PartA('1234') = 0, 'A("1234") <> 0');
    Assert(PartA('91212129') = 9, 'A("91212129") <> 9');

    Assert(PartB('1212') = 6, 'B("1212") <> 6');
    Assert(PartB('1221') = 0, 'B("1221") <> 0');
    Assert(PartB('123425') = 4, 'B("123425") <> 4');
    Assert(PartB('123123') = 12, 'B("123123") <> 12');
    Assert(PartB('12131415') = 4, 'B("12131415") <> 4');

    if not ReadFromFile('..\..\AdventOfCode1.txt', s) then
      Writeln('Cannot read data')
    else begin
      Writeln('PartA: ', PartA(s));
      Writeln('PartB: ', PartB(s));
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.

