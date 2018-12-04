program AdventOfCode4;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.DateUtils,
  System.Classes,
  System.Generics.Defaults,
  System.Generics.Collections;

type
  TLogEntry = record
    DateTime   : TDateTime;
    Description: string;
  end;
  TGuardLog = record
    Minutes: array [0..59] of integer;
    Total  : integer;
  end;
  TGuards = TDictionary<integer, TGuardLog>;

procedure LoadLog(log: TList<TLogEntry>; const fileName: string);
var
  entry : TLogEntry;
  parts : TArray<string>;
  reader: TStreamReader;
  s     : string;
  time  : TArray<string>;
begin
  reader := TStreamReader.Create(fileName);
  try
    while not reader.EndOfStream do begin
      s := reader.ReadLine.Trim;
      if s = '' then
        continue;
      parts := s.Split(['[', ']']);
      time := parts[1].Split(['-', ' ', ':']);
      entry.DateTime := EncodeDate(time[0].ToInteger + 1000, time[1].ToInteger, time[2].ToInteger) +
                        EncodeTime(time[3].ToInteger, time[4].ToInteger, 0, 0);
      entry.Description := parts[2].Trim;
      log.Add(entry);
    end;
  finally FreeAndNil(reader); end;

  log.Sort(TComparer<TLogEntry>.Construct(
    function (const left, right: TLogEntry): integer
    begin
      Result := CompareDateTime(left.DateTime, right.DateTime);
    end));
end;

procedure LoadGuards(guards: TGuards; log: TList<TLogEntry>);
var
  action  : TArray<string>;
  asleepAt: TDateTime;
  guardID : integer;
  guardLog: TGuardLog;
  i       : integer;
  logEntry: TLogEntry;
begin
  guardID := -1;
  asleepAt := 0;
  for logEntry in log do begin
    action := logEntry.Description.Split([' ', '#']);
    if SameText(action[0], 'Guard') then
      guardID := action[2].ToInteger
    else if SameText(action[0], 'falls') then
      asleepAt := logEntry.DateTime
    else if SameText(action[0], 'wakes') then begin
      if not guards.TryGetValue(guardID, guardLog) then
        guardLog := Default(TGuardLog);
      for i := MinuteOf(asleepAt) to MinuteOf(logEntry.DateTime) - 1 do begin
        guardLog.Minutes[i] := guardLog.Minutes[i] + 1;
        guardLog.Total := guardLog.Total + 1;
      end;
      guards.AddOrSetValue(guardID, guardLog);
    end;
  end;
end;

procedure FindSleepy(const guards: TGuards; out guardID: integer; out guardLog: TGuardLog);
var
  kv : TPair<integer, TGuardLog>;
  max: integer;
begin
  max := -1;
  for kv in guards do begin
    if kv.Value.Total > max then begin
      guardID := kv.Key;
      guardLog := kv.Value;
      max := kv.Value.Total;
    end;
  end;
end;

function FindMaxMinute(const guardLog: TGuardLog): integer;
var
  i  : integer;
  max: integer;
begin
  Result := -1;
  max := -1;
  for i := Low(guardLog.Minutes) to High(guardLog.Minutes) do
    if guardLog.Minutes[i] > max then begin
      max := guardLog.Minutes[i];
      Result := i;
    end;
end;

procedure FindTopMinute(guards: TGuards; out guardID, minute: integer);
var
  i  : integer;
  kv : TPair<integer, TGuardLog>;
  max: integer;
begin
  max := -1;
  for kv in guards do
    for i := Low(kv.Value.Minutes) to High(kv.Value.Minutes) do
      if kv.Value.Minutes[i] > max then begin
        max := kv.Value.Minutes[i];
        guardID := kv.Key;
        minute := i;
      end;
end;

function PartA(const fileName: string): integer;
var
  guardID : integer;
  guardLog: TGuardLog;
  guards  : TGuards;
  log     : TList<TLogEntry>;
begin
  log := TList<TlogEntry>.Create;
  try
    LoadLog(log, fileName);
    guards := TGuards.Create;
    try
      LoadGuards(guards, log);
      FindSleepy(guards, guardID, guardLog);
      Result := guardID * FindMaxMinute(guardLog);
    finally FreeAndNil(guards); end;
  finally FreeAndNil(log); end;
end;

function PartB(const fileName: string): integer;
var
  guardID : integer;
  guardLog: TGuardLog;
  guards  : TGuards;
  log     : TList<TLogEntry>;
  minute  : integer;
begin
  log := TList<TlogEntry>.Create;
  try
    LoadLog(log, fileName);
    guards := TGuards.Create;
    try
      LoadGuards(guards, log);
      FindTopMinute(guards, guardID, minute);
      Result := guardID * minute;
    finally FreeAndNil(guards); end;
  finally FreeAndNil(log); end;
end;

begin
  try
    Assert(PartA('..\..\AdventOfCode4test.txt') = 240, 'PartA(test) <> 240');
    Writeln('PartA: ', PartA('..\..\AdventOfCode4.txt'));

    Assert(PartB('..\..\AdventOfCode4test.txt') = 4455, 'PartB(test) <> 4455');
    Writeln('PartB: ', PartB('..\..\AdventOfCode4.txt'));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
