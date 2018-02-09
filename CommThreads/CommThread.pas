unit CommThread;

interface

uses
  System.Classes, System.SyncObjs, System.Generics.Collections;

type
  TMessageProc<T> = reference to procedure (const data: T);

  TMessageQueue<T> = class
  strict private
    FEvent   : TEvent;
    FQueue   : TThreadedQueue<T>;
    FReceiver: TMessageProc<T>;
  strict protected
    procedure DispatchMessages;
  public
    constructor Create(numItems: integer;
      const messageReceiver: TMessageProc<T> = nil);
    destructor Destroy; override;
    function Receive(var value: T): boolean;
    function Send(const value: T): boolean;
    property Event: TEvent read FEvent;
  end;

  TCommThread<TToThread, TToMain> = class(TThread)
  strict private
    FToThread: TMessageQueue<TToThread>;
    FToMain  : TMessageQueue<TToMain>;
  protected
    procedure ProcessMessage(const data: TToThread); virtual; abstract;
    function SendToMain(const value: TToMain): boolean;
    procedure TerminatedSet; override;
  public
    constructor Create(AQueueToThread: TMessageQueue<TToThread>;
      AQueueToMain: TMessageQueue<TToMain>);
    procedure Execute; override;
  end;

  TSingleCommThread<TToThread, TToMain> = class(TCommThread<TToThread, TToMain>)
  strict private
    FToThreadQueue: TMessageQueue<TToThread>;
    FToMainQueue: TMessageQueue<TToMain>;
  public
    constructor Create(numItems: integer;
      const messageReceiver: TMessageProc<TToMain> = nil);
    destructor Destroy; override;
    function SendToThread(const value: TToThread): boolean;
  end;

implementation

uses
  System.SysUtils;

{ TMessageQueue<T> }

constructor TMessageQueue<T>.Create(numItems: integer;
  const messageReceiver: TMessageProc<T>);
begin
  inherited Create;
  FQueue := TThreadedQueue<T>.Create(numItems, 0, 0);
  FReceiver := messageReceiver;
  if not assigned(FReceiver) then
    FEvent := TEvent.Create;
end;

destructor TMessageQueue<T>.Destroy;
begin
  FreeAndNil(FQueue);
  FreeAndNil(FEvent);
  inherited;
end;

procedure TMessageQueue<T>.DispatchMessages;
var
  value: T;
begin
  while FQueue.PopItem(value) = wrSignaled do
    FReceiver(value);
end;

function TMessageQueue<T>.Receive(var value: T): boolean;
begin
  Result := (FQueue.PopItem(value) = wrSignaled);
end;

function TMessageQueue<T>.Send(const value: T): boolean;
begin
  Result := (FQueue.PushItem(value) = wrSignaled);
  if assigned(FEvent) then
    FEvent.SetEvent;
  if assigned(FReceiver) then
    TThread.Queue(TThread.Current, DispatchMessages);
end;

{ TCommThread<TToThread, TToMain> }

constructor TCommThread<TToThread, TToMain>.Create(AQueueToThread: TMessageQueue<TToThread>;
      AQueueToMain: TMessageQueue<TToMain>);
begin
  inherited Create;
  FToThread := AQueueToThread;
  FToMain := AQueueToMain;
end;

procedure TCommThread<TToThread, TToMain>.Execute;
var
  data: TToThread;
begin
  while FToThread.Event.WaitFor = wrSignaled do begin
    if Terminated then
      break;
    FToThread.Event.ResetEvent;
    while FToThread.Receive(data) do
      ProcessMessage(data);
  end;
  TThread.RemoveQueuedEvents(TThread.Current);
end;

function TCommThread<TToThread, TToMain>.SendToMain(
  const value: TToMain): boolean;
begin
  Result := FToMain.Send(value);
end;

procedure TCommThread<TToThread, TToMain>.TerminatedSet;
begin
  FToThread.Event.SetEvent;
  inherited;
end;

{ TSingleCommThread<TToThread, TToMain> }

constructor TSingleCommThread<TToThread, TToMain>.Create(numItems: integer;
  const messageReceiver: TMessageProc<TToMain>);
begin
  FToThreadQueue := TMessageQueue<TToThread>.Create(numItems);
  FToMainQueue := TMessageQueue<TToMain>.Create(numItems, messageReceiver);
  inherited Create(FToThreadQueue, FToMainQueue);
end;

destructor TSingleCommThread<TToThread, TToMain>.Destroy;
begin
  inherited;
  FreeAndNil(FToThreadQueue);
  FreeAndNil(FToMainQueue);
end;

function TSingleCommThread<TToThread, TToMain>.SendToThread(
  const value: TToThread): boolean;
begin
  Result := FToThreadQueue.Send(value);
end;

end.
