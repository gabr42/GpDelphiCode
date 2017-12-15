program AdventOfCode12;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Generics.Collections,
  GpLists, GpStreams, GpTextStream,
  System.Classes;

type
  TMaps = class(TDictionary<string, TArray<string>>)
    procedure ReadInput(const fileName: string);
    function GetConnectedGroup(const startNode: string): TStringList;
  end;

procedure TMaps.ReadInput(const fileName: string);
var
  lr: TArray<string>;
  s : AnsiString;
begin
  for s in EnumLines(AutoDestroyStream(SafeCreateFileStream(fileName, fmOpenRead)).Stream) do
  begin
    lr := string(s).Split([' <-> ']);
    if Length(lr) <> 2 then
      raise Exception.Create('Invalid input: ' + string(s));
    Add(lr[0], lr[1].Split([', ']));
  end;
end;

function TMaps.GetConnectedGroup(const startNode: string): TStringList;
var
  node  : string;
  unseen: TStringList;
begin
  Result := TStringList.Create;
  Result.Sorted := true;
  unseen := TStringList.Create;
  try
    unseen.Sorted := true;
    unseen.Duplicates := dupIgnore;
    unseen.Add(startNode);
    while unseen.Count > 0 do begin
      node := unseen[0];
      unseen.Delete(0);
      Result.Add(node);
      for node in Items[node] do
        if not Result.Contains(node) then
          unseen.Add(node);
    end;
  finally FreeAndNil(unseen); end;
end;

function PartA(const fileName: string): integer;
var
  group: TStringList;
  maps: TMaps;
begin
  maps := TMaps.Create;
  try
    maps.ReadInput(fileName);

    group := maps.GetConnectedGroup('0');
    try
      Result := group.Count;
    finally FreeAndNil(group); end;
  finally FreeAndNil(maps); end;
end;

function PartB(const fileName: string): integer;
var
  first: string;
  group: TStringList;
  maps : TMaps;
  s    : string;
begin
  Result := 0;
  maps := TMaps.Create;
  try
    maps.ReadInput(fileName);

    first := '0';
    while maps.Count > 0 do begin
      Inc(Result);
      group := maps.GetConnectedGroup(first);
      try
        for s in group do
          maps.Remove(s);
      finally FreeAndNil(group); end;
      for s in maps.Keys do begin
        first := s;
        break;
      end;
    end;
  finally FreeAndNil(maps); end;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode12test.txt') = 6, 'PartA test failed');
    Assert(PartB('..\..\AdventOfCode12test.txt') = 2, 'PartB test failed');

    Writeln(PartA('..\..\AdventOfCode12.txt'));
    Writeln(PartB('..\..\AdventOfCode12.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;

end.
