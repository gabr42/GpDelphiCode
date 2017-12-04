program AdventOfCode4;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  GpStreams,
  GpTextStream;

function IsPhraseValidA(const phrase: string): boolean;
var
  dict: TStringList;
  word: string;
begin
  Result := true;
  dict := TStringList.Create;
  try
    dict.Sorted := true;
    for word in phrase.Split([' ']) do
      if dict.IndexOf(word) >= 0 then
        Exit(false)
      else
        dict.Add(word);
  finally FreeAndNil(dict); end;
end;

function PartA: integer;
var
  phrase: string;
begin
  Result := 0;
  for phrase in EnumLines(AutoDestroyStream(SafeCreateFileStream('..\..\AdventOfCode4.txt', fmOpenRead)).Stream) do
    Inc(Result, Ord(IsPhraseValidA(phrase)));
end;

function Sort(const word: string): string;
var
  ch: char;
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    for ch in word do
      sl.Add(ch);
    sl.Sort;
    sl.Delimiter := ' ';
    Result := StringReplace(sl.DelimitedText, ' ', '', [rfReplaceAll]);
  finally FreeAndNil(sl); end;
end;

function IsPhraseValidB(const phrase: string): boolean;
var
  dict  : TStringList;
  sorted: string;
  word  : string;
begin
  Result := true;
  dict := TStringList.Create;
  try
    dict.Sorted := true;
    for word in phrase.Split([' ']) do begin
      sorted := Sort(word);
      if dict.IndexOf(sorted) >= 0 then
        Exit(false)
      else
        dict.Add(sorted);
    end;
  finally FreeAndNil(dict); end;
end;

function PartB: integer;
var
  phrase: string;
begin
  Result := 0;
  for phrase in EnumLines(AutoDestroyStream(SafeCreateFileStream('..\..\AdventOfCode4.txt', fmOpenRead)).Stream) do
    Inc(Result, Ord(IsPhraseValidB(phrase)));
end;

begin
  try
    Assert(IsPhraseValidA('aa bb cc dd ee'), 'failed test A#1');
    Assert(not IsPhraseValidA('aa bb cc dd aa'), 'failed test A#2');
    Assert(IsPhraseValidA('aa bb cc dd aaa'), 'failed test A#3');

    Assert(IsPhraseValidB('abcde fghij'), 'failed test B#1');
    Assert(not IsPhraseValidB('abcde xyz ecdab'), 'failed test B#2');
    Assert(IsPhraseValidB('a ab abc abd abf abj'), 'failed test B#3');
    Assert(IsPhraseValidB('iiii oiii ooii oooi oooo'), 'failed test B#4');
    Assert(not IsPhraseValidB('oiii ioii iioi iiio'), 'failed test B#5');

    Writeln('PartA: ', PartA);
    Writeln('PartB: ', PartB);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
