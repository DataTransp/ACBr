{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Italo Giurizzato Junior                         }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida - daniel@projetoacbr.com.br - www.projetoacbr.com.br}
{       Rua Coronel Aureliano de Camargo, 963 - Tatu� - SP - 18270-170         }
{******************************************************************************}

{$I ACBr.inc}

unit SimplISS.Provider;

interface

uses
  SysUtils, Classes, ACBrNFSeXClass, ACBrNFSeXConversao,
  ACBrNFSeXGravarXml, ACBrNFSeXLerXml,
  ACBrNFSeXProviderABRASFv1, ACBrNFSeXProviderABRASFv2,
  ACBrNFSeXWebserviceBase, ACBrNFSeXWebservicesResponse;

type
  TACBrNFSeXWebserviceSimplISS = class(TACBrNFSeXWebserviceSoap11)
  private
    function GetDadosUsuario: string;
    function AjustarMensagem(AMSG: string; ATags: array of string): string;

  public
    function Recepcionar(ACabecalho, AMSG: String): string; override;
    function ConsultarLote(ACabecalho, AMSG: String): string; override;
    function ConsultarSituacao(ACabecalho, AMSG: String): string; override;
    function ConsultarNFSePorRps(ACabecalho, AMSG: String): string; override;
    function ConsultarNFSe(ACabecalho, AMSG: String): string; override;
    function Cancelar(ACabecalho, AMSG: String): string; override;

    property DadosUsuario: string read GetDadosUsuario;
  end;

  TACBrNFSeProviderSimplISS = class (TACBrNFSeProviderABRASFv1)
  protected
    procedure Configuracao; override;

    function CriarGeradorXml(const ANFSe: TNFSe): TNFSeWClass; override;
    function CriarLeitorXml(const ANFSe: TNFSe): TNFSeRClass; override;
    function CriarServiceClient(const AMetodo: TMetodo): TACBrNFSeXWebservice; override;

  end;

  TACBrNFSeXWebserviceSimplISSv2 = class(TACBrNFSeXWebserviceSoap11)
  public
    function Recepcionar(ACabecalho, AMSG: String): string; override;
    function GerarNFSe(ACabecalho, AMSG: String): string; override;
    function ConsultarLote(ACabecalho, AMSG: String): string; override;
    function ConsultarNFSePorRps(ACabecalho, AMSG: String): string; override;
    function ConsultarNFSePorFaixa(ACabecalho, AMSG: String): string; override;
    function ConsultarNFSeServicoPrestado(ACabecalho, AMSG: String): string; override;
    function ConsultarNFSeServicoTomado(ACabecalho, AMSG: String): string; override;
    function Cancelar(ACabecalho, AMSG: String): string; override;
    function SubstituirNFSe(ACabecalho, AMSG: String): string; override;

  end;

  TACBrNFSeProviderSimplISSv2 = class (TACBrNFSeProviderABRASFv2)
  protected
    procedure Configuracao; override;

    function CriarGeradorXml(const ANFSe: TNFSe): TNFSeWClass; override;
    function CriarLeitorXml(const ANFSe: TNFSe): TNFSeRClass; override;
    function CriarServiceClient(const AMetodo: TMetodo): TACBrNFSeXWebservice; override;

  end;

implementation

uses
  ACBrUtil,  ACBrNFSeX, ACBrNFSeXConfiguracoes,
  ACBrXmlBase, ACBrXmlDocument, SimplISS.GravarXml, SimplISS.LerXml;

{ TACBrNFSeProviderSimplISS }

procedure TACBrNFSeProviderSimplISS.Configuracao;
begin
  inherited Configuracao;

  with ConfigGeral do
  begin
    {italo
    Prefixo3      := 'nfse';
    Prefixo4      := 'nfse';
    }
    Identificador := 'id';
  end;

  SetXmlNameSpace('http://www.sistema.com.br/Nfse/arquivos/nfse_3.xsd');

  {italo
  with ConfigMsgDados do
  begin
    GerarVersao := False;
    Prefixo3Tag := 'nfse';

    with LoteRps do
    begin
      GerarID := True;
      GerarP3LoteRps := True;
    end;

    with ConsSit do
    begin
      GerarP3Prestador := True;
    end;

    with ConsLote do
    begin
      GerarP3Prestador := True;
    end;

    with ConsNFSeRps do
    begin
      GerarP3IdentificacaoRps := True;
      GerarP3Prestador        := True;
    end;

    with ConsNFSe do
    begin
      GerarP3Prestador := True;
    end;

    with Cancelar do
    begin
      GerarP4InfPedCanc := True;
    end;
  end;
  }
  SetNomeXSD('nfse_3.xsd');
end;

function TACBrNFSeProviderSimplISS.CriarGeradorXml(
  const ANFSe: TNFSe): TNFSeWClass;
begin
  Result := TNFSeW_SimplISS.Create(Self);
  Result.NFSe := ANFSe;
end;

function TACBrNFSeProviderSimplISS.CriarLeitorXml(
  const ANFSe: TNFSe): TNFSeRClass;
begin
  Result := TNFSeR_SimplISS.Create(Self);
  Result.NFSe := ANFSe;
end;

function TACBrNFSeProviderSimplISS.CriarServiceClient(
  const AMetodo: TMetodo): TACBrNFSeXWebservice;
begin
  if FAOwner.Configuracoes.WebServices.AmbienteCodigo = 2 then
  begin
   with ConfigWebServices.Homologacao do
    begin
      case AMetodo of
        tmRecepcionar:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, Recepcionar);
        tmConsultarSituacao:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarSituacao);
        tmConsultarLote:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarLote);
        tmConsultarNFSePorRps:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarNFSeRps);
        tmConsultarNFSe:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarNFSe);
        tmConsultarNFSeURL:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarNFSeURL);
        tmConsultarNFSePorFaixa:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarNFSePorFaixa);
        tmConsultarNFSeServicoPrestado:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarNFSeServicoPrestado);
        tmConsultarNFSeServicoTomado:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarNFSeServicoTomado);
        tmCancelarNFSe:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, CancelarNFSe);
        tmGerar:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, GerarNFSe);
        tmRecepcionarSincrono:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, RecepcionarSincrono);
        tmSubstituirNFSe:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, SubstituirNFSe);
        tmAbrirSessao:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, AbrirSessao);
        tmFecharSessao:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, FecharSessao);
      else
        // tmTeste
        Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, TesteEnvio);
      end;
    end;
  end
  else
  begin
    with ConfigWebServices.Producao do
    begin
      case AMetodo of
        tmRecepcionar:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, Recepcionar);
        tmConsultarSituacao:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarSituacao);
        tmConsultarLote:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarLote);
        tmConsultarNFSePorRps:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarNFSeRps);
        tmConsultarNFSe:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarNFSe);
        tmConsultarNFSeURL:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarNFSeURL);
        tmConsultarNFSePorFaixa:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarNFSePorFaixa);
        tmConsultarNFSeServicoPrestado:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarNFSeServicoPrestado);
        tmConsultarNFSeServicoTomado:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, ConsultarNFSeServicoTomado);
        tmCancelarNFSe:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, CancelarNFSe);
        tmGerar:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, GerarNFSe);
        tmRecepcionarSincrono:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, RecepcionarSincrono);
        tmSubstituirNFSe:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, SubstituirNFSe);
        tmAbrirSessao:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, AbrirSessao);
        tmFecharSessao:
          Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, FecharSessao);
      else
        // tmTeste
        Result := TACBrNFSeXWebserviceSimplISS.Create(FAOwner, AMetodo, TesteEnvio);
      end;
    end;
  end;
end;

{ TACBrNFSeXWebserviceSimplISS }

function TACBrNFSeXWebserviceSimplISS.GetDadosUsuario: string;
begin
  with TACBrNFSeX(FPDFeOwner).Configuracoes.Geral do
  begin
    Result := '<sis:pParam>' +
                '<sis1:P1>' + Emitente.WSUser + '</sis1:P1>' +
                '<sis1:P2>' + Emitente.WSSenha + '</sis1:P2>' +
              '</sis:pParam>';
  end;
end;

function TACBrNFSeXWebserviceSimplISS.AjustarMensagem(AMSG: string; ATags: array of string): string;
Var
  ADoc: TACBrXmlDocument;
  ANode: TACBrXmlNode;
  I: Integer;
  TagName: string;
begin
  Result := '';

  ADoc := TACBrXmlDocument.Create;
  try
    ADoc.LoadFromXml(AMSG);
    ANode := ADoc.Root;
    for I := Low(ATags) to High(ATags) do
      ANode := ANode.Childrens.FindAnyNs(ATags[I]);

    ANode.Namespaces.Add('http://www.sistema.com.br/Nfse/arquivos/nfse_3.xsd', 'nfse');
    ApplyNamespacePrefix(ANode, 'nfse', ['']);

    TagName := ADoc.Root.LocalName;

    Result := ADoc.Xml;

    if Pos('nfse:' + TagName, Result) > 0 then
      Result := StringReplace(Result, 'nfse:' + TagName, 'sis:' + TagName, [rfReplaceAll])
    else
      Result := StringReplace(Result, tagName, 'sis:' + TagName, [rfReplaceAll]);
  finally
    ADoc.Destroy;
  end;
end;

function TACBrNFSeXWebserviceSimplISS.Recepcionar(ACabecalho, AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<sis:RecepcionarLoteRps>';
  Request := Request + AjustarMensagem(AMSG, ['LoteRps']);
  Request := Request + DadosUsuario;
  Request := Request + '</sis:RecepcionarLoteRps>';

  Result := Executar('http://www.sistema.com.br/Sistema.Ws.Nfse/INfseService/RecepcionarLoteRps',
                     Request,
                     ['RecepcionarLoteRpsResponse', 'RecepcionarLoteRpsResult'],
                     ['xmlns:sis="http://www.sistema.com.br/Sistema.Ws.Nfse"',
                      'xmlns:sis1="http://www.sistema.com.br/Sistema.Ws.Nfse.Cn"']);
end;

function TACBrNFSeXWebserviceSimplISS.ConsultarSituacao(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<sis:ConsultarSituacaoLoteRps>';
  Request := Request + XmlToStr(AMSG);
  Request := Request + DadosUsuario;
  Request := Request + '</sis:ConsultarSituacaoLoteRps>';

  Result := Executar('http://www.sistema.com.br/Sistema.Ws.Nfse/INfseService/ConsultarSituacaoLoteRps',
                     Request,
                     ['ConsultarSituacaoLoteRpsResponse', 'ConsultarSituacaoLoteRpsResult'],
                     ['xmlns:sis="http://www.sistema.com.br/Sistema.Ws.Nfse"',
                      'xmlns:sis1="http://www.sistema.com.br/Sistema.Ws.Nfse.Cn"',
            'xmlns:nfse="http://www.sistema.com.br/Nfse/arquivos/nfse_3.xsd"']);
end;

function TACBrNFSeXWebserviceSimplISS.ConsultarLote(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<sis:ConsultarLoteRps>';
  Request := Request + XmlToStr(AMSG);
  Request := Request + DadosUsuario;
  Request := Request + '</sis:ConsultarLoteRps>';

  Result := Executar('http://www.sistema.com.br/Sistema.Ws.Nfse/INfseService/ConsultarLoteRps',
                     Request,
                     ['ConsultarLoteRpsResponse', 'ConsultarLoteRpsResult'],
                     ['xmlns:sis="http://www.sistema.com.br/Sistema.Ws.Nfse"',
                      'xmlns:sis1="http://www.sistema.com.br/Sistema.Ws.Nfse.Cn"',
            'xmlns:nfse="http://www.sistema.com.br/Nfse/arquivos/nfse_3.xsd"']);
end;

function TACBrNFSeXWebserviceSimplISS.ConsultarNFSePorRps(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<sis:ConsultarNfsePorRps>';
  Request := Request + XmlToStr(AMSG);
  Request := Request + DadosUsuario;
  Request := Request + '</sis:ConsultarNfsePorRps>';

  Result := Executar('http://www.sistema.com.br/Sistema.Ws.Nfse/INfseService/ConsultarNfsePorRps',
                     Request,
                     ['ConsultarNfsePorRpsResponse', 'ConsultarNfsePorRpsResult'],
                     ['xmlns:sis="http://www.sistema.com.br/Sistema.Ws.Nfse"',
                      'xmlns:sis1="http://www.sistema.com.br/Sistema.Ws.Nfse.Cn"',
            'xmlns:nfse="http://www.sistema.com.br/Nfse/arquivos/nfse_3.xsd"']);
end;

function TACBrNFSeXWebserviceSimplISS.ConsultarNFSe(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<sis:ConsultarNfse>';
  Request := Request + XmlToStr(AMSG);
  Request := Request + DadosUsuario;
  Request := Request + '</sis:ConsultarNfse>';

  Result := Executar('http://www.sistema.com.br/Sistema.Ws.Nfse/INfseService/ConsultarNfse',
                     Request,
                     ['ConsultarNfseResponse', 'ConsultarNfseResult'],
                     ['xmlns:sis="http://www.sistema.com.br/Sistema.Ws.Nfse"',
                      'xmlns:sis1="http://www.sistema.com.br/Sistema.Ws.Nfse.Cn"',
            'xmlns:nfse="http://www.sistema.com.br/Nfse/arquivos/nfse_3.xsd"']);
end;

function TACBrNFSeXWebserviceSimplISS.Cancelar(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<sis:CancelarNfse>';
  Request := Request + XmlToStr(AMSG);
  Request := Request + DadosUsuario;
  Request := Request + '</sis:CancelarNfse>';

  Result := Executar('http://www.sistema.com.br/Sistema.Ws.Nfse/INfseService/CancelarNfse',
                     Request,
                     ['CancelarNfseResponse', 'CancelarNfseResult'],
                     ['xmlns:sis="http://www.sistema.com.br/Sistema.Ws.Nfse"',
                      'xmlns:sis1="http://www.sistema.com.br/Sistema.Ws.Nfse.Cn"',
            'xmlns:nfse="http://www.sistema.com.br/Nfse/arquivos/nfse_3.xsd"']);
end;

{ TACBrNFSeProviderSimplISSv2 }

procedure TACBrNFSeProviderSimplISSv2.Configuracao;
begin
  inherited Configuracao;

  ConfigGeral.ModoEnvio := meLoteAssincrono;

  with ConfigAssinar do
  begin
    Rps := True;
    LoteRps := True;
    RpsGerarNFSe := True;
  end;

  with ConfigWebServices do
  begin
    VersaoDados := '2.03';
    VersaoAtrib := '2.03';
  end;

  with ConfigMsgDados do
  begin
    DadosCabecalho := '<cabecalho versao="2.03" xmlns="http://www.abrasf.org.br/nfse.xsd">' +
                      '<versaoDados>2.03</versaoDados>' +
                      '</cabecalho>';
  end;
end;

function TACBrNFSeProviderSimplISSv2.CriarGeradorXml(
  const ANFSe: TNFSe): TNFSeWClass;
begin
  Result := TNFSeW_SimplISSv2.Create(Self);
  Result.NFSe := ANFSe;
end;

function TACBrNFSeProviderSimplISSv2.CriarLeitorXml(
  const ANFSe: TNFSe): TNFSeRClass;
begin
  Result := TNFSeR_SimplISSv2.Create(Self);
  Result.NFSe := ANFSe;
end;

function TACBrNFSeProviderSimplISSv2.CriarServiceClient(
  const AMetodo: TMetodo): TACBrNFSeXWebservice;
begin
  if FAOwner.Configuracoes.WebServices.AmbienteCodigo = 2 then
  begin
   with ConfigWebServices.Homologacao do
    begin
      case AMetodo of
        tmRecepcionar:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, Recepcionar);
        tmConsultarSituacao:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarSituacao);
        tmConsultarLote:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarLote);
        tmConsultarNFSePorRps:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarNFSeRps);
        tmConsultarNFSe:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarNFSe);
        tmConsultarNFSeURL:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarNFSeURL);
        tmConsultarNFSePorFaixa:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarNFSePorFaixa);
        tmConsultarNFSeServicoPrestado:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarNFSeServicoPrestado);
        tmConsultarNFSeServicoTomado:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarNFSeServicoTomado);
        tmCancelarNFSe:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, CancelarNFSe);
        tmGerar:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, GerarNFSe);
        tmRecepcionarSincrono:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, RecepcionarSincrono);
        tmSubstituirNFSe:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, SubstituirNFSe);
        tmAbrirSessao:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, AbrirSessao);
        tmFecharSessao:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, FecharSessao);
      else
        // tmTeste
        Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, TesteEnvio);
      end;
    end;
  end
  else
  begin
    with ConfigWebServices.Producao do
    begin
      case AMetodo of
        tmRecepcionar:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, Recepcionar);
        tmConsultarSituacao:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarSituacao);
        tmConsultarLote:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarLote);
        tmConsultarNFSePorRps:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarNFSeRps);
        tmConsultarNFSe:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarNFSe);
        tmConsultarNFSeURL:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarNFSeURL);
        tmConsultarNFSePorFaixa:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarNFSePorFaixa);
        tmConsultarNFSeServicoPrestado:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarNFSeServicoPrestado);
        tmConsultarNFSeServicoTomado:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, ConsultarNFSeServicoTomado);
        tmCancelarNFSe:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, CancelarNFSe);
        tmGerar:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, GerarNFSe);
        tmRecepcionarSincrono:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, RecepcionarSincrono);
        tmSubstituirNFSe:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, SubstituirNFSe);
        tmAbrirSessao:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, AbrirSessao);
        tmFecharSessao:
          Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, FecharSessao);
      else
        // tmTeste
        Result := TACBrNFSeXWebserviceSimplISSv2.Create(FAOwner, AMetodo, TesteEnvio);
      end;
    end;
  end;
end;

{ TACBrNFSeXWebserviceSimplISSv2 }

function TACBrNFSeXWebserviceSimplISSv2.Recepcionar(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfse:RecepcionarLoteRpsRequest>';
  Request := Request + '<nfseCabecMsg>' + XmlToStr(ACabecalho) + '</nfseCabecMsg>';
  Request := Request + '<nfseDadosMsg>' + XmlToStr(AMSG) + '</nfseDadosMsg>';
  Request := Request + '</nfse:RecepcionarLoteRpsRequest>';

  Result := Executar('http://nfse.abrasf.org.br/INfseService/RecepcionarLoteRps', Request,
                     ['outputXML', 'EnviarLoteRpsResposta'],
                     ['xmlns:nfse="http://nfse.abrasf.org.br"']);
end;

function TACBrNFSeXWebserviceSimplISSv2.GerarNFSe(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfse:GerarNfseRequest>';
  Request := Request + '<nfseCabecMsg>' + XmlToStr(ACabecalho) + '</nfseCabecMsg>';
  Request := Request + '<nfseDadosMsg>' + XmlToStr(AMSG) + '</nfseDadosMsg>';
  Request := Request + '</nfse:GerarNfseRequest>';

  Result := Executar('http://nfse.abrasf.org.br/INfseService/GerarNfse', Request,
                     ['outputXML', 'GerarNfseResposta'],
                     ['xmlns:nfse="http://nfse.abrasf.org.br"']);
end;

function TACBrNFSeXWebserviceSimplISSv2.ConsultarLote(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfse:ConsultarLoteRpsRequest>';
  Request := Request + '<nfseCabecMsg>' + XmlToStr(ACabecalho) + '</nfseCabecMsg>';
  Request := Request + '<nfseDadosMsg>' + XmlToStr(AMSG) + '</nfseDadosMsg>';
  Request := Request + '</nfse:ConsultarLoteRpsRequest>';

  Result := Executar('http://nfse.abrasf.org.br/INfseService/ConsultarLoteRps', Request,
                     ['outputXML', 'ConsultarLoteRpsResposta'],
                     ['xmlns:nfse="http://nfse.abrasf.org.br"']);
end;

function TACBrNFSeXWebserviceSimplISSv2.ConsultarNFSePorFaixa(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfse:ConsultarNfseFaixaRequest>';
  Request := Request + '<nfseCabecMsg>' + XmlToStr(ACabecalho) + '</nfseCabecMsg>';
  Request := Request + '<nfseDadosMsg>' + XmlToStr(AMSG) + '</nfseDadosMsg>';
  Request := Request + '</nfse:ConsultarNfseFaixaRequest>';

  Result := Executar('http://nfse.abrasf.org.br/INfseService/ConsultarNfseFaixa', Request,
                     ['outputXML', 'ConsultarNfseFaixaResposta'],
                     ['xmlns:nfse="http://nfse.abrasf.org.br"']);
end;

function TACBrNFSeXWebserviceSimplISSv2.ConsultarNFSePorRps(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfse:ConsultarNfseRpsRequest>';
  Request := Request + '<nfseCabecMsg>' + XmlToStr(ACabecalho) + '</nfseCabecMsg>';
  Request := Request + '<nfseDadosMsg>' + XmlToStr(AMSG) + '</nfseDadosMsg>';
  Request := Request + '</nfse:ConsultarNfseRpsRequest>';

  Result := Executar('http://nfse.abrasf.org.br/INfseService/ConsultarNfseRps', Request,
                     ['outputXML', 'ConsultarNfseRpsResposta'],
                     ['xmlns:nfse="http://nfse.abrasf.org.br"']);
end;

function TACBrNFSeXWebserviceSimplISSv2.ConsultarNFSeServicoPrestado(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfse:ConsultarNfseServicoPrestadoRequest>';
  Request := Request + '<nfseCabecMsg>' + XmlToStr(ACabecalho) + '</nfseCabecMsg>';
  Request := Request + '<nfseDadosMsg>' + XmlToStr(AMSG) + '</nfseDadosMsg>';
  Request := Request + '</nfse:ConsultarNfseServicoPrestadoRequest>';

  Result := Executar('http://nfse.abrasf.org.br/INfseService/ConsultarNfseServicoPrestado', Request,
                     ['outputXML', 'ConsultarNfseServicoPrestadoResposta'],
                     ['xmlns:nfse="http://nfse.abrasf.org.br"']);
end;

function TACBrNFSeXWebserviceSimplISSv2.ConsultarNFSeServicoTomado(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfse:ConsultarNfseServicoTomadoRequest>';
  Request := Request + '<nfseCabecMsg>' + XmlToStr(ACabecalho) + '</nfseCabecMsg>';
  Request := Request + '<nfseDadosMsg>' + XmlToStr(AMSG) + '</nfseDadosMsg>';
  Request := Request + '</nfse:ConsultarNfseServicoTomadoRequest>';

  Result := Executar('http://nfse.abrasf.org.br/INfseService/ConsultarNfseServicoTomado', Request,
                     ['outputXML', 'ConsultarNfseServicoTomadoResposta'],
                     ['xmlns:nfse="http://nfse.abrasf.org.br"']);
end;

function TACBrNFSeXWebserviceSimplISSv2.Cancelar(ACabecalho, AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfse:CancelarNfseRequest>';
  Request := Request + '<nfseCabecMsg>' + XmlToStr(ACabecalho) + '</nfseCabecMsg>';
  Request := Request + '<nfseDadosMsg>' + XmlToStr(AMSG) + '</nfseDadosMsg>';
  Request := Request + '</nfse:CancelarNfseRequest>';

  Result := Executar('http://nfse.abrasf.org.br/INfseService/CancelarNfse', Request,
                     ['outputXML', 'CancelarNfseResposta'],
                     ['xmlns:nfse="http://nfse.abrasf.org.br"']);
end;

function TACBrNFSeXWebserviceSimplISSv2.SubstituirNFSe(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfse:SubstituirNfseRequest>';
  Request := Request + '<nfseCabecMsg>' + XmlToStr(ACabecalho) + '</nfseCabecMsg>';
  Request := Request + '<nfseDadosMsg>' + XmlToStr(AMSG) + '</nfseDadosMsg>';
  Request := Request + '</nfse:SubstituirNfseRequest>';

  Result := Executar('http://nfse.abrasf.org.br/INfseService/SubstituirNfse', Request,
                     ['outputXML', 'SubstituirNfseResposta'],
                     ['xmlns:nfse="http://nfse.abrasf.org.br"']);
end;

{
  Para a vers�o 1 desse provedor todas as tags recebem prefixo, inclusive as
  referente a montagem do lote de envio, por exemplo.
}
end.
