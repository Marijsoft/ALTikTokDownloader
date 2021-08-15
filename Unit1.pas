{ ******************************************************* }
{                                                         }
{ AL Tiktok Downloader                                    }
{                                                         }
{ Copyright (C) 2021 Aloe Luigi                           }
{ Distribuited under license BSD 3                        }
{                                                         }
{ ******************************************************* }

unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.NetEncoding,
  FMX.Objects, FMX.Menus;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    ProgressBar1: TProgressBar;
    Edit1: TEdit;
    ClearEditButton1: TClearEditButton;
    Button1: TButton;
    NetHTTPClient1: TNetHTTPClient;
    Label1: TLabel;
    Image1: TImage;
    StyleBook1: TStyleBook;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure NetHTTPClient1ReceiveData(const Sender: TObject;
      AContentLength, AReadCount: Int64; var AAbort: Boolean);
    procedure MenuItem1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

const
  url = 'aHR0cHM6Ly9nb2Rvd25sb2FkZXIuY29tL2FwaS90aWt0b2stbm8td2F0ZXJtYXJrLWZyZWU/dXJsPQ==';

const
  apikey = 'JmtleT1nb2Rvd25sb2FkZXIuY29t';

implementation

uses
  System.JSON;
{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
  urlnk, key, datijson, linkvideo, titolo, t: string;
  tm: TMemoryStream;
begin
  Label1.Text.Empty;
  urlnk := TNetEncoding.Base64.Decode(url);
  key := TNetEncoding.Base64.Decode(apikey);
  datijson := (NetHTTPClient1.Get(urlnk + Edit1.Text + key).ContentAsString);
  var
  JSONValue := TJSONObject.ParseJSONValue(datijson);
  try
    if JSONValue is TJSONObject then
    begin
      linkvideo := JSONValue.GetValue<string>('video_no_watermark');
      linkvideo := linkvideo.Replace('\', '', [RfReplaceAll]);
      titolo := JSONValue.GetValue<string>('desc');
      titolo := titolo.Replace('@', '', [RfReplaceAll]);
      t := TNetEncoding.Base64.Decode('Z29kb3dubG9hZGVy');
      titolo := titolo.Replace(t, '', [RfReplaceAll]);
    end;
  finally
    JSONValue.Free;
  end;
  TThread.CreateAnonymousThread(
    procedure
    begin
      tm := TMemoryStream.Create;
      try
        NetHTTPClient1.OnReceiveData := NetHTTPClient1ReceiveData;
        NetHTTPClient1.Get(linkvideo, tm).ContentStream;
      finally
        NetHTTPClient1.OnReceiveData := nil;
        tm.Position := 0;
        tm.SaveToFile(titolo + '.mp4');
        tm.DisposeOf;
      end;
      TThread.CreateAnonymousThread(
        procedure
        begin
          Label1.Text := 'File downloaded!';
        end).Start;
    end).Start;
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
begin
  ShowMessage('AL TikTok Downloader created by Aloe Luigi.' + #13 +
    'This software is distribuited under license bsd 3' + #13 +
    'no one must to pay for use this one');
end;

procedure TForm1.NetHTTPClient1ReceiveData(const Sender: TObject;
AContentLength, AReadCount: Int64; var AAbort: Boolean);
begin
  ProgressBar1.Max := AContentLength;
  ProgressBar1.Value := AReadCount;
  Application.ProcessMessages;
end;

end.
