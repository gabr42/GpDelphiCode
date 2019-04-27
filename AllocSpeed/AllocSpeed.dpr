program AllocSpeed;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Math,
  System.Diagnostics,
  System.Generics.Collections;

const
    CMemBlockSize = 264752;

type
  EUnusedException = class(Exception)
  end;

procedure Measure;
var
  count   : integer;
  i       : Integer;
  list    : TList<pointer>;
  maxCount: integer;
  p       : pointer;
  results : TStringList;
  steps   : integer;
  stopwB  : TStopwatch;
  stopwT  : TStopwatch;
begin
  maxCount := 6000;

  list := TList<pointer>.Create;
  try
    results := TStringList.Create;
    try
      results.Add('Count;Bottom;Top');
      for steps := 0 to 100 do begin
        count := Max(Round(maxCount/100*steps), 1);
        Writeln(steps);

        list.Clear;
        list.Capacity := maxCount;
        stopwB := TStopwatch.StartNew;
        for i := 1 to count do begin
          p := VirtualAlloc(nil, CMemBlockSize, MEM_COMMIT, PAGE_READWRITE);
          list.Add(p);
        end;
        stopwB.Stop;
        for p in list do
          VirtualFree(p, CMemBlockSize, MEM_RELEASE);

        list.Clear;
        list.Capacity := maxCount;
        stopwT := TStopwatch.StartNew;
        for i := 1 to count do begin
          p := VirtualAlloc(nil, CMemBlockSize, MEM_COMMIT OR MEM_TOP_DOWN, PAGE_READWRITE);
          list.Add(p);
        end;
        stopwT.Stop;
        for p in list do
          VirtualFree(p, 0, MEM_RELEASE);

        results.Add(count.ToString + ';' + stopwB.ElapsedMilliseconds.ToString + ';' + stopwT.ElapsedMilliseconds.ToString);
      end;
      results.SaveToFile('memory.csv');
    finally FreeAndNil(results); end;
  finally FreeAndNil(list); end;
end;

begin
  try
    Measure;
    Write('> ');
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
