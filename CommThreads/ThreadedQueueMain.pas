unit ThreadedQueueMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Samples.Spin, Vcl.StdCtrls,
  CommThread;

type
  TCopyThread = class(TCommThread<string,string>)
  protected
    procedure ProcessMessage(const data: string); override;
  end;

  TSingleCopyThread = class(TSingleCommThread<string,string>)
  protected
    procedure ProcessMessage(const data: string); override;
  end;

  TfrmThreadedQueue = class(TForm)
    Edit1: TEdit;
    SpinEdit1: TSpinEdit;
    Label2: TLabel;
    Button1: TButton;
    ListBox1: TListBox;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    FQueueToWorkers: TMessageQueue<string>;
    FQueueToMain: TMessageQueue<string>;
    FWorkers: TArray<TCopyThread>;
    FSingleWorker: TSingleCopyThread;
  protected
    procedure HandleWorkerMessage(const value: string);
    procedure Log(const msg: string);
  public
  end;

var
  frmThreadedQueue: TfrmThreadedQueue;

implementation

{$R *.dfm}

{ TCopyThread }

procedure TCopyThread.ProcessMessage(const data: string);
begin
  if not SendToMain('Processed: ' + data) then
    TThread.Queue(nil,
      procedure
      begin
        frmThreadedQueue.Log(Format('*** Thread failed to post message [%s]', [data]));
      end);
end;

{ TSingleCopyThread }

procedure TSingleCopyThread.ProcessMessage(const data: string);
begin
  if not SendToMain('Processed: ' + data) then
    TThread.Queue(nil,
      procedure
      begin
        frmThreadedQueue.Log(Format('*** Thread failed to post message [%s]', [data]));
      end);
end;

{ TfrmThreadedQueue }

procedure TfrmThreadedQueue.Button1Click(Sender: TObject);
var
  i: integer;
  msg: string;
begin
  ListBox1.Clear;
  msg := Edit1.Text;
  for i := 1 to SpinEdit1.Value do
    if not FQueueToWorkers.Send(msg + ' #' + i.ToString) then
      Log(Format('*** Main failed to post message [%d]', [i]));
end;

procedure TfrmThreadedQueue.Button2Click(Sender: TObject);
var
  i: integer;
  msg: string;
begin
  ListBox1.Clear;
  msg := Edit1.Text;
  for i := 1 to SpinEdit1.Value do
    if not FSingleWorker.SendToThread(msg + ' #' + i.ToString) then
      Log(Format('*** Main failed to post message [%d]', [i]));
end;

procedure TfrmThreadedQueue.FormCreate(Sender: TObject);
var
  i: integer;
begin
  FQueueToWorkers := TMessageQueue<string>.Create(100);
  FQueueToMain := TMessageQueue<string>.Create(100, HandleWorkerMessage);
  SetLength(FWorkers, TThread.ProcessorCount);
  for i := Low(FWorkers) to High(FWorkers) do
    FWorkers[i] := TCopyThread.Create(FQueueToWorkers, FQueueToMain);

  FSingleWorker := TSingleCopyThread.Create(10, HandleWorkerMessage);
end;

procedure TfrmThreadedQueue.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  for i := Low(FWorkers) to High(FWorkers) do begin
    FWorkers[i].Terminate;
    FWorkers[i].Free;
  end;
  FreeAndNil(FQueueToWorkers);
  FreeAndNil(FQueueToMain);

  FSingleWorker.Terminate;
  FSingleWorker.Free;
end;

procedure TfrmThreadedQueue.HandleWorkerMessage(const value: string);
begin
  Log(value);
end;

procedure TfrmThreadedQueue.Log(const msg: string);
begin
  ListBox1.ItemIndex := ListBox1.Items.Add(FormatDateTime('hh:mm:ss.zzz ', Now) + msg);
end;

end.
