program AdventOfCode8;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  TTree = TArray<integer>;

function ReadTree(const fileName: string): TTree;
var
  data  : TArray<string>;
  i     : integer;
  reader: TStreamReader;
begin
  reader := TStreamReader.Create(fileName);
  try
    data := reader.ReadLine.Split([' ']);
    SetLength(Result, Length(data));
    for i := Low(data) to High(data) do
      Result[i] := data[i].ToInteger;
  finally FreeAndNil(reader); end;
end;

function SumTree(const data: TTree; var nodeIdx: integer): integer;
var
  i       : integer;
  numChild: integer;
  numMeta : integer;
begin
  Result := 0;
  numChild := data[nodeIdx];
  numMeta := data[nodeIdx + 1];
  nodeIdx := nodeIdx + 2;
  for i := 1 to numChild do
    Result := Result + SumTree(data, nodeIdx);
  for i := 1 to numMeta do begin
    Result := Result + data[nodeIdx];
    Inc(nodeIdx);
  end;
end;

function PartA(const fileName: string): integer;
var
  nodeIdx: integer;
begin
  nodeIdx := 0;
  Result := SumTree(ReadTree(fileName), nodeIdx);
end;

function ValueTree(const data: TTree; var nodeIdx: integer): integer;
var
  i       : integer;
  numChild: integer;
  numMeta : integer;
  values  : TList<integer>;
begin
  Result := 0;
  numChild := data[nodeIdx];
  numMeta := data[nodeIdx + 1];
  nodeIdx := nodeIdx + 2;
  values := TList<integer>.Create;
  try
    for i := 1 to numChild do
      values.Add(ValueTree(data, nodeIdx));
    for i := 1 to numMeta do begin
      if numChild = 0 then
        Result := Result + data[nodeIdx]
      else if data[nodeIdx] <= values.Count then
        Result := Result + values[data[nodeIdx]-1];
      Inc(nodeIdx);
    end;
  finally FreeAndNil(values); end;
end;

function PartB(const fileName: string): integer;
var
  nodeIdx: integer;
begin
  nodeIdx := 0;
  Result := ValueTree(ReadTree(fileName), nodeIdx);
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode8test.txt') = 138, 'PartA(test) failed');
    Writeln('PartA: ', PartA('..\..\AdventOfCode8.txt'));

    Assert(PartB('..\..\AdventOfCode8test.txt') = 66, 'PartB(test) failed');
    Writeln('PartB: ', PartB('..\..\AdventOfCode8.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
