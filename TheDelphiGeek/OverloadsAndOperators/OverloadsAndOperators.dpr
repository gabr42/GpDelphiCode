program OverloadsAndOperators;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

type
  TConnector = class
  public
    procedure SetupBridge(const url1, url2: string); overload;
    procedure SetupBridge(const url1, proto2, host2, path2: string); overload;
    procedure SetupBridge(const proto1, host1, path1, proto2, host2, path2: string); overload;
//    procedure SetupBridge(const proto1, host1, path1, url2: string); overload;
  end;

  TURL = record
  strict private
    FUrl: string;
  public
    constructor Create(const proto, host, path: string);
    class operator Implicit(const url: string): TURL;
    class operator Implicit(const url: TURL): string;
  end;

  TConnector2 = class
  public
    procedure SetupBridge(const url1, url2: TURL);
  end;

{ TConnector }

procedure TConnector.SetupBridge(const url1, url2: string);
begin
  Writeln('  1: ', url1);
  Writeln('  2: ', url2);
end;

procedure TConnector.SetupBridge(const url1, proto2, host2, path2: string);
begin
  Writeln('  1: ', url1);
  Writeln('  2: ', proto2, '://', host2, '/', path2);
end;

procedure TConnector.SetupBridge(const proto1, host1, path1, proto2, host2, path2: string);
begin
  Writeln('  1: ', proto1, '://', host1, '/', path1);
  Writeln('  2: ', proto2, '://', host2, '/', path2);
end;

//procedure TConnector.SetupBridge(const proto1, host1, path1, url2: string);
//begin
//  Writeln('  1: ', proto1, '://', host1, '/', path1);
//  Writeln('  2: ', url2);
//end;

var
  conn: TConnector;
  conn2: TConnector2;

{ TURL }

constructor TURL.Create(const proto, host, path: string);
begin
  FURL := proto + '://' + host + '/' + path;
end;

class operator TURL.Implicit(const url: string): TURL;
begin
  Result.FURL := url;
end;

class operator TURL.Implicit(const url: TURL): string;
begin
  Result := url.FURL;
end;

{ TConnector2 }

procedure TConnector2.SetupBridge(const url1, url2: TURL);
begin
  Writeln('  1: ' + url1);
  Writeln('  2: ' + url2);
end;

begin
  try
    Writeln;

    conn := TConnector.Create;
    try
      conn.SetupBridge('http://www.thedelphigeek.com/index.html',
                       'http://bad.horse/');
      conn.SetupBridge('http://www.thedelphigeek.com/index.html',
                       'http', 'bad.horse', '');
      conn.SetupBridge('http', 'www.thedelphigeek.com', 'index.html',
                       'http', 'bad.horse', '');
      // this compiles, ouch:
      conn.SetupBridge('http', 'www.thedelphigeek.com', 'index.html',
                       'http://bad.horse/');
    finally
      FreeAndNil(conn);
    end;
    Writeln;

    conn2 := TConnector2.Create;
    try
      conn2.SetupBridge('http://www.thedelphigeek.com/index.html',
                       'http://bad.horse/');
      conn2.SetupBridge('http://www.thedelphigeek.com/index.html',
                       TURL.Create('http', 'bad.horse', ''));
      conn2.SetupBridge(TURL.Create('http', 'www.thedelphigeek.com', 'index.html'),
                       TURL.Create('http', 'bad.horse', ''));
      // this works as expected:
      conn2.SetupBridge(TURL.Create('http', 'www.thedelphigeek.com', 'index.html'),
                       'http://bad.horse/');
    finally
      FreeAndNil(conn2);
    end;

    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.


