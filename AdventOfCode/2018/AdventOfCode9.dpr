program AdventOfCode9;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

type
  TMarble = class
    Value    : integer;
    Clockwise: TMarble;
    CounterCW: TMarble;
  end;

function SetupGame: TMarble;
begin
  Result := TMarble.Create;
  Result.Value := 0;
  Result.Clockwise := Result;
  Result.CounterCW := Result;
end;

procedure TearDownGame(marble: TMarble);
var
  tmpMarble: TMarble;
begin
  marble.CounterCW.Clockwise := nil;
  while assigned(marble.Clockwise) do begin
    tmpMarble := marble;
    marble := marble.Clockwise;
    FreeAndNil(tmpMarble);
  end;
  FreeAndNil(marble);
end;

function AdvanceCW(marble: TMarble; steps: integer): TMarble;
var
  i: integer;
begin
  Result := marble;
  for i := 1 to steps do
    Result := Result.Clockwise;
end;

function AdvanceCCW(marble: TMarble; steps: integer): TMarble;
var
  i: integer;
begin
  Result := marble;
  for i := 1 to steps do
    Result := Result.CounterCW;
end;

function InsertClockwiseFrom(marble: TMarble): TMarble;
begin
  Result := TMarble.Create;
  Result.Clockwise := marble.Clockwise;
  Result.CounterCW := marble;
  marble.Clockwise := Result;
  Result.Clockwise.CounterCW := Result;
end;

function RemoveMarbleMoveCW(marble: TMarble): TMarble;
begin
  Result := marble.Clockwise;
  marble.CounterCW.Clockwise := marble.Clockwise;
  marble.Clockwise.CounterCW := marble.CounterCW;
  marble.Free;
end;

(*
procedure DumpCircle(marble: TMarble);
var
  first: TMarble;
begin
  first := marble;
  while first.Value <> 0 do
    first := first.Clockwise;

  repeat
    if first = marble then
      Write('(', first.Value, ') ')
    else
      Write(first.Value, ' ');
    first := first.Clockwise;
  until first.Value = 0;
  Writeln;
end;
*)

function PartA(numPlayers, highestMarble: integer): int64;
var
  circle     : TMarble;
  curPlayer  : integer;
  marble     : integer;
  playerScore: TArray<int64>;
  score      : int64;
begin
  SetLength(playerScore, numPlayers);
  curPlayer := 0;

  circle := SetupGame;
  try
    for marble := 1 to highestMarble do begin
      if (marble mod 23) <> 0 then begin
        circle := InsertClockwiseFrom(AdvanceCW(circle, 1));
        circle.Value := marble;
      end
      else begin
        playerScore[curPlayer] := playerScore[curPlayer] + marble;
        circle := AdvanceCCW(circle, 7);
        playerScore[curPlayer] := playerScore[curPlayer] + circle.Value;
        circle := RemoveMarbleMoveCW(circle);
      end;

      curPlayer := (curPlayer + 1) mod numPlayers;
    end;
  finally TearDownGame(circle); end;

  Result := 0;
  for score in playerScore do
    if score > Result then
      Result := score;
end;

begin
  try
    Assert(PartA(9, 25) = 32, 'PartA(9, 25) <> 32');
    Assert(PartA(10, 1618) = 8317, 'PartA(10, 1618) <> 8317');
    Assert(PartA(13, 7999) = 146373, 'PartA(13, 7999) <> 146373');
    Assert(PartA(17, 1104) = 2764, 'PartA(17, 1104) <> 2764');
    Assert(PartA(21, 6111) = 54718, 'PartA(21, 6111) <> 54718');
    Assert(PartA(30, 5807) = 37305, 'PartA(30, 5807) <> 37305');
    Writeln('PartA: ', PartA(438, 71626));

    Writeln('PartB: ', PartA(438, 71626 * 100));
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Write('> '); Readln;
end.
