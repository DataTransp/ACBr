unit FormPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ACBrAbecsPinPad;

type

  { TForm1 }

  TForm1 = class(TForm)
    btAtivar: TButton;
    btMNU: TButton;
    btCLX: TButton;
    btDEX: TButton;
    btDSP: TButton;
    btDSI: TButton;
    btGCD: TButton;
    btGKY: TButton;
    btGIN: TButton;
    btCEX: TButton;
    btLMF: TButton;
    btDMF: TButton;
    btMediaLoad: TButton;
    btGIX: TButton;
    btDesativar: TButton;
    btRMC: TButton;
    btOPN: TButton;
    btCLO: TButton;
    Button1: TButton;
    edPorta: TEdit;
    Label1: TLabel;
    pCancelar: TPanel;
    procedure btAtivarClick(Sender: TObject);
    procedure btCEXClick(Sender: TObject);
    procedure btCLOClick(Sender: TObject);
    procedure btCLXClick(Sender: TObject);
    procedure btDesativarClick(Sender: TObject);
    procedure btDEXClick(Sender: TObject);
    procedure btDMFClick(Sender: TObject);
    procedure btDSIClick(Sender: TObject);
    procedure btDSPClick(Sender: TObject);
    procedure btGCDClick(Sender: TObject);
    procedure btGINClick(Sender: TObject);
    procedure btGIXClick(Sender: TObject);
    procedure btGKYClick(Sender: TObject);
    procedure btMediaLoadClick(Sender: TObject);
    procedure btLMFClick(Sender: TObject);
    procedure btMNUClick(Sender: TObject);
    procedure btOPNClick(Sender: TObject);
    procedure btRMCClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  protected
    procedure ShowPanelCancel;
    procedure HidePanelCancel;
    procedure OnStartCommand(Sender: TObject);
    procedure OnWaitForResponse(var Cancel: Boolean);
    procedure OnEndCommand(Sender: TObject);
  private
    fAbecsPinPad: TACBrAbecsPinPad;
  public

  end;

var
  Form1: TForm1;

implementation

uses
  ACBrUtiL.FilesIO,
  ACBrUtil.Strings;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  fAbecsPinPad := TACBrAbecsPinPad.Create(Self);
  fAbecsPinPad.LogFile := 'C:\temp\ACBrPinPad.log';
  fAbecsPinPad.LogLevel := 6;
  //fAbecsPinPad.LogTranslate := False;
  fAbecsPinPad.OnStartCommand := @OnStartCommand;
  fAbecsPinPad.OnWaitForResponse := @OnWaitForResponse;
  fAbecsPinPad.OnEndCommand := @OnEndCommand;
end;

procedure TForm1.ShowPanelCancel;
begin
  pCancelar.Align := alClient;
  pCancelar.Visible := True;
end;

procedure TForm1.HidePanelCancel;
begin
  pCancelar.Visible := False;
end;

procedure TForm1.OnStartCommand(Sender: TObject);
begin
  if fAbecsPinPad.Command.IsBlocking then
    ShowPanelCancel;
end;

procedure TForm1.OnWaitForResponse(var Cancel: Boolean);
begin
  Application.ProcessMessages;
  Cancel := not pCancelar.Visible;
end;

procedure TForm1.OnEndCommand(Sender: TObject);
begin
  HidePanelCancel;
end;

procedure TForm1.btAtivarClick(Sender: TObject);
begin
  fAbecsPinPad.Port := edPorta.Text;
  fAbecsPinPad.Enable;
end;

procedure TForm1.btCEXClick(Sender: TObject);
begin
  fAbecsPinPad.DSP('Pressione'+#13+'alguma tecla');
  fAbecsPinPad.CEX(True,False,False,False,False);
  ShowMessage('PP_EVENT: '+fAbecsPinPad.Response.GetResponseFromTagValue(PP_EVENT) + sLineBreak +
              'PP_TRK1INC: '+fAbecsPinPad.Response.GetResponseFromTagValue(PP_TRACK1) + sLineBreak +
              'PP_TRK2INC: '+fAbecsPinPad.Response.GetResponseFromTagValue(PP_TRACK2) + sLineBreak +
              'PP_TRK3INC: '+fAbecsPinPad.Response.GetResponseFromTagValue(PP_TRACK3) );

  fAbecsPinPad.DSP('Aproxime o cartao');
  fAbecsPinPad.CEX(False,False,False,False,True);
  ShowMessage('PP_EVENT: '+fAbecsPinPad.Response.GetResponseFromTagValue(PP_EVENT) + sLineBreak +
              'PP_TRK1INC: '+fAbecsPinPad.Response.GetResponseFromTagValue(PP_TRACK1) + sLineBreak +
              'PP_TRK2INC: '+fAbecsPinPad.Response.GetResponseFromTagValue(PP_TRACK2) + sLineBreak +
              'PP_TRK3INC: '+fAbecsPinPad.Response.GetResponseFromTagValue(PP_TRACK3) );

end;

procedure TForm1.btDesativarClick(Sender: TObject);
begin
  fAbecsPinPad.Disable;
end;

procedure TForm1.btDEXClick(Sender: TObject);
begin
  fAbecsPinPad.DEX('');
  fAbecsPinPad.DEX('PROJETO ACBR'+#13+'projetoacbr.com.br'+#13+'(15) 2105-0750'+#13+'LINHA 4'+#13+'LINHA 5'+#13+'LINHA 6');
end;

procedure TForm1.btDMFClick(Sender: TObject);
begin
  fAbecsPinPad.DMF('LOGOACBR');
  fAbecsPinPad.DMF(['LOGOACBR', 'AAA']);
end;

procedure TForm1.btDSIClick(Sender: TObject);
begin
  fAbecsPinPad.DSI('LOGOACBR');
//  fAbecsPinPad.DSI('352233FF');
end;

procedure TForm1.btDSPClick(Sender: TObject);
begin
  fAbecsPinPad.DSP('');
  fAbecsPinPad.DSP('PROJETO ACBR'+#13+'projetoacbr.com.br');
end;

procedure TForm1.btGCDClick(Sender: TObject);
var
  s: String;
begin
  s := fAbecsPinPad.GCD(msgDataNascimentoDDMMAAAA, 60);
  ShowMessage(s);
  s := fAbecsPinPad.GCD($0025, 5, 5);
  ShowMessage(s);
end;

procedure TForm1.btGINClick(Sender: TObject);
begin
  fAbecsPinPad.GIN(2);
  fAbecsPinPad.GIN(3);
  fAbecsPinPad.GIN;
end;

procedure TForm1.btGIXClick(Sender: TObject);
begin
  fAbecsPinPad.GIX([PP_MODEL]);
  fAbecsPinPad.GIX;
end;

procedure TForm1.btGKYClick(Sender: TObject);
var
  i: Integer;
begin
  fAbecsPinPad.DEX('Pressione'+#13+'alguma tecla'+#13+'de função');
  i := fAbecsPinPad.GKY;
  fAbecsPinPad.DSP('');
  ShowMessage(IntToStr(i));
end;

procedure TForm1.btMediaLoadClick(Sender: TObject);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create('C:\Pascal\Comp\ACBr\trunk2\Fontes\Imagens\Android\Quadrado\ACBr_192_192.png', fmOpenRead);
  try
    fAbecsPinPad.LoadMedia('LOGOACBR', FS, mtPNG);
  finally
    FS.Free;
  end;
end;

procedure TForm1.btLMFClick(Sender: TObject);
begin
  fAbecsPinPad.LMF;
end;

procedure TForm1.btMNUClick(Sender: TObject);
var
  s: String;
begin
  s := fAbecsPinPad.MNU(['1 A VISTA','2 A PRAZO','3 FIADO'],'Forma de Pagamento');
  ShowMessage(s);
end;

procedure TForm1.btOPNClick(Sender: TObject);
begin
  fAbecsPinPad.OPN;
  //fAbecsPinPad.OPN(
  //  'AE6F230563307A1FA054C0E5835D9670C2EEC4BCE9E67C10A77B3D1F637C68CFFD2307E8345'+
  //  '120084B873F2B7D7E5DE1D3383DEB18D57106E58954B0A8D8E7DCFD84ACC724FB84DAEB2A40'+
  //  '82E2CE576F4AAB0EF3522CD2ED1C5F926FFBA070BA6F78E2FFCCBF78508DBD337670F6C121B'+
  //  '2E114AD939E87880833CA7B76F850B6D7E24C472CEF6A7F766951CC68CA782D05D37E621D3A'+
  //  '7EE0A5FB5AB01437870A82664A3FCE8B3D75A64BE5DFFCF67FA4915C7A87D287E97AAB5FCA6'+
  //  '497C420840C0099F23FD089711209A31A6ED5EE9248D8C19D46F62A4EBC797143D80B85DAD4'+
  //  '7D0A485926298D81AFE23CA3D6229F3E011203713E5B74E9807CF98B71CD7D',
  //  '010001');
end;

procedure TForm1.btRMCClick(Sender: TObject);
begin
  fAbecsPinPad.RMC('OPERAÇÃO'+#13+'TERMINADA');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  HidePanelCancel;
end;

procedure TForm1.btCLOClick(Sender: TObject);
begin
  fAbecsPinPad.CLO('PROJETO ACBR'+#13+'projetoacbr.com.br');
end;

procedure TForm1.btCLXClick(Sender: TObject);
begin
  fAbecsPinPad.CLX('PROJETO ACBR'+#13+'projetoacbr.com.br'+#13+'(15) 2105-0750'+#13+'LINHA 4'+#13+'LINHA 5'+#13+'LINHA 6');
  fAbecsPinPad.CLX('LOGOACBR');
end;

end.

