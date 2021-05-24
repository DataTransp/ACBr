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

unit Coplan.Provider;

interface

uses
  SysUtils, Classes,
  ACBrXmlBase, ACBrXmlDocument, ACBrNFSeXClass, ACBrNFSeXConversao,
  ACBrNFSeXGravarXml, ACBrNFSeXLerXml,
  ACBrNFSeXProviderABRASFv2, ACBrNFSeXWebserviceBase;

type
  TACBrNFSeXWebserviceCoplan = class(TACBrNFSeXWebserviceSoap11)
  private
    function GetNamespace: string;

  public
    function Recepcionar(ACabecalho, AMSG: String): string; override;
    function RecepcionarSincrono(ACabecalho, AMSG: String): string; override;
    function GerarNFSe(ACabecalho, AMSG: String): string; override;
    function ConsultarLote(ACabecalho, AMSG: String): string; override;
    function ConsultarNFSePorRps(ACabecalho, AMSG: String): string; override;
    function ConsultarNFSePorFaixa(ACabecalho, AMSG: String): string; override;
    function ConsultarNFSeServicoPrestado(ACabecalho, AMSG: String): string; override;
    function ConsultarNFSeServicoTomado(ACabecalho, AMSG: String): string; override;
    function Cancelar(ACabecalho, AMSG: String): string; override;
    function SubstituirNFSe(ACabecalho, AMSG: String): string; override;

    property Namespace: string read GetNamespace;
  end;

  TACBrNFSeProviderCoplan = class (TACBrNFSeProviderABRASFv2)
  protected
    procedure Configuracao; override;

    function CriarGeradorXml(const ANFSe: TNFSe): TNFSeWClass; override;
    function CriarLeitorXml(const ANFSe: TNFSe): TNFSeRClass; override;
    function CriarServiceClient(const AMetodo: TMetodo): TACBrNFSeXWebservice; override;

  end;

implementation

uses
  ACBrUtil, ACBrDFeException, ACBrNFSeX, ACBrNFSeXConfiguracoes,
  ACBrNFSeXNotasFiscais, Coplan.GravarXml, Coplan.LerXml;

{ TACBrNFSeProviderCoplan }

procedure TACBrNFSeProviderCoplan.Configuracao;
begin
  inherited Configuracao;

  with ConfigAssinar do
  begin
    Rps := True;
    LoteRps := True;
    CancelarNFSe := True;
    RpsGerarNFSe := True;
    RpsSubstituirNFSe := True;
    SubstituirNFSe := True;
  end;

  with ConfigWebServices do
  begin
    VersaoDados := '2.01';
    VersaoAtrib := '2.01';
  end;

  ConfigMsgDados.DadosCabecalho := GetCabecalho('');
end;

function TACBrNFSeProviderCoplan.CriarGeradorXml(
  const ANFSe: TNFSe): TNFSeWClass;
begin
  Result := TNFSeW_Coplan.Create(Self);
  Result.NFSe := ANFSe;
end;

function TACBrNFSeProviderCoplan.CriarLeitorXml(
  const ANFSe: TNFSe): TNFSeRClass;
begin
  Result := TNFSeR_Coplan.Create(Self);
  Result.NFSe := ANFSe;
end;

function TACBrNFSeProviderCoplan.CriarServiceClient(
  const AMetodo: TMetodo): TACBrNFSeXWebservice;
begin
  if FAOwner.Configuracoes.WebServices.AmbienteCodigo = 2 then
  begin
   with ConfigWebServices.Homologacao do
    begin
      case AMetodo of
        tmRecepcionar:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, Recepcionar);
        tmConsultarSituacao:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarSituacao);
        tmConsultarLote:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarLote);
        tmConsultarNFSePorRps:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarNFSeRps);
        tmConsultarNFSe:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarNFSe);
        tmConsultarNFSeURL:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarNFSeURL);
        tmConsultarNFSePorFaixa:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarNFSePorFaixa);
        tmConsultarNFSeServicoPrestado:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarNFSeServicoPrestado);
        tmConsultarNFSeServicoTomado:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarNFSeServicoTomado);
        tmCancelarNFSe:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, CancelarNFSe);
        tmGerar:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, GerarNFSe);
        tmRecepcionarSincrono:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, RecepcionarSincrono);
        tmSubstituirNFSe:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, SubstituirNFSe);
        tmAbrirSessao:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, AbrirSessao);
        tmFecharSessao:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, FecharSessao);
      else
        // tmTeste
        Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, TesteEnvio);
      end;
    end;
  end
  else
  begin
    with ConfigWebServices.Producao do
    begin
      case AMetodo of
        tmRecepcionar:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, Recepcionar);
        tmConsultarSituacao:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarSituacao);
        tmConsultarLote:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarLote);
        tmConsultarNFSePorRps:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarNFSeRps);
        tmConsultarNFSe:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarNFSe);
        tmConsultarNFSeURL:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarNFSeURL);
        tmConsultarNFSePorFaixa:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarNFSePorFaixa);
        tmConsultarNFSeServicoPrestado:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarNFSeServicoPrestado);
        tmConsultarNFSeServicoTomado:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, ConsultarNFSeServicoTomado);
        tmCancelarNFSe:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, CancelarNFSe);
        tmGerar:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, GerarNFSe);
        tmRecepcionarSincrono:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, RecepcionarSincrono);
        tmSubstituirNFSe:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, SubstituirNFSe);
        tmAbrirSessao:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, AbrirSessao);
        tmFecharSessao:
          Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, FecharSessao);
      else
        // tmTeste
        Result := TACBrNFSeXWebserviceCoplan.Create(FAOwner, AMetodo, TesteEnvio);
      end;
    end;
  end;
end;

{ TACBrNFSeXWebserviceCoplan }

function TACBrNFSeXWebserviceCoplan.GetNamespace: string;
begin
  if FPConfiguracoes.WebServices.AmbienteCodigo = 1 then
    Result := 'Tributario_PRODUCAO_FULL'
  else
    Result := 'TributarioGx16New';

  Result := 'xmlns:trib1="' + Result + '"';
end;

function TACBrNFSeXWebserviceCoplan.Recepcionar(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<trib:nfse_web_service.RECEPCIONARLOTERPS>';
  Request := Request + '<trib:Recepcionarloterpsrequest>';
  Request := Request + '<trib1:nfseCabecMsg>' + IncluirCDATA(ACabecalho) + '</trib1:nfseCabecMsg>';
  Request := Request + '<trib1:nfseDadosMsg>' + IncluirCDATA(AMSG) + '</trib1:nfseDadosMsg>';
  Request := Request + '</trib:Recepcionarloterpsrequest>';
  Request := Request + '</trib:nfse_web_service.RECEPCIONARLOTERPS>';

  Result := Executar('Tributarioaction/ANFSE_WEB_SERVICE.RECEPCIONARLOTERPS', Request,
                     ['Recepcionarloterpsresponse', 'outputXML', 'EnviarLoteRpsResposta'],
                     ['xmlns:trib="Tributario"', NameSpace]);
end;

function TACBrNFSeXWebserviceCoplan.RecepcionarSincrono(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<trib:nfse_web_service.RECEPCIONARLOTERPSSINCRONO>';
  Request := Request + '<trib:Recepcionarloterpssincronorequest>';
  Request := Request + '<trib1:nfseCabecMsg>' + IncluirCDATA(ACabecalho) + '</trib1:nfseCabecMsg>';
  Request := Request + '<trib1:nfseDadosMsg>' + IncluirCDATA(AMSG) + '</trib1:nfseDadosMsg>';
  Request := Request + '</trib:Recepcionarloterpssincronorequest>';
  Request := Request + '</trib:nfse_web_service.RECEPCIONARLOTERPSSINCRONO>';

  Result := Executar('Tributarioaction/ANFSE_WEB_SERVICE.RECEPCIONARLOTERPSSINCRONO', Request,
                     ['Recepcionarloterpssincronoresponse', 'outputXML', 'EnviarLoteRpsSincronoResposta'],
                     ['xmlns:trib="Tributario"', NameSpace]);
end;

function TACBrNFSeXWebserviceCoplan.GerarNFSe(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<trib:nfse_web_service.GERARNFSE>';
  Request := Request + '<trib:Gerarnfserequest>';
  Request := Request + '<trib1:nfseCabecMsg>' + IncluirCDATA(ACabecalho) + '</trib1:nfseCabecMsg>';
  Request := Request + '<trib1:nfseDadosMsg>' + IncluirCDATA(AMSG) + '</trib1:nfseDadosMsg>';
  Request := Request + '</trib:Gerarnfserequest>';
  Request := Request + '</trib:nfse_web_service.GERARNFSE>';

  Result := Executar('Tributarioaction/ANFSE_WEB_SERVICE.GERARNFSE', Request,
                     ['Gerarnfseresponse', 'outputXML', 'GerarNfseResposta'],
                     ['xmlns:trib="Tributario"', NameSpace]);
end;

function TACBrNFSeXWebserviceCoplan.ConsultarLote(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<trib:nfse_web_service.CONSULTARLOTERPS>';
  Request := Request + '<trib:Consultarloterpsrequest>';
  Request := Request + '<trib1:nfseCabecMsg>' + IncluirCDATA(ACabecalho) + '</trib1:nfseCabecMsg>';
  Request := Request + '<trib1:nfseDadosMsg>' + IncluirCDATA(AMSG) + '</trib1:nfseDadosMsg>';
  Request := Request + '</trib:Consultarloterpsrequest>';
  Request := Request + '</trib:nfse_web_service.CONSULTARLOTERPS>';

  Result := Executar('Tributarioaction/ANFSE_WEB_SERVICE.CONSULTARLOTERPS', Request,
                     ['Consultarloterpsresponse', 'outputXML', 'ConsultarLoteRpsResposta'],
                     ['xmlns:trib="Tributario"', NameSpace]);
end;

function TACBrNFSeXWebserviceCoplan.ConsultarNFSePorFaixa(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<trib:nfse_web_service.CONSULTARNFSEFAIXA>';
  Request := Request + '<trib:Consultarnfseporfaixarequest>';
  Request := Request + '<trib1:nfseCabecMsg>' + IncluirCDATA(ACabecalho) + '</trib1:nfseCabecMsg>';
  Request := Request + '<trib1:nfseDadosMsg>' + IncluirCDATA(AMSG) + '</trib1:nfseDadosMsg>';
  Request := Request + '</trib:Consultarnfseporfaixarequest>';
  Request := Request + '</trib:nfse_web_service.CONSULTARNFSEFAIXA>';

  Result := Executar('Tributarioaction/ANFSE_WEB_SERVICE.CONSULTARNFSEFAIXA', Request,
                     ['Consultarnfseporfaixaresponse', 'outputXML', 'ConsultarNfseFaixaResposta'],
                     ['xmlns:trib="Tributario"', NameSpace]);
  {
    os campos <Codigo>, <Mensagem> e <Correcao> est�o dentro do grupo:
       <ConsultarNfseFaixaResposta> em vez de <MensagemRetorno>
    Vai ser necess�rio estudar a melhor forma de resolver esse problema
  }
end;

function TACBrNFSeXWebserviceCoplan.ConsultarNFSePorRps(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<trib:nfse_web_service.CONSULTARNFSEPORRPS>';
  Request := Request + '<trib:Consultarnfseporrpsrequest>';
  Request := Request + '<trib1:nfseCabecMsg>' + IncluirCDATA(ACabecalho) + '</trib1:nfseCabecMsg>';
  Request := Request + '<trib1:nfseDadosMsg>' + IncluirCDATA(AMSG) + '</trib1:nfseDadosMsg>';
  Request := Request + '</trib:Consultarnfseporrpsrequest>';
  Request := Request + '</trib:nfse_web_service.CONSULTARNFSEPORRPS>';

  Result := Executar('Tributarioaction/ANFSE_WEB_SERVICE.CONSULTARNFSEPORRPS', Request,
                     ['Consultarnfseporrpsresponse', 'outputXML', 'ConsultarNfseRpsResposta'],
                     ['xmlns:trib="Tributario"', NameSpace]);
end;

function TACBrNFSeXWebserviceCoplan.ConsultarNFSeServicoPrestado(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<trib:nfse_web_service.CONSULTARNFSESERVICOPRESTADO>';
  Request := Request + '<trib:Consultarnfseservicoprestadorequest>';
  Request := Request + '<trib1:nfseCabecMsg>' + IncluirCDATA(ACabecalho) + '</trib1:nfseCabecMsg>';
  Request := Request + '<trib1:nfseDadosMsg>' + IncluirCDATA(AMSG) + '</trib1:nfseDadosMsg>';
  Request := Request + '</trib:Consultarnfseservicoprestadorequest>';
  Request := Request + '</trib:nfse_web_service.CONSULTARNFSESERVICOPRESTADO>';

  Result := Executar('Tributarioaction/ANFSE_WEB_SERVICE.CONSULTARNFSESERVICOPRESTADO', Request,
                     ['Consultarnfseservicoprestadoresponse', 'outputXML', 'ConsultarNfseServicoPrestadoResposta'],
                     ['xmlns:trib="Tributario"', NameSpace]);
end;

function TACBrNFSeXWebserviceCoplan.ConsultarNFSeServicoTomado(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<trib:nfse_web_service.CONSULTARNFSESERVICOTOMADO>';
  Request := Request + '<trib:Consultarnfseservicotomadorequest>';
  Request := Request + '<trib1:nfseCabecMsg>' + IncluirCDATA(ACabecalho) + '</trib1:nfseCabecMsg>';
  Request := Request + '<trib1:nfseDadosMsg>' + IncluirCDATA(AMSG) + '</trib1:nfseDadosMsg>';
  Request := Request + '</trib:Consultarnfseservicotomadorequest>';
  Request := Request + '</trib:nfse_web_service.CONSULTARNFSESERVICOTOMADO>';

  Result := Executar('Tributarioaction/ANFSE_WEB_SERVICE.CONSULTARNFSESERVICOTOMADO', Request,
                     ['Consultarnfseservicotomadoresponse', 'outputXML', 'ConsultarNfseServicoTomadoResposta'],
                     ['xmlns:trib="Tributario"', NameSpace]);
end;

function TACBrNFSeXWebserviceCoplan.Cancelar(ACabecalho, AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<trib:nfse_web_service.CANCELARNFSE>';
  Request := Request + '<trib:Cancelarnfserequest>';
  Request := Request + '<trib1:nfseCabecMsg>' + IncluirCDATA(ACabecalho) + '</trib1:nfseCabecMsg>';
  Request := Request + '<trib1:nfseDadosMsg>' + IncluirCDATA(AMSG) + '</trib1:nfseDadosMsg>';
  Request := Request + '</trib:Cancelarnfserequest>';
  Request := Request + '</trib:nfse_web_service.CANCELARNFSE>';

  Result := Executar('Tributarioaction/ANFSE_WEB_SERVICE.CANCELARNFSE', Request,
                     ['Cancelarnfseresponse', 'outputXML', 'CancelarNfseResposta'],
                     ['xmlns:trib="Tributario"', NameSpace]);
end;

function TACBrNFSeXWebserviceCoplan.SubstituirNFSe(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<trib:nfse_web_service.SUBSTITUIRNFSE>';
  Request := Request + '<trib:Substituirnfserequest>';
  Request := Request + '<trib1:nfseCabecMsg>' + IncluirCDATA(ACabecalho) + '</trib1:nfseCabecMsg>';
  Request := Request + '<trib1:nfseDadosMsg>' + IncluirCDATA(AMSG) + '</trib1:nfseDadosMsg>';
  Request := Request + '</trib:Substituirnfserequest>';
  Request := Request + '</trib:nfse_web_service.SUBSTITUIRNFSE>';

  Result := Executar('Tributarioaction/ANFSE_WEB_SERVICE.SUBSTITUIRNFSE', Request,
                     ['Substituirnfseresponse', 'outputXML', 'SubstituirNfseResposta'],
                     ['xmlns:trib="Tributario"', NameSpace]);
end;

end.
