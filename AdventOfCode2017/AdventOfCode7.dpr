program AdventOfCode7;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.RegularExpressions,
  GpLists, GpStreams, GpTextStream;

type
  TProgramInfo = class
  public
    Weight     : integer;
    TotalWeight: integer;
    Children   : TStringList;
    constructor Create;
    destructor Destroy; override;
  end;

  TPrograms = class(TObjectDictionary<string, TProgramInfo>)
  public type
  public
    procedure ReadFromFile(const fileName: string);
    function TotalChildWeight(info: TProgramInfo): integer;
    function Unbalanced(info: TProgramInfo; var badChild: TProgramInfo; 
      var goodWeight: integer): boolean;
  end;

function PartA(programs: TPrograms): string;
var
  child   : string;
  idx     : integer;
  progInfo: TProgramInfo;
  progs   : TStringList;
begin
  progs := TStringList.Create;
  try
    progs.AddStrings(programs.Keys.ToArray);
    progs.Sorted := true;
    for progInfo in programs.Values do
      for child in progInfo.Children do begin
        idx := progs.IndexOf(child);
        if idx >= 0 then
          progs.Delete(idx);
      end;
    Result := progs[0];
  finally FreeAndNil(progs); end;
end;

function PartB(programs: TPrograms): integer;
var
  badChild   : TProgramInfo;
  childWeight: integer;
  goodWeight : integer;
  info       : TProgramInfo;
  progs      : TStringList;
begin
  Result := 0; //balanced tree
  progs := TStringList.Create;
  try
    progs.AddStrings(programs.Keys.ToArray);
    while progs.Count > 0 do begin
      info := programs[progs[0]];
      if info.Children.Count = 0 then begin
        info.TotalWeight := info.Weight;
        programs.AddOrSetValue(progs[0], info);
        progs.Delete(0);
      end
      else begin
        childWeight := programs.TotalChildWeight(info);
        if childWeight = 0 then 
          progs.Move(0, progs.Count - 1)
        else begin // all children have weight
          if programs.Unbalanced(info, badChild, goodWeight) then 
            Exit(badChild.Weight + goodWeight - badChild.TotalWeight);
          info.TotalWeight := info.Weight + childWeight;
          programs.AddOrSetValue(progs[0], info);
          progs.Delete(0);
        end
      end;
    end;
  finally FreeAndNil(progs); end;
end;

var
  programs: TPrograms;

{ TPrograms.TProgramInfo }

constructor TProgramInfo.Create;
begin
  inherited Create;
  Children := TStringList.Create;
end;

destructor TProgramInfo.Destroy;
begin
  FreeAndNil(Children);
  inherited;
end;

{ TPrograms }

procedure TPrograms.ReadFromFile(const fileName: string);
var
  info    : TProgramInfo;
  match   : TMatch;
  regexObj: TRegEx;
  s       : string;
begin
  regexObj := TRegEx.Create('([a-z]+)\s\((\d+)\)(\s*->\s*(.*))?', [roIgnoreCase, roMultiLine]);
  for s in EnumLines(AutoDestroyStream(SafeCreateFileStream(fileName, fmOpenRead)).Stream) do
  begin
    match := regexObj.Match(s);
    if not match.Success then
      raise Exception.Create('Invalid input: ' + s);
    info := TProgramInfo.Create;
    info.Weight := StrToInt(match.Groups[2].Value);
    if match.Groups.Count > 3 then begin
      info.Children.Delimiter := ';';
      info.Children.DelimitedText := StringReplace(match.Groups[4].Value, ', ', ';', [rfReplaceAll]);
    end;
    Add(match.Groups[1].Value, info);
  end;
end;

function TPrograms.TotalChildWeight(info: TProgramInfo): integer;
var
  child    : string;
  childInfo: TProgramInfo;
begin
  Result := 0;
  for child in info.Children do begin
    childInfo := Items[child];
    if childInfo.TotalWeight = 0 then
      Exit(0);
    Inc(Result, childInfo.TotalWeight);
  end;
end;

function TPrograms.Unbalanced(info: TProgramInfo; var badChild: TProgramInfo; 
  var goodWeight: integer): boolean;
var
  child     : string;
  childInfo : TProgramInfo;
  i         : integer;
  idx       : integer;
  weights   : TGpCountedIntegerList;
begin
  Result := false;
  badChild := nil;
  goodWeight := 0;
  weights := TGpCountedIntegerList.Create;
  try
    for child in info.Children do begin
      childInfo := Items[child];
      if childInfo.TotalWeight = 0 then
        raise Exception.Create('Unbalanced: TotalWeight = 0?');
      idx := weights.IndexOf(childInfo.TotalWeight);
      if idx < 0 then
        weights.Add(childInfo.TotalWeight, 1)
      else
        weights.Counter[idx] := weights.Counter[idx] + 1;
    end;
    if weights.Count > 1 then begin
      for i := 0 to weights.Count - 1 do
        if weights.Counter[i] > 1 then
          goodWeight := weights[i];
      for i := 0 to weights.Count - 1 do
        if weights.Counter[i] = 1 then begin
          for child in info.children do
            if Items[child].TotalWeight = weights[i] then begin
              badChild := Items[child];
              Exit(true);
            end;
        end;
    end;
  finally FreeAndNil(weights); end;
end;

begin
  try
    programs := TPrograms.Create;
    try
      programs.ReadFromFile('..\..\AdventOfCode7test.txt');
      Assert(PartA(programs) = 'tknk', 'PartA(test) <> "tknk"');
      Assert(PartB(programs) = 60, 'PartB(test) <> 60');
    finally FreeAndNil(programs); end;

    programs := TPrograms.Create;
    try
      programs.ReadFromFile('..\..\AdventOfCode7.txt');
      Writeln(PartA(programs));
      Writeln(PartB(programs));
    finally FreeAndNil(programs); end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Readln;
end.
