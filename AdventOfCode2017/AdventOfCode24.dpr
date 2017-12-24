program AdventOfCode24;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Generics.Collections,
  GpStreams, GpTextStream;

type
  TComponents = class(TObjectList<TList<integer>>)
  public
    constructor Create(const fileName: string);
  end;

  TIntPair = TPair<integer,integer>;

procedure MakeBridge(const fileName: string; var max, longMax: integer);
var
  b     : boolean;
  bridge: TStack<TIntPair>;
  comps : TComponents;
  inUse : TDictionary<TIntPair, boolean>;
  len   : integer;
  maxLen: integer;
  next  : TIntPair;
  sum   : integer;
  top   : TIntPair;

  function SumBridge(var len: integer): integer;
  var
    i     : TIntPair;
    intArr: TArray<TIntPair>;
  begin
    Result := 0;
    intArr := bridge.ToArray;
    for i in intArr do
      Inc(Result, 2 * i.Key);
    len := Length(intArr);
  end;

begin
  max := 0;
  maxLen := 0;
  comps := TComponents.Create(fileName);
  try
    inUse := TDictionary<TIntPair, boolean>.Create;
    try
      bridge := TStack<TIntPair>.Create;
      try
        bridge.Push(TIntPair.Create(0,-1));
        repeat
          top := bridge.Pop;
          if top.Value < (comps[top.Key].Count - 1) then begin
            top.Value := top.Value + 1;
            bridge.Push(top);
            next := TIntPair.Create(top.Key, comps[top.Key][top.Value]);
            if not inUse.TryGetValue(next, b) then begin
              inUse.Add(next, true);
              if next.Key <> next.Value then
                inUse.Add(TIntPair.Create(next.Value, next.Key), true);
              bridge.Push(TIntPair.Create(next.Value, -1));
            end;
          end
          else if bridge.Count = 0 then
            break //repeat
          else begin
            sum := SumBridge(len) + top.Key;
            if sum > max then
              max := sum;
            if (len > maxLen) or ((len = maxLen) and (sum > longMax)) then begin
              longMax := sum;
              maxLen := len;
            end;
            next := TIntPair.Create(bridge.Peek.Key, top.Key);
            inUse.Remove(next);
            if next.Key <> next.Value then
              inUse.Remove(TIntPair.Create(next.Value, next.Key));
          end;
        until false;
      finally FreeAndNil(bridge); end;
    finally FreeAndNil(inUse); end;
  finally FreeAndNil(comps); end;
end;

{ TComponents }

constructor TComponents.Create(const fileName: string);
var
  i    : integer;
  line : string;
  list : integer;
  parts: TArray<string>;
begin
  inherited Create;
  for line in EnumLines(AutoDestroyStream(SafeCreateFileStream(fileName, fmOpenRead)).Stream) do
  begin
    parts := line.Split(['/']);
    list := parts[0].ToInteger;
    for i := Count to list do
      Add(TList<integer>.Create);
    Items[list].Add(parts[1].ToInteger);
    list := parts[1].ToInteger;
    for i := Count to list do
      Add(TList<integer>.Create);
    Items[list].Add(parts[0].ToInteger);
  end;
end;

var
  max, maxl: integer;

begin
  try
    MakeBridge('..\..\AdventOfCode24test.txt', max, maxl);
    Assert(max = 31);

    MakeBridge('..\..\AdventOfCode24.txt', max, maxl);
    Writeln(max);
    Writeln(maxl);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
