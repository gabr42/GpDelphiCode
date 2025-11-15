program TestAnsiBuffer;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

function DumpBuffer(const astr: AnsiString): string;
begin
  Result := Format('[%d] ', [Length(astr)]);
  for var ch in astr do
    Result := Result + Format('%.2x', [Ord(ch)]);
end;

procedure Check(const astr: AnsiString);
begin
  Write('Original: ', DumpBuffer(astr));
  Writeln(', Converted: ', DumpBuffer(AnsiString(string(astr))));
end;

begin
  // valid UTF-8 sequences
  Check(#$41#$42#$43);
  Check(#$01#$02#$03);
  Writeln('---');
  // invalid UTF-8 sequences
  Check(#$e2#$28#$a1);
  Check(#$e2#$82#$28);
  Check(#$c3#$28);
  Writeln('> '); Readln;
end.
