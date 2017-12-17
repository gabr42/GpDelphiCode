program AdventOfCode17;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  GpLists;

function PartA(step: integer): integer;
var
  cp  : integer;
  i   : integer;
  list: TGpIntegerList;
begin
  list := TGpIntegerList.Create;
  try
    list.Add(0);
    cp := 0;
    for i := 1 to 2017 do begin
      cp := (cp + step) mod list.Count;
      list.Insert(cp + 1, i);
      Inc(cp);
    end;
    Result := list[(cp+1) mod list.Count];
    i := list.IndexOf(0);
  finally FreeAndNil(list); end;
end;

function PartB(step, max: integer): integer;
var
  cp  : integer;
  i   : integer;
  pos0: integer;
begin
  pos0 := 0;
  cp := 1;
  Result := 1;
  for i := 2 to max do begin
    cp := (cp + step) mod i + 1;
    if cp = (pos0 + 1) then
      Result := i;
  end;
end;


begin
  try
    Assert(PartA(3) = 638, 'PartA test failed');
    Assert(PartB(3, 2017) = 1226, 'PartB test failed');

    Writeln(PartA(335));
    Writeln(PartB(335, 50000000));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
