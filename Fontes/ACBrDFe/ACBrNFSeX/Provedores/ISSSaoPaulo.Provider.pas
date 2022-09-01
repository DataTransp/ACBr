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

unit ISSSaoPaulo.Provider;

interface

uses
  SysUtils, Classes, Variants,
  ACBrDFeSSL,
  ACBrXmlBase, ACBrXmlDocument,
  ACBrNFSeXNotasFiscais,
  ACBrNFSeXClass, ACBrNFSeXConversao,
  ACBrNFSeXGravarXml, ACBrNFSeXLerXml,
  ACBrNFSeXProviderProprio,
  ACBrNFSeXWebserviceBase, ACBrNFSeXWebservicesResponse;

type
  TACBrNFSeXWebserviceISSSaoPaulo = class(TACBrNFSeXWebserviceSoap11)
  public
    function Recepcionar(ACabecalho, AMSG: String): string; override;
    function GerarNFSe(ACabecalho, AMSG: String): string; override;
    function TesteEnvio(ACabecalho, AMSG: String): string; override;
    function ConsultarSituacao(ACabecalho, AMSG: String): string; override;
    function ConsultarLote(ACabecalho, AMSG: String): string; override;
    function ConsultarNFSePorRps(ACabecalho, AMSG: String): string; override;
    function ConsultarNFSe(ACabecalho, AMSG: String): string; override;
    function Cancelar(ACabecalho, AMSG: String): string; override;

    function TratarXmlRetornado(const aXML: string): string; override;
  end;

  TACBrNFSeProviderISSSaoPaulo = class (TACBrNFSeProviderProprio)
  protected
    procedure Configuracao; override;

    procedure AssinaturaAdicional(Nota: TNotaFiscal);

    function CriarGeradorXml(const ANFSe: TNFSe): TNFSeWClass; override;
    function CriarLeitorXml(const ANFSe: TNFSe): TNFSeRClass; override;
    function CriarServiceClient(const AMetodo: TMetodo): TACBrNFSeXWebservice; override;

    procedure PrepararEmitir(Response: TNFSeEmiteResponse); override;
    procedure TratarRetornoEmitir(Response: TNFSeEmiteResponse); override;

    procedure PrepararConsultaSituacao(Response: TNFSeConsultaSituacaoResponse); override;
    procedure TratarRetornoConsultaSituacao(Response: TNFSeConsultaSituacaoResponse); override;

    procedure PrepararConsultaLoteRps(Response: TNFSeConsultaLoteRpsResponse); override;
    procedure TratarRetornoConsultaLoteRps(Response: TNFSeConsultaLoteRpsResponse); override;

    procedure PrepararConsultaNFSeporRps(Response: TNFSeConsultaNFSeporRpsResponse); override;
    procedure TratarRetornoConsultaNFSeporRps(Response: TNFSeConsultaNFSeporRpsResponse); override;

    procedure PrepararConsultaNFSe(Response: TNFSeConsultaNFSeResponse); override;
    procedure TratarRetornoConsultaNFSe(Response: TNFSeConsultaNFSeResponse); override;

    procedure PrepararCancelaNFSe(Response: TNFSeCancelaNFSeResponse); override;
    procedure TratarRetornoCancelaNFSe(Response: TNFSeCancelaNFSeResponse); override;

    procedure ProcessarMensagemErros(RootNode: TACBrXmlNode;
                                     Response: TNFSeWebserviceResponse;
                                     const AListTag: string = '';
                                     const AMessageTag: string = 'Erro'); override;

    function LerChaveNFe(ANode: TACBrXmlNode): string;
    function LerChaveRPS(ANode: TACBrXmlNode): string;
  end;

implementation

uses
  ACBrDFeException,
  ACBrUtil.Base, ACBrUtil.Strings, ACBrUtil.XMLHTML,
  ACBrNFSeX, ACBrNFSeXConfiguracoes, ACBrNFSeXConsts,
  ISSSaoPaulo.GravarXml, ISSSaoPaulo.LerXml;

{ TACBrNFSeProviderISSSaoPaulo }

procedure TACBrNFSeProviderISSSaoPaulo.AssinaturaAdicional(Nota: TNotaFiscal);
var
  sSituacao, sISSRetido, sCPFCNPJTomador, sIndTomador, sTomador,
  sCPFCNPJInter, sIndInter, sISSRetidoInter, sInter, sAssinatura: String;
begin
  with Nota do
  begin
    sSituacao := EnumeradoToStr(NFSe.SituacaoNfse, ['N', 'C'], [snNormal, snCancelado]);

    sISSRetido := EnumeradoToStr(NFSe.Servico.Valores.IssRetido,
                                 ['N', 'S'], [stNormal, stRetencao]);

    // Tomador do Servi�o
    sCPFCNPJTomador := OnlyNumber(NFSe.Tomador.IdentificacaoTomador.CpfCnpj);

    if Length(sCPFCNPJTomador) = 11 then
      sIndTomador := '1'
    else
      if Length(sCPFCNPJTomador) = 14 then
        sIndTomador := '2'
      else
        sIndTomador := '3';

    sTomador := sIndTomador + ACBrUtil.Strings.Poem_Zeros(sCPFCNPJTomador, 14);

    // Prestador Intermediario
    sCPFCNPJInter := OnlyNumber(NFSe.Intermediario.Identificacao.CpfCnpj);

    if Length(sCPFCNPJInter) = 11 then
      sIndInter := '1'
    else
      if Length(sCPFCNPJInter) = 14 then
        sIndInter := '2'
      else
        sIndInter := '3';

    sISSRetidoInter := EnumeradoToStr(NFSe.Intermediario.IssRetido,
                                      ['N', 'S'], [stNormal, stRetencao]);

    if sIndInter <> '3' then
      sInter := sIndInter + ACBrUtil.Strings.Poem_Zeros(sCPFCNPJInter, 14) + sISSRetidoInter
    else
      sInter := '';

    sAssinatura := ACBrUtil.Strings.Poem_Zeros(NFSe.Prestador.IdentificacaoPrestador.InscricaoMunicipal, 8) +
                   PadRight(NFSe.IdentificacaoRps.Serie, 5 , ' ') +
                   ACBrUtil.Strings.Poem_Zeros(NFSe.IdentificacaoRps.Numero, 12) +
                   FormatDateTime('yyyymmdd', NFse.DataEmissao) +
                   TipoTributacaoRPSToStr(NFSe.TipoTributacaoRPS) +
                   sSituacao +
                   sISSRetido +
                   ACBrUtil.Strings.Poem_Zeros(OnlyNumber(FormatFloat('#0.00', NFSe.Servico.Valores.ValorServicos)), 15 ) +
                   ACBrUtil.Strings.Poem_Zeros(OnlyNumber(FormatFloat('#0.00', NFSe.Servico.Valores.ValorDeducoes)), 15 ) +
                   ACBrUtil.Strings.Poem_Zeros(OnlyNumber(NFSe.Servico.ItemListaServico ), 5 ) +
                   sTomador +
                   sInter;

    with TACBrNFSeX(FAOwner) do
      NFSe.Assinatura := string(SSL.CalcHash(AnsiString(sAssinatura), dgstSHA1, outBase64, True));
  end;
end;

procedure TACBrNFSeProviderISSSaoPaulo.Configuracao;
begin
  inherited Configuracao;

  with ConfigGeral do
  begin
    Identificador := '';
    QuebradeLinha := '|';
    ModoEnvio := meLoteAssincrono;
  end;

  with ConfigAssinar do
  begin
    LoteRps := True;
    ConsultarSituacao := True;
    ConsultarLote := True;
    ConsultarNFSeRps := True;
    ConsultarNFSe := True;
    CancelarNFSe := True;
    LoteGerarNFSe := True;

    IncluirURI := False;

    AssinaturaAdicional := True;
  end;

  SetXmlNameSpace('http://www.prefeitura.sp.gov.br/nfe');

  with ConfigMsgDados do
  begin
    UsarNumLoteConsLote := True;

    with LoteRps do
    begin
      GerarNSLoteRps := True;
      InfElemento := 'RPS';
      DocElemento := 'PedidoEnvioLoteRPS';
    end;

    with ConsultarSituacao do
    begin
      InfElemento := '';
      DocElemento := 'PedidoInformacoesLote';
    end;

    with ConsultarLote do
    begin
      InfElemento := '';
      DocElemento := 'PedidoConsultaLote';
    end;

    with ConsultarNFSeRps do
    begin
      InfElemento := '';
      DocElemento := 'PedidoConsultaNFe';
    end;

    with ConsultarNFSe do
    begin
      InfElemento := '';
      DocElemento := 'PedidoConsultaNFe';
    end;

    with CancelarNFSe do
    begin
      InfElemento := '';
      DocElemento := 'PedidoCancelamentoNFe';
    end;

    with GerarNFSe do
    begin
      InfElemento := '';
      DocElemento := 'PedidoEnvioRPS';
    end;

    DadosCabecalho := '1';
  end;

  with ConfigSchemas do
  begin
    Teste := 'PedidoEnvioLoteRPS_v01.xsd';
    Recepcionar := 'PedidoEnvioLoteRPS_v01.xsd';
    ConsultarSituacao := 'PedidoInformacoesLote_v01.xsd';
    ConsultarLote := 'PedidoConsultaLote_v01.xsd';
    ConsultarNFSeRps := 'PedidoConsultaNFe_v01.xsd';
    ConsultarNFSe := 'PedidoConsultaNFe_v01.xsd';
    CancelarNFSe := 'PedidoCancelamentoNFe_v01.xsd';
    GerarNFSe := 'PedidoEnvioRPS_v01.xsd';
  end;
end;

function TACBrNFSeProviderISSSaoPaulo.CriarGeradorXml(
  const ANFSe: TNFSe): TNFSeWClass;
begin
  Result := TNFSeW_ISSSaoPaulo.Create(Self);
  Result.NFSe := ANFSe;
end;

function TACBrNFSeProviderISSSaoPaulo.CriarLeitorXml(
  const ANFSe: TNFSe): TNFSeRClass;
begin
  Result := TNFSeR_ISSSaoPaulo.Create(Self);
  Result.NFSe := ANFSe;
end;

function TACBrNFSeProviderISSSaoPaulo.CriarServiceClient(
  const AMetodo: TMetodo): TACBrNFSeXWebservice;
var
  URL: string;
begin
  URL := GetWebServiceURL(AMetodo);

  if URL <> '' then
    Result := TACBrNFSeXWebserviceISSSaoPaulo.Create(FAOwner, AMetodo, URL)
  else
  begin
    if ConfigGeral.Ambiente = taProducao then
      raise EACBrDFeException.Create(ERR_SEM_URL_PRO)
    else
      raise EACBrDFeException.Create(ERR_SEM_URL_HOM);
  end;
end;

function TACBrNFSeProviderISSSaoPaulo.LerChaveNFe(ANode: TACBrXmlNode): string;
var
  AuxNode: TACBrXmlNode;
begin
  if ANode = nil then
    Exit;

  AuxNode := ANode.Childrens.FindAnyNs('ChaveNFe');

  if AuxNode <> nil then
    Result := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('NumeroNFe'), tcStr);
end;

function TACBrNFSeProviderISSSaoPaulo.LerChaveRPS(ANode: TACBrXmlNode): string;
var
  AuxNode: TACBrXmlNode;
begin
  if ANode = nil then
    Exit;

  AuxNode := ANode.Childrens.FindAnyNs('ChaveRPS');

  if AuxNode <> nil then
    Result := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('NumeroRPS'), tcStr);
end;

procedure TACBrNFSeProviderISSSaoPaulo.ProcessarMensagemErros(
  RootNode: TACBrXmlNode; Response: TNFSeWebserviceResponse;
  const AListTag, AMessageTag: string);
var
  I: Integer;
  ANode: TACBrXmlNode;
  ANodeArray: TACBrXmlNodeArray;
  AErro: TNFSeEventoCollectionItem;
  AAlerta: TNFSeEventoCollectionItem;
  Mensagem: string;
begin
  ANodeArray := RootNode.Childrens.FindAllAnyNs(AMessageTag);

  if Assigned(ANodeArray) then
  begin
    for I := Low(ANodeArray) to High(ANodeArray) do
    begin
      AErro := Response.Erros.New;
      AErro.Codigo := ObterConteudoTag(ANodeArray[I].Childrens.FindAnyNs('Codigo'), tcStr);
      AErro.Descricao := ObterConteudoTag(ANodeArray[I].Childrens.FindAnyNs('Descricao'), tcStr);

      ANode := ANodeArray[I].Childrens.FindAnyNs('ChaveRPS');

      if ANode <> nil then
        AErro.Correcao := 'Numero/S�rie Rps: ' +
          ObterConteudoTag(ANode.Childrens.FindAnyNs('NumeroRPS'), tcStr) + '/' +
          ObterConteudoTag(ANode.Childrens.FindAnyNs('SerieRPS'), tcStr);
    end;
  end;

  ANodeArray := RootNode.Childrens.FindAllAnyNs('Alerta');

  if Assigned(ANodeArray) then
  begin
    for I := Low(ANodeArray) to High(ANodeArray) do
    begin
      Mensagem := ObterConteudoTag(ANodeArray[I].Childrens.FindAnyNs('Descricao'), tcStr);

      if Mensagem <> '' then
      begin
        AAlerta := Response.Alertas.New;
        AAlerta.Codigo := ObterConteudoTag(ANodeArray[I].Childrens.FindAnyNs('Codigo'), tcStr);
        AAlerta.Descricao := Mensagem;

        ANode := ANodeArray[I].Childrens.FindAnyNs('ChaveRPS');

        if ANode <> nil then
          AAlerta.Correcao := 'Numero/S�rie Rps: ' +
            ObterConteudoTag(ANode.Childrens.FindAnyNs('NumeroRPS'), tcStr) + '/' +
            ObterConteudoTag(ANode.Childrens.FindAnyNs('SerieRPS'), tcStr);
      end;
    end;
  end
end;

procedure TACBrNFSeProviderISSSaoPaulo.PrepararEmitir(Response: TNFSeEmiteResponse);
var
  AErro: TNFSeEventoCollectionItem;
  Emitente: TEmitenteConfNFSe;
  Nota: TNotaFiscal;
  IdAttr, NameSpace, ListaRps, xRps,
  TagEnvio, xCabecalho, xDataI, xDataF, xTotServicos, xTotDeducoes: string;
  I: Integer;
  DataInicial, DataFinal: TDateTime;
  vTotServicos, vTotDeducoes: Double;
  wAno, wMes, wDia: Word;
begin
  if TACBrNFSeX(FAOwner).NotasFiscais.Count <= 0 then
  begin
    AErro := Response.Erros.New;
    AErro.Codigo := Cod002;
    AErro.Descricao := Desc002;
  end;

  if TACBrNFSeX(FAOwner).NotasFiscais.Count > Response.MaxRps then
  begin
    AErro := Response.Erros.New;
    AErro.Codigo := Cod003;
    AErro.Descricao := 'Conjunto de RPS transmitidos (m�ximo de ' +
                       IntToStr(Response.MaxRps) + ' RPS)' +
                       ' excedido. Quantidade atual: ' +
                       IntToStr(TACBrNFSeX(FAOwner).NotasFiscais.Count);
  end;

  if Response.Erros.Count > 0 then Exit;

  ListaRps := '';

  if ConfigAssinar.IncluirURI then
    IdAttr := ConfigGeral.Identificador
  else
    IdAttr := 'ID';

  DataInicial := 0;
  DataFinal := 0;
  vTotServicos := 0;
  vTotDeducoes := 0;

  for I := 0 to TACBrNFSeX(FAOwner).NotasFiscais.Count -1 do
  begin
    Nota := TACBrNFSeX(FAOwner).NotasFiscais.Items[I];

    AssinaturaAdicional(Nota);

    Nota.GerarXML;

    Nota.XmlRps := ConverteXMLtoUTF8(Nota.XmlRps);
    Nota.XmlRps := ChangeLineBreak(Nota.XmlRps, '');

    if ConfigAssinar.Rps or ConfigAssinar.RpsGerarNFSe then
    begin
      Nota.XmlRps := FAOwner.SSL.Assinar(Nota.XmlRps,
                                         ConfigMsgDados.XmlRps.DocElemento,
                                         ConfigMsgDados.XmlRps.InfElemento, '', '', '', IdAttr);
    end;

    SalvarXmlRps(Nota);

    if i = 0 then
    begin
      DataInicial := Nota.NFSe.DataEmissao;
      DataFinal := DataInicial;
    end;

    if Nota.NFSe.DataEmissao < DataInicial then
      DataInicial := Nota.NFSe.DataEmissao;

    if Nota.NFSe.DataEmissao > DataFinal then
      DataFinal := Nota.NFSe.DataEmissao;

    vTotServicos := vTotServicos + Nota.NFSe.Servico.Valores.ValorServicos;
    vTotDeducoes := vTotDeducoes + Nota.NFSe.Servico.Valores.ValorDeducoes;

    xRps := RemoverDeclaracaoXML(Nota.XmlRps);

    xRps := '<RPS xmlns="">' + SeparaDados(xRps, 'RPS') + '</RPS>';

    ListaRps := ListaRps + xRps;
  end;

  Emitente := TACBrNFSeX(FAOwner).Configuracoes.Geral.Emitente;

  ListaRps := ChangeLineBreak(ListaRps, '');

  case Response.ModoEnvio of
    meUnitario:
    begin
      TagEnvio := 'PedidoEnvioRPS';

      xCabecalho := '<Cabecalho xmlns="" Versao="1">' +
                      '<CPFCNPJRemetente>' +
                        '<CNPJ>' +
                          OnlyNumber(Emitente.CNPJ) +
                        '</CNPJ>' +
                      '</CPFCNPJRemetente>' +
                    '</Cabecalho>';

      if EstaVazio(ConfigMsgDados.GerarNFSe.xmlns) then
        NameSpace := ''
      else
        NameSpace := ' xmlns="' + ConfigMsgDados.GerarNFSe.xmlns + '"';
    end;
  else
    begin
      TagEnvio := 'PedidoEnvioLoteRPS';

      DecodeDate(VarToDateTime(DataInicial), wAno, wMes, wDia);
      xDataI := FormatFloat('0000', wAno) + '-' +
                FormatFloat('00', wMes) + '-' + FormatFloat('00', wDia);

      DecodeDate(VarToDateTime(DataFinal), wAno, wMes, wDia);
      xDataF := FormatFloat('0000', wAno) + '-' +
                FormatFloat('00', wMes) + '-' + FormatFloat('00', wDia);

      {
        Tag <transacao>
        Informe se os RPS a serem substitu�dos por NFS-e far�o parte de uma
        mesma transa��o.

        True - Os RPS s� ser�o substitu�dos por NFS-e se n�o ocorrer nenhum
               evento de erro durante o processamento de todo o lote;

        False - Os RPS v�lidos ser�o substitu�dos por NFS-e, mesmo que ocorram
                eventos de erro durante processamento de outros RPS deste lote.
      }

      xTotServicos := FloatToString(vTotServicos, '.', FloatMask(2, False));
      xTotServicos := StringReplace(xTotServicos, '.00', '', []);
      xTotDeducoes := FloatToString(vTotDeducoes, '.', FloatMask(2, False));
      xTotDeducoes := StringReplace(xTotDeducoes, '.00', '', []);

      xCabecalho := '<Cabecalho xmlns="" Versao="1">' +
                      '<CPFCNPJRemetente>' +
                        '<CNPJ>' +
                          OnlyNumber(Emitente.CNPJ) +
                        '</CNPJ>' +
                      '</CPFCNPJRemetente>' +
                      '<transacao>' +
                         LowerCase(BoolToStr(TACBrNFSeX(FAOwner).NotasFiscais.Transacao, True)) +
                      '</transacao>' +
                      '<dtInicio>' + xDataI + '</dtInicio>' +
                      '<dtFim>' + xDataF + '</dtFim>' +
                      '<QtdRPS>' +
                         IntToStr(TACBrNFSeX(FAOwner).NotasFiscais.Count) +
                      '</QtdRPS>' +
                      '<ValorTotalServicos>' +
                         xTotServicos +
                      '</ValorTotalServicos>' +
                      '<ValorTotalDeducoes>' +
                         xTotDeducoes +
                      '</ValorTotalDeducoes>' +
                    '</Cabecalho>';

      if EstaVazio(ConfigMsgDados.LoteRps.xmlns) then
        NameSpace := ''
      else
        NameSpace := ' xmlns="' + ConfigMsgDados.LoteRps.xmlns + '"';
    end;
  end;

  Response.ArquivoEnvio := '<' + TagEnvio + NameSpace + '>' +
                              xCabecalho +
                              ListaRps +
                           '</' + TagEnvio + '>';
end;

procedure TACBrNFSeProviderISSSaoPaulo.TratarRetornoEmitir(Response: TNFSeEmiteResponse);
var
  Document: TACBrXmlDocument;
  AErro: TNFSeEventoCollectionItem;
  ANode: TACBrXmlNode;
  AuxNode, AuxNodeChave: TACBrXmlNode;
begin
  Document := TACBrXmlDocument.Create;

  try
    try
      if Response.ArquivoRetorno = '' then
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod201;
        AErro.Descricao := Desc201;
        Exit
      end;

      Document.LoadFromXml(Response.ArquivoRetorno);

      ANode := Document.Root;

      ProcessarMensagemErros(ANode, Response);

      Response.Sucesso := (Response.Erros.Count = 0);

      AuxNode := ANode.Childrens.FindAnyNs('Cabecalho');

      if AuxNode <> nil then
      begin
        with Response do
        begin
          Situacao := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('Sucesso'), tcStr);

          AuxNode := AuxNode.Childrens.FindAnyNs('InformacoesLote');

          if AuxNode <> nil then
          begin
            Lote := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('NumeroLote'), tcStr);

            { Verificar se mais alguma dessas informa��es s�o necess�rias
            with InformacoesLote do
            begin
              NumeroLote := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('NumeroLote'), tcStr);
              InscricaoPrestador := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('InscricaoPrestador'), tcStr);

              AuxNodeCPFCNPJ := AuxNode.Childrens.FindAnyNs('CPFCNPJRemetente');

              if AuxNodeCPFCNPJ <> nil then
              begin
                CPFCNPJRemetente := ObterConteudoTag(AuxNodeCPFCNPJ.Childrens.FindAnyNs('CNPJ'), tcStr);

                if CPFCNPJRemetente = '' then
                  CPFCNPJRemetente := ObterConteudoTag(AuxNodeCPFCNPJ.Childrens.FindAnyNs('CPF'), tcStr);
              end;

              DataEnvioLote := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('DataEnvioLote'), tcDatHor);
              QtdNotasProcessadas := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('QtdNotasProcessadas'), tcInt);
              TempoProcessamento := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('TempoProcessamento'), tcInt);
              ValorTotalServico := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('ValorTotalServicos'), tcDe2);
            end;
            }
          end;
        end;
      end;

      AuxNode := ANode.Childrens.FindAnyNs('ChaveNFeRPS');

      if AuxNode <> nil then
      begin
        AuxNodeChave := AuxNode.Childrens.FindAnyNs('ChaveRPS');

        if (AuxNodeChave <> nil) then
        begin
          with Response do
          begin
            SerieRps := ObterConteudoTag(AuxNodeChave.Childrens.FindAnyNs('SerieRPS'), tcStr);
            NumeroRps := ObterConteudoTag(AuxNodeChave.Childrens.FindAnyNs('NumeroRPS'), tcStr);
          end;
        end;

        AuxNodeChave := AuxNode.Childrens.FindAnyNs('ChaveNFe');

        if (AuxNodeChave <> nil) then
        begin
          with Response do
          begin
            NumeroNota := ObterConteudoTag(AuxNodeChave.Childrens.FindAnyNs('NumeroNFe'), tcStr);
            CodVerificacao := ObterConteudoTag(AuxNodeChave.Childrens.FindAnyNs('CodigoVerificacao'), tcStr);
          end;
        end;
      end;
    except
      on E:Exception do
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod999;
        AErro.Descricao := Desc999 + E.Message;
      end;
    end;
  finally
    FreeAndNil(Document);
  end;
end;

procedure TACBrNFSeProviderISSSaoPaulo.PrepararConsultaSituacao(
  Response: TNFSeConsultaSituacaoResponse);
var
  AErro: TNFSeEventoCollectionItem;
  Emitente: TEmitenteConfNFSe;
  NameSpace: string;
begin
  if EstaVazio(Response.Lote) then
  begin
    AErro := Response.Erros.New;
    AErro.Codigo := Cod111;
    AErro.Descricao := Desc111;
    Exit;
  end;

  Emitente := TACBrNFSeX(FAOwner).Configuracoes.Geral.Emitente;

  if EstaVazio(ConfigMsgDados.ConsultarSituacao.xmlns) then
    NameSpace := ''
  else
    NameSpace := ' xmlns="' + ConfigMsgDados.ConsultarSituacao.xmlns + '"';

  Response.ArquivoEnvio := '<PedidoInformacoesLote' + NameSpace + '>' +
                             '<Cabecalho xmlns="" Versao="1">' +
                               '<CPFCNPJRemetente>' +
                                 '<CNPJ>' +
                                   OnlyNumber(Emitente.CNPJ) +
                                 '</CNPJ>' +
                               '</CPFCNPJRemetente>' +
                               '<NumeroLote>' +
                                 Response.Lote +
                               '</NumeroLote>' +
                               '<InscricaoPrestador>' +
                                 OnlyNumber(Emitente.InscMun) +
                               '</InscricaoPrestador>' +
                             '</Cabecalho>' +
                           '</PedidoInformacoesLote>';
end;

procedure TACBrNFSeProviderISSSaoPaulo.TratarRetornoConsultaSituacao(
  Response: TNFSeConsultaSituacaoResponse);
var
  Document: TACBrXmlDocument;
  AErro: TNFSeEventoCollectionItem;
  ANode, AuxNode: TACBrXmlNode;
begin
  Document := TACBrXmlDocument.Create;

  try
    try
      if Response.ArquivoRetorno = '' then
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod201;
        AErro.Descricao := Desc201;
        Exit
      end;

      Document.LoadFromXml(Response.ArquivoRetorno);

      ANode := Document.Root;

      ProcessarMensagemErros(ANode, Response);

      Response.Sucesso := (Response.Erros.Count = 0);

      AuxNode := ANode.Childrens.FindAnyNs('Cabecalho');

      if AuxNode <> nil then
      begin
        with Response do
        begin
          Situacao := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('Sucesso'), tcStr);

          AuxNode := AuxNode.Childrens.FindAnyNs('InformacoesLote');

          if AuxNode <> nil then
          begin
            Lote := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('NumeroLote'), tcStr);

            { Verificar se mais alguma dessas informa��es s�o necess�rias
            with InformacoesLote do
            begin
              NumeroLote := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('NumeroLote'), tcStr);
              InscricaoPrestador := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('InscricaoPrestador'), tcStr);

              AuxNodeCPFCNPJ := AuxNode.Childrens.FindAnyNs('CPFCNPJRemetente');

              if AuxNodeCPFCNPJ <> nil then
              begin
                CPFCNPJRemetente := ObterConteudoTag(AuxNodeCPFCNPJ.Childrens.FindAnyNs('CNPJ'), tcStr);

                if CPFCNPJRemetente = '' then
                  CPFCNPJRemetente := ObterConteudoTag(AuxNodeCPFCNPJ.Childrens.FindAnyNs('CPF'), tcStr);
              end;

              DataEnvioLote := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('DataEnvioLote'), tcDatHor);
              QtdNotasProcessadas := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('QtdNotasProcessadas'), tcInt);
              TempoProcessamento := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('TempoProcessamento'), tcInt);
              ValorTotalServico := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('ValorTotalServico'), tcDe2);
            end;
            }
          end;
        end;
      end;
    except
      on E:Exception do
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod999;
        AErro.Descricao := Desc999 + E.Message;
      end;
    end;
  finally
    FreeAndNil(Document);
  end;
end;

procedure TACBrNFSeProviderISSSaoPaulo.PrepararConsultaLoteRps(
  Response: TNFSeConsultaLoteRpsResponse);
var
  AErro: TNFSeEventoCollectionItem;
  Emitente: TEmitenteConfNFSe;
  NameSpace: string;
begin
  if EstaVazio(Response.Lote) then
  begin
    AErro := Response.Erros.New;
    AErro.Codigo := Cod111;
    AErro.Descricao := Desc111;
    Exit;
  end;

  Emitente := TACBrNFSeX(FAOwner).Configuracoes.Geral.Emitente;

  if EstaVazio(ConfigMsgDados.ConsultarLote.xmlns) then
    NameSpace := ''
  else
    NameSpace := ' xmlns="' + ConfigMsgDados.ConsultarLote.xmlns + '"';

  Response.ArquivoEnvio := '<PedidoConsultaLote' + NameSpace + '>' +
                             '<Cabecalho xmlns="" Versao="1">' +
                               '<CPFCNPJRemetente>' +
                                 '<CNPJ>' +
                                   OnlyNumber(Emitente.CNPJ) +
                                 '</CNPJ>' +
                               '</CPFCNPJRemetente>' +
                               '<NumeroLote>' +
                                 Response.Lote +
                               '</NumeroLote>' +
                             '</Cabecalho>' +
                           '</PedidoConsultaLote>';
end;

procedure TACBrNFSeProviderISSSaoPaulo.TratarRetornoConsultaLoteRps(
  Response: TNFSeConsultaLoteRpsResponse);
var
  Document: TACBrXmlDocument;
  AErro: TNFSeEventoCollectionItem;
  ANode, AuxNode: TACBrXmlNode;
  ANodeArray: TACBrXmlNodeArray;
  i: Integer;
  NumRps, NumNFSe: String;
  ANota: TNotaFiscal;
begin
  Document := TACBrXmlDocument.Create;
  NumRps := '';
  NumNFSe := '';

  try
    try
      if Response.ArquivoRetorno = '' then
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod201;
        AErro.Descricao := Desc201;
        Exit
      end;

      Document.LoadFromXml(Response.ArquivoRetorno);

      ANode := Document.Root;

      ProcessarMensagemErros(ANode, Response);

      Response.Sucesso := (Response.Erros.Count = 0);

      AuxNode := ANode.Childrens.FindAnyNs('Cabecalho');

      if AuxNode <> nil then
      begin
        with Response do
        begin
          Situacao := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('Sucesso'), tcStr);
        end;
      end;

      ANodeArray := ANode.Childrens.FindAllAnyNs('NFe');
      if not Assigned(ANodeArray) then
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod203;
        AErro.Descricao := Desc203;
        Exit;
      end;

      for i := Low(ANodeArray) to High(ANodeArray) do
      begin
        ANode := ANodeArray[i];

        NumRps := LerChaveRPS(ANode);
        NumNFSe := LerChaveNFe(ANode);

        ANota := TACBrNFSeX(FAOwner).NotasFiscais.FindByRps(NumRps);

        if ANota = nil then
          ANota := TACBrNFSeX(FAOwner).NotasFiscais.FindByNFSe(NumNFSe);

        ANota := CarregarXmlNfse(ANota, ANode.OuterXml);
        SalvarXmlNfse(ANota);
      end;
    except
      on E:Exception do
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod999;
        AErro.Descricao := Desc999 + E.Message;
      end;
    end;
  finally
    FreeAndNil(Document);
  end;
end;

procedure TACBrNFSeProviderISSSaoPaulo.PrepararConsultaNFSeporRps(
  Response: TNFSeConsultaNFSeporRpsResponse);
var
  AErro: TNFSeEventoCollectionItem;
  Emitente: TEmitenteConfNFSe;
  NameSpace: string;
begin
  if EstaVazio(Response.NumRPS) then
  begin
    AErro := Response.Erros.New;
    AErro.Codigo := Cod102;
    AErro.Descricao := Desc102;
    Exit;
  end;

  if EstaVazio(Response.Serie) then
  begin
    AErro := Response.Erros.New;
    AErro.Codigo := Cod103;
    AErro.Descricao := Desc103;
    Exit;
  end;

  Emitente := TACBrNFSeX(FAOwner).Configuracoes.Geral.Emitente;

  if EstaVazio(ConfigMsgDados.ConsultarNFSeRps.xmlns) then
    NameSpace := ''
  else
    NameSpace := ' xmlns="' + ConfigMsgDados.ConsultarNFSeRps.xmlns + '"';

  Response.ArquivoEnvio := '<PedidoConsultaNFe' + NameSpace + '>' +
                             '<Cabecalho xmlns="" Versao="1">' +
                               '<CPFCNPJRemetente>' +
                                 '<CNPJ>' +
                                   OnlyNumber(Emitente.CNPJ) +
                                 '</CNPJ>' +
                               '</CPFCNPJRemetente>' +
                             '</Cabecalho>' +
                             '<Detalhe xmlns="">' +
                               '<ChaveRPS>' +
                                 '<InscricaoPrestador>' +
                                   OnlyNumber(Emitente.InscMun) +
                                 '</InscricaoPrestador>' +
                                 '<SerieRPS>' + Response.Serie + '</SerieRPS>' +
                                 '<NumeroRPS>' + Response.NumRPS + '</NumeroRPS>' +
                               '</ChaveRPS>' +
                             '</Detalhe>' +
                           '</PedidoConsultaNFe>';
end;

procedure TACBrNFSeProviderISSSaoPaulo.TratarRetornoConsultaNFSeporRps(
  Response: TNFSeConsultaNFSeporRpsResponse);
var
  Document: TACBrXmlDocument;
  AErro: TNFSeEventoCollectionItem;
  ANode, AuxNode: TACBrXmlNode;
  ANodeArray: TACBrXmlNodeArray;
  i: Integer;
  NumRps, NumNFSe: String;
  ANota: TNotaFiscal;
begin
  Document := TACBrXmlDocument.Create;
  NumRps := '';
  NumNFSe := '';

  try
    try
      if Response.ArquivoRetorno = '' then
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod201;
        AErro.Descricao := Desc201;
        Exit
      end;

      Document.LoadFromXml(Response.ArquivoRetorno);

      ANode := Document.Root;

      ProcessarMensagemErros(ANode, Response);

      Response.Sucesso := (Response.Erros.Count = 0);

      AuxNode := ANode.Childrens.FindAnyNs('Cabecalho');

      if AuxNode <> nil then
      begin
        with Response do
        begin
          Situacao := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('Sucesso'), tcStr);
        end;
      end;

      ANodeArray := ANode.Childrens.FindAllAnyNs('NFe');
      if not Assigned(ANodeArray) then
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod203;
        AErro.Descricao := Desc203;
        Exit;
      end;

      for i := Low(ANodeArray) to High(ANodeArray) do
      begin
        ANode := ANodeArray[i];

        NumRps := LerChaveRPS(ANode);
        NumNFSe := LerChaveNFe(ANode);

        ANota := TACBrNFSeX(FAOwner).NotasFiscais.FindByRps(NumRps);

        if ANota = nil then
          ANota := TACBrNFSeX(FAOwner).NotasFiscais.FindByNFSe(NumNFSe);

        ANota := CarregarXmlNfse(ANota, ANode.OuterXml);
        SalvarXmlNfse(ANota);
      end;
    except
      on E:Exception do
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod999;
        AErro.Descricao := Desc999 + E.Message;
      end;
    end;
  finally
    FreeAndNil(Document);
  end;
end;

procedure TACBrNFSeProviderISSSaoPaulo.PrepararConsultaNFSe(
  Response: TNFSeConsultaNFSeResponse);
var
  AErro: TNFSeEventoCollectionItem;
  Emitente: TEmitenteConfNFSe;
  NameSpace: string;
begin
  if EstaVazio(Response.InfConsultaNFSe.NumeroIniNFSe) then
  begin
    AErro := Response.Erros.New;
    AErro.Codigo := Cod108;
    AErro.Descricao := Desc108;
    Exit;
  end;

  Emitente := TACBrNFSeX(FAOwner).Configuracoes.Geral.Emitente;

  Response.Metodo := tmConsultarNFSe;

  if EstaVazio(ConfigMsgDados.ConsultarNFSe.xmlns) then
    NameSpace := ''
  else
    NameSpace := ' xmlns="' + ConfigMsgDados.ConsultarNFSe.xmlns + '"';

  Response.ArquivoEnvio := '<PedidoConsultaNFe' + NameSpace + '>' +
                             '<Cabecalho xmlns="" Versao="1">' +
                               '<CPFCNPJRemetente>' +
                                 '<CNPJ>' +
                                   OnlyNumber(Emitente.CNPJ) +
                                 '</CNPJ>' +
                               '</CPFCNPJRemetente>' +
                             '</Cabecalho>' +
                             '<Detalhe xmlns="">' +
                               '<ChaveNFe>' +
                                 '<InscricaoPrestador>' +
                                   OnlyNumber(Emitente.InscMun) +
                                 '</InscricaoPrestador>' +
                                 '<NumeroNFe>' +
                                    Response.InfConsultaNFSe.NumeroIniNFSe +
                                 '</NumeroNFe>' +
                               '</ChaveNFe>' +
                             '</Detalhe>' +
                           '</PedidoConsultaNFe>';
end;

procedure TACBrNFSeProviderISSSaoPaulo.TratarRetornoConsultaNFSe(
  Response: TNFSeConsultaNFSeResponse);
var
  Document: TACBrXmlDocument;
  AErro: TNFSeEventoCollectionItem;
  ANode, AuxNode: TACBrXmlNode;
  ANodeArray: TACBrXmlNodeArray;
  i: Integer;
  NumRps, NumNFSe: String;
  ANota: TNotaFiscal;
begin
  Document := TACBrXmlDocument.Create;
  NumRps := '';
  NumNFSe := '';

  try
    try
      if Response.ArquivoRetorno = '' then
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod201;
        AErro.Descricao := Desc201;
        Exit
      end;

      Document.LoadFromXml(Response.ArquivoRetorno);

      ANode := Document.Root;

      ProcessarMensagemErros(ANode, Response);

      Response.Sucesso := (Response.Erros.Count = 0);

      AuxNode := ANode.Childrens.FindAnyNs('Cabecalho');

      if AuxNode <> nil then
      begin
        with Response do
        begin
          Situacao := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('Sucesso'), tcStr);
        end;
      end;

      ANodeArray := ANode.Childrens.FindAllAnyNs('NFe');
      if not Assigned(ANodeArray) then
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod203;
        AErro.Descricao := Desc203;
        Exit;
      end;

      for i := Low(ANodeArray) to High(ANodeArray) do
      begin
        ANode := ANodeArray[i];

        NumRps := LerChaveRPS(ANode);
        NumNFSe := LerChaveNFe(ANode);

        ANota := TACBrNFSeX(FAOwner).NotasFiscais.FindByRps(NumRps);

        if ANota = nil then
          ANota := TACBrNFSeX(FAOwner).NotasFiscais.FindByNFSe(NumNFSe);

        ANota := CarregarXmlNfse(ANota, ANode.OuterXml);
        SalvarXmlNfse(ANota);
      end;
    except
      on E:Exception do
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod999;
        AErro.Descricao := Desc999 + E.Message;
      end;
    end;
  finally
    FreeAndNil(Document);
  end;
end;

procedure TACBrNFSeProviderISSSaoPaulo.PrepararCancelaNFSe(
  Response: TNFSeCancelaNFSeResponse);
var
  AErro: TNFSeEventoCollectionItem;
  Emitente: TEmitenteConfNFSe;
  NameSpace, sAssinatura, InscMun, NumeroNFSe: string;
begin
  if EstaVazio(Response.InfCancelamento.NumeroNFSe) then
  begin
    AErro := Response.Erros.New;
    AErro.Codigo := Cod108;
    AErro.Descricao := Desc108;
    Exit;
  end;

  Emitente := TACBrNFSeX(FAOwner).Configuracoes.Geral.Emitente;

  if EstaVazio(ConfigMsgDados.CancelarNFSe.xmlns) then
    NameSpace := ''
  else
    NameSpace := ' xmlns="' + ConfigMsgDados.CancelarNFSe.xmlns + '"';

  {
    Tag <transacao>
    Informe se as NFS-e a serem canceladas far�o parte de uma mesma transa��o.

    True - As NFS-e s� ser�o canceladas se n�o ocorrer nenhum evento de erro
           durante o processamento de todo o lote;

    False - As NFS-e aptas a serem canceladas ser�o canceladas, mesmo que
            ocorram eventos de erro durante processamento do cancelamento de
            outras NFS-e deste lote.
  }

  InscMun := OnlyNumber(Emitente.InscMun);
  NumeroNFSe := OnlyNumber(Response.InfCancelamento.NumeroNFSe);

  sAssinatura := ACBrUtil.Strings.Poem_Zeros(InscMun, 8) +
                 ACBrUtil.Strings.Poem_Zeros(NumeroNFSe, 12);

  sAssinatura := string(TACBrNFSeX(FAOwner).SSL.CalcHash(AnsiString(sAssinatura),
                                                    dgstSHA1, outBase64, True));

  Response.ArquivoEnvio := '<PedidoCancelamentoNFe' + NameSpace + '>' +
                             '<Cabecalho xmlns="" Versao="1">' +
                               '<CPFCNPJRemetente>' +
                                 '<CNPJ>' +
                                   OnlyNumber(Emitente.CNPJ) +
                                 '</CNPJ>' +
                               '</CPFCNPJRemetente>' +
                               '<transacao>false</transacao>' +
                             '</Cabecalho>' +
                             '<Detalhe xmlns="">' +
                               '<ChaveNFe>' +
                                 '<InscricaoPrestador>' +
                                   InscMun +
                                 '</InscricaoPrestador>' +
                                 '<NumeroNFe>' +
                                    NumeroNFSe +
                                 '</NumeroNFe>' +
                               '</ChaveNFe>' +
                               '<AssinaturaCancelamento>' +
                                  sAssinatura +
                               '</AssinaturaCancelamento>' +
                             '</Detalhe>' +
                           '</PedidoCancelamentoNFe>';
end;

procedure TACBrNFSeProviderISSSaoPaulo.TratarRetornoCancelaNFSe(
  Response: TNFSeCancelaNFSeResponse);
var
  Document: TACBrXmlDocument;
  AErro: TNFSeEventoCollectionItem;
  ANode, AuxNode: TACBrXmlNode;
begin
  Document := TACBrXmlDocument.Create;

  try
    try
      if Response.ArquivoRetorno = '' then
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod201;
        AErro.Descricao := Desc201;
        Exit
      end;

      Document.LoadFromXml(Response.ArquivoRetorno);

      ANode := Document.Root;

      ProcessarMensagemErros(ANode, Response);

      Response.Sucesso := (Response.Erros.Count = 0);

      AuxNode := ANode.Childrens.FindAnyNs('Cabecalho');

      if AuxNode <> nil then
      begin
        with Response do
        begin
          Situacao := ObterConteudoTag(AuxNode.Childrens.FindAnyNs('Sucesso'), tcStr);
        end;
      end;
    except
      on E:Exception do
      begin
        AErro := Response.Erros.New;
        AErro.Codigo := Cod999;
        AErro.Descricao := Desc999 + E.Message;
      end;
    end;
  finally
    FreeAndNil(Document);
  end;
end;

{ TACBrNFSeXWebserviceISSSaoPaulo }

function TACBrNFSeXWebserviceISSSaoPaulo.Recepcionar(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfe:EnvioLoteRPSRequest>';
  Request := Request + '<nfe:VersaoSchema>' + ACabecalho + '</nfe:VersaoSchema>';
  Request := Request + '<nfe:MensagemXML>' + XmlToStr(AMSG) + '</nfe:MensagemXML>';
  Request := Request + '</nfe:EnvioLoteRPSRequest>';

  Result := Executar('http://www.prefeitura.sp.gov.br/nfe/ws/envioLoteRPS', Request,
                     ['RetornoXML', 'RetornoEnvioLoteRPS'],
                     ['xmlns:nfe="http://www.prefeitura.sp.gov.br/nfe"']);
end;

function TACBrNFSeXWebserviceISSSaoPaulo.GerarNFSe(ACabecalho, AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfe:EnvioRPSRequest>';
  Request := Request + '<nfe:VersaoSchema>' + ACabecalho + '</nfe:VersaoSchema>';
  Request := Request + '<nfe:MensagemXML>' + XmlToStr(AMSG) + '</nfe:MensagemXML>';
  Request := Request + '</nfe:EnvioRPSRequest>';

  Result := Executar('http://www.prefeitura.sp.gov.br/nfe/ws/envioRPS', Request,
                     ['RetornoXML', 'RetornoEnvioRPS'],
                     ['xmlns:nfe="http://www.prefeitura.sp.gov.br/nfe"']);
end;

function TACBrNFSeXWebserviceISSSaoPaulo.TesteEnvio(ACabecalho, AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfe:TesteEnvioLoteRPSRequest>';
  Request := Request + '<nfe:VersaoSchema>' + ACabecalho + '</nfe:VersaoSchema>';
  Request := Request + '<nfe:MensagemXML>' + XmlToStr(AMSG) + '</nfe:MensagemXML>';
  Request := Request + '</nfe:TesteEnvioLoteRPSRequest>';

  Result := Executar('http://www.prefeitura.sp.gov.br/nfe/ws/testeenvio', Request,
                     ['RetornoXML', 'RetornoEnvioLoteRPS'],
                     ['xmlns:nfe="http://www.prefeitura.sp.gov.br/nfe"']);
end;

function TACBrNFSeXWebserviceISSSaoPaulo.ConsultarSituacao(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfe:ConsultaInformacoesLoteRequest>';
  Request := Request + '<nfe:VersaoSchema>' + ACabecalho + '</nfe:VersaoSchema>';
  Request := Request + '<nfe:MensagemXML>' + XmlToStr(AMSG) + '</nfe:MensagemXML>';
  Request := Request + '</nfe:ConsultaInformacoesLoteRequest>';

  Result := Executar('http://www.prefeitura.sp.gov.br/nfe/ws/consultaInformacoesLote', Request,
                     ['RetornoXML', 'RetornoInformacoesLote'],
                     ['xmlns:nfe="http://www.prefeitura.sp.gov.br/nfe"']);
end;

function TACBrNFSeXWebserviceISSSaoPaulo.ConsultarLote(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfe:ConsultaLoteRequest>';
  Request := Request + '<nfe:VersaoSchema>' + ACabecalho + '</nfe:VersaoSchema>';
  Request := Request + '<nfe:MensagemXML>' + XmlToStr(AMSG) + '</nfe:MensagemXML>';
  Request := Request + '</nfe:ConsultaLoteRequest>';

  Result := Executar('http://www.prefeitura.sp.gov.br/nfe/ws/consultaLote', Request,
                     ['RetornoXML', 'RetornoConsulta'],
                     ['xmlns:nfe="http://www.prefeitura.sp.gov.br/nfe"']);
end;

function TACBrNFSeXWebserviceISSSaoPaulo.ConsultarNFSePorRps(ACabecalho,
  AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfe:ConsultaNFeRequest>';
  Request := Request + '<nfe:VersaoSchema>' + ACabecalho + '</nfe:VersaoSchema>';
  Request := Request + '<nfe:MensagemXML>' + XmlToStr(AMSG) + '</nfe:MensagemXML>';
  Request := Request + '</nfe:ConsultaNFeRequest>';

  Result := Executar('http://www.prefeitura.sp.gov.br/nfe/ws/consultaNFe', Request,
                     ['RetornoXML', 'RetornoConsulta'],
                     ['xmlns:nfe="http://www.prefeitura.sp.gov.br/nfe"']);
end;

function TACBrNFSeXWebserviceISSSaoPaulo.ConsultarNFSe(ACabecalho, AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfe:ConsultaNFeRequest>';
  Request := Request + '<nfe:VersaoSchema>' + ACabecalho + '</nfe:VersaoSchema>';
  Request := Request + '<nfe:MensagemXML>' + XmlToStr(AMSG) + '</nfe:MensagemXML>';
  Request := Request + '</nfe:ConsultaNFeRequest>';

  Result := Executar('http://www.prefeitura.sp.gov.br/nfe/ws/consultaNFe', Request,
                     ['RetornoXML', 'RetornoConsulta'],
                     ['xmlns:nfe="http://www.prefeitura.sp.gov.br/nfe"']);
end;

function TACBrNFSeXWebserviceISSSaoPaulo.Cancelar(ACabecalho, AMSG: String): string;
var
  Request: string;
begin
  FPMsgOrig := AMSG;

  Request := '<nfe:CancelamentoNFeRequest>';
  Request := Request + '<nfe:VersaoSchema>' + ACabecalho + '</nfe:VersaoSchema>';
  Request := Request + '<nfe:MensagemXML>' + XmlToStr(AMSG) + '</nfe:MensagemXML>';
  Request := Request + '</nfe:CancelamentoNFeRequest>';

  Result := Executar('http://www.prefeitura.sp.gov.br/nfe/ws/cancelamentoNFe', Request,
                     ['RetornoXML', 'RetornoCancelamentoNFe'],
                     ['xmlns:nfe="http://www.prefeitura.sp.gov.br/nfe"']);
end;

function TACBrNFSeXWebserviceISSSaoPaulo.TratarXmlRetornado(
  const aXML: string): string;
begin
  Result := inherited TratarXmlRetornado(aXML);

  Result := ParseText(AnsiString(Result), True, False);
  Result := RemoverDeclaracaoXML(Result);
end;

end.
