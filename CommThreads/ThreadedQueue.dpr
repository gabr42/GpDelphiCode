program ThreadedQueue;

uses
  Vcl.Forms,
  ThreadedQueueMain in 'ThreadedQueueMain.pas' {frmThreadedQueue},
  CommThread in 'CommThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmThreadedQueue, frmThreadedQueue);
  Application.Run;
end.
