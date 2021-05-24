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

unit ACBrNFSeXProviderManager;

interface

uses
  SysUtils, Classes, ACBrUtil,
  ACBrNFSeXInterface, ACBrNFSeXConversao, ACBrDFe;

type

  TACBrNFSeXProviderManager = class
  public
    class function GetProvider(ACBrNFSe: TACBrDFe): IACBrNFSeXProvider;
  end;

implementation

uses
  ACBrNFSeX,

  // Provedores que seguem a vers�o 1 do layout da ABRASF
  BHISS.Provider,
  CIGA.Provider,
  DBSeller.Provider,
  DSFSJC.Provider,
  FISSLex.Provider,
  GeNFe.Provider,
  Ginfes.Provider,
  GovBr.Provider,
  ISSCuritiba.Provider,
  ISSFortaleza.Provider,
  ISSIntel.Provider,
  ISSNet.Provider,
  Lexsom.Provider,
  MetropolisWeb.Provider,
  Natal.Provider,
  NFSeBrasil.Provider,
  Publica.Provider,
  Recife.Provider,
  RJ.Provider,
  Salvador.Provider,
  SilTecnologia.Provider,
  SJP.Provider,
  SpeedGov.Provider,
  Thema.Provider,
  Tinus.Provider,

  // Provedores que seguem a vers�o 2 do layout da ABRASF
  ABase.Provider,
  Actcon.Provider,
  Adm.Provider,
  AEG.Provider,
  Asten.Provider,
  Centi.Provider,
  Coplan.Provider,
  DataSmart.Provider,
  DeISS.Provider,
  Desenvolve.Provider,
  Digifred.Provider,
  DSF.Provider,
  EloTech.Provider,
  eReceita.Provider,
  fintelISS.Provider,
  Fiorilli.Provider,
  Futurize.Provider,
  Giss.Provider,
  Goiania.Provider,
  GovDigital.Provider,
  iiBrasil.Provider,
  ISSDigital.Provider,
  ISSe.Provider,
  ISSJoinville.Provider,
  Link3.Provider,
  MegaSoft.Provider,
  Mitra.Provider,
  ModernizacaoPublica.Provider,
  NEAInformatica.Provider,
  NotaInteligente.Provider,
  Prodata.Provider,
  PVH.Provider,
  RLZ.Provider,
  Saatri.Provider,
  SafeWeb.Provider,
  SH3.Provider,
  Siam.Provider,
  SiapNet.Provider,
  SiapSistemas.Provider,
  SigCorp.Provider,
  Sigep.Provider,
  SisPMJP.Provider,
  Sistemas4R.Provider,
  SystemPro.Provider,
  TcheInfo.Provider,
  Tecnos.Provider,
  Tributus.Provider,
  VersaTecnologia.Provider,
  Virtual.Provider,
  Vitoria.Provider,

  // Provedores que seguem a vers�o 1 e 2 do layout da ABRASF
  Abaco.Provider,
  Betha.Provider,
  Pronim.Provider,
  SimplISS.Provider,
  Tiplan.Provider,
  WebISS.Provider,

  // Provedores que tem layout pr�prio e tamb�m seguem a vers�o 1 ou 2 do
  // layout da ABRASF
  EL.Provider,
  Infisc.Provider,
  SmarAPD.Provider,

  // Provedores que tem layout pr�prio
  Agili.Provider,
  AssessorPublico.Provider,
  Conam.Provider,
  eGoverneISS.Provider,
  Equiplano.Provider,
  GeisWeb.Provider,
  Giap.Provider,
  Governa.Provider,
  IPM.Provider,
  ISSDSF.Provider,
  Lencois.Provider,
  Siat.Provider,
  SigISS.Provider,
  SP.Provider,
  WebFisco.Provider;

  { TACBrNFSeXProviderManager }

class function TACBrNFSeXProviderManager.GetProvider(ACBrNFSe: TACBrDFe): IACBrNFSeXProvider;
begin
  case TACBrNFSeX(ACBrNFSe).Configuracoes.Geral.Provedor of
    // ABRASFv1
    proAbaco:    Result := TACBrNFSeProviderAbaco.Create(ACBrNFSe);
    proAbacoA:   Result := TACBrNFSeProviderAbacoA.Create(ACBrNFSe);
    proBetha:    Result := TACBrNFSeProviderBetha.Create(ACBrNFSe);
    proBHISS:    Result := TACBrNFSeProviderBHISS.Create(ACBrNFSe);
    proCIGA:     Result := TACBrNFSeProviderCIGA.Create(ACBrNFSe);
    proDBSeller: Result := TACBrNFSeProviderDBSeller.Create(ACBrNFSe);
    proDSFSJC:   Result := TACBrNFSeProviderDSFSJC.Create(ACBrNFSe);
    proFISSLex:  Result := TACBrNFSeProviderFISSLex.Create(ACBrNFSe);
    proGeNFe:    Result := TACBrNFSeProviderGeNFe.Create(ACBrNFSe);
    proGinfes:   Result := TACBrNFSeProviderGinfes.Create(ACBrNFSe);
    proGovBr:    Result := TACBrNFSeProviderGovBr.Create(ACBrNFSe);

    proISSCuritiba:
      Result := TACBrNFSeProviderISSCuritiba.Create(ACBrNFSe);

    proISSFortaleza:
      Result := TACBrNFSeProviderISSFortaleza.Create(ACBrNFSe);

    proISSIntel: Result := TACBrNFSeProviderISSIntel.Create(ACBrNFSe);
    proISSNet:   Result := TACBrNFSeProviderISSNet.Create(ACBrNFSe);
    proLexsom:   Result := TACBrNFSeProviderLexsom.Create(ACBrNFSe);

    proMetropolisWeb:
      Result := TACBrNFSeProviderMetropolisWeb.Create(ACBrNFSe);

    proNatal:    Result := TACBrNFSeProviderNatal.Create(ACBrNFSe);

    proNFSeBrasil:
      Result := TACBrNFSeProviderNFSeBrasil.Create(ACBrNFSe);

    proPronim:   Result := TACBrNFSeProviderPronim.Create(ACBrNFSe);
    proPublica:  Result := TACBrNFSeProviderPublica.Create(ACBrNFSe);
    proRecife:   Result := TACBrNFSeProviderRecife.Create(ACBrNFSe);
    proRJ:       Result := TACBrNFSeProviderRJ.Create(ACBrNFSe);
    proSalvador: Result := TACBrNFSeProviderSalvador.Create(ACBrNFSe);

    proSilTecnologia:
      Result := TACBrNFSeProviderSilTecnologia.Create(ACBrNFSe);

    proSimplISS: Result := TACBrNFSeProviderSimplISS.Create(ACBrNFSe);
    proSJP:      Result := TACBrNFSeProviderSJP.Create(ACBrNFSe);
    proSpeedGov: Result := TACBrNFSeProviderSpeedGov.Create(ACBrNFSe);
    proThema:    Result := TACBrNFSeProviderThema.Create(ACBrNFSe);
    proTinus,
    proTinusA:   Result := TACBrNFSeProviderTinus.Create(ACBrNFSe);
    proTiplan:   Result := TACBrNFSeProviderTiplan.Create(ACBrNFSe);
    proWebISS:   Result := TACBrNFSeProviderWebISS.Create(ACBrNFSe);

    // ABRASFv2
    proSistemas4R:   Result := TACBrNFSeProvider4R.Create(ACBrNFSe);
    proAbacoV204:    Result := TACBrNFSeProviderAbacov204.Create(ACBrNFSe);
    proABase:        Result := TACBrNFSeProviderABase.Create(ACBrNFSe);
    proActconV201:   Result := TACBrNFSeProviderActconv201.Create(ACBrNFSe);
    proActconV202:   Result := TACBrNFSeProviderActconv202.Create(ACBrNFSe);
    proAdm:          Result := TACBrNFSeProviderAdm.Create(ACBrNFSe);
    proAEG:          Result := TACBrNFSeProviderAEG.Create(ACBrNFSe);
    proAsten:        Result := TACBrNFSeProviderAsten.Create(ACBrNFSe);
    proBethaV2:      Result := TACBrNFSeProviderBethav2.Create(ACBrNFSe);
    proCenti:        Result := TACBrNFSeProviderCenti.Create(ACBrNFSe);
    proCoplan:       Result := TACBrNFSeProviderCoplan.Create(ACBrNFSe);
    proDataSmart:    Result := TACBrNFSeProviderDataSmart.Create(ACBrNFSe);
    proDeISS:        Result := TACBrNFSeProviderDeISS.Create(ACBrNFSe);
    proDesenvolve:   Result := TACBrNFSeProviderDesenvolve.Create(ACBrNFSe);
    proDigifred:     Result := TACBrNFSeProviderDigifred.Create(ACBrNFSe);
    proDSFV2:        Result := TACBrNFSeProviderDSF.Create(ACBrNFSe);
    proELV2:         Result := TACBrNFSeProviderELv2.Create(ACBrNFSe);
    proElotech:      Result := TACBrNFSeProviderEloTech.Create(ACBrNFSe);
    proeReceita:     Result := TACBrNFSeProvidereReceita.Create(ACBrNFSe);
    profintelISS:    Result := TACBrNFSeProviderfintelISS.Create(ACBrNFSe);
    proFiorilli:     Result := TACBrNFSeProviderFiorilli.Create(ACBrNFSe);
    proFuturize:     Result := TACBrNFSeProviderFuturize.Create(ACBrNFSe);
    proGiss:         Result := TACBrNFSeProviderGiss.Create(ACBrNFSe);
    proGoiania:      Result := TACBrNFSeProviderGoiania.Create(ACBrNFSe);
    proGovDigital:   Result := TACBrNFSeProviderGovDigital.Create(ACBrNFSe);
    proiiBrasilV2:   Result := TACBrNFSeProvideriiBrasil.Create(ACBrNFSe);
    proInfiscV2:     Result := TACBrNFSeProviderInfiscv2.Create(ACBrNFSe);
    proISSDigital:   Result := TACBrNFSeProviderISSDigital.Create(ACBrNFSe);
    proISSe:         Result := TACBrNFSeProviderISSe.Create(ACBrNFSe);
    proISSJoinville: Result := TACBrNFSeProviderISSJoinville.Create(ACBrNFSe);
    proLink3:        Result := TACBrNFSeProviderLink3.Create(ACBrNFSe);
    proMegaSoft:     Result := TACBrNFSeProviderMegaSoft.Create(ACBrNFSe);
    proMitra:        Result := TACBrNFSeProviderMitra.Create(ACBrNFSe);

    proModernizacaoPublica:
      Result := TACBrNFSeProviderModernizacaoPublica.Create(ACBrNFSe);
    proNEAInformatica:
      Result := TACBrNFSeProviderNEAInformatica.Create(ACBrNFSe);
    proNotaInteligente:
      Result := TACBrNFSeProviderNotaInteligente.Create(ACBrNFSe);

    proProdata:      Result := TACBrNFSeProviderProdata.Create(ACBrNFSe);
    proPronimV202:   Result := TACBrNFSeProviderPronimv202.Create(ACBrNFSe);
    proPronimV203:   Result := TACBrNFSeProviderPronimv203.Create(ACBrNFSe);
    proPVH:          Result := TACBrNFSeProviderPVH.Create(ACBrNFSe);
    proRLZ:          Result := TACBrNFSeProviderRLZ.Create(ACBrNFSe);
    proSaatri:       Result := TACBrNFSeProviderSaatri.Create(ACBrNFSe);
    proSafeWeb:      Result := TACBrNFSeProviderSafeWeb.Create(ACBrNFSe);
    proSH3:          Result := TACBrNFSeProviderSH3.Create(ACBrNFSe);
    proSiam:         Result := TACBrNFSeProviderSiam.Create(ACBrNFSe);
    proSiapNet:      Result := TACBrNFSeProviderSiapNet.Create(ACBrNFSe);
    proSiapSistemas: Result := TACBrNFSeProviderSiapSistemas.Create(ACBrNFSe);
    proSigCorp:      Result := TACBrNFSeProviderSigCorp.Create(ACBrNFSe);
    proSigep:        Result := TACBrNFSeProviderSigep.Create(ACBrNFSe);
    proSimplISSV2:   Result := TACBrNFSeProviderSimplISSv2.Create(ACBrNFSe);
    proSisPMJP:      Result := TACBrNFSeProviderSisPMJP.Create(ACBrNFSe);
    proSmarAPDV203:  Result := TACBrNFSeProviderSmarAPDv203.Create(ACBrNFSe);
    proSmarAPDV204:  Result := TACBrNFSeProviderSmarAPDv204.Create(ACBrNFSe);
    proSystemPro:    Result := TACBrNFSeProviderSystemPro.Create(ACBrNFSe);
    proTcheInfoV2:   Result := TACBrNFSeProviderTcheInfo.Create(ACBrNFSe);
    proTecnos:       Result := TACBrNFSeProviderTecnos.Create(ACBrNFSe);
    proTributus:     Result := TACBrNFSeProviderTributus.Create(ACBrNFSe);
    proTiplanV2:     Result := TACBrNFSeProviderTiplanv2.Create(ACBrNFSe);

    proVersaTecnologiaV201:
      Result := TACBrNFSeProviderVersaTecnologiav201.Create(ACBrNFSe);

    proVersaTecnologiaV202:
      Result := TACBrNFSeProviderVersaTecnologiav202.Create(ACBrNFSe);

    proVirtual:  Result := TACBrNFSeProviderVirtual.Create(ACBrNFSe);
    proVitoria:  Result := TACBrNFSeProviderVitoria.Create(ACBrNFSe);
    proWebISSV2: Result := TACBrNFSeProviderWebISSv2.Create(ACBrNFSe);

    // Layout Pr�prio
    proAgili:   Result := TACBrNFSeProviderAgili.Create(ACBrNFSe);

    proAssessorPublico:
      Result := TACBrNFSeProviderAssessorPublico.Create(ACBrNFSe);

    proConam:   Result := TACBrNFSeProviderConam.Create(ACBrNFSe);

    proeGoverneISS:
      Result := TACBrNFSeProvidereGoverneISS.Create(ACBrNFSe);

    proEL:      Result := TACBrNFSeProviderEL.Create(ACBrNFSe);

    proEquiplano:
      Result := TACBrNFSeProviderEquiplano.Create(ACBrNFSe);

    proGeisWeb: Result := TACBrNFSeProviderGeisWeb.Create(ACBrNFSe);
    proGiap:    Result := TACBrNFSeProviderGiap.Create(ACBrNFSe);
    proGoverna: Result := TACBrNFSeProviderGoverna.Create(ACBrNFSe);

    proInfiscV100:
      Result := TACBrNFSeProviderInfiscv100.Create(ACBrNFSe);

    proInfiscV110:
      Result := TACBrNFSeProviderInfiscv110.Create(ACBrNFSe);

    proIPM:     Result := TACBrNFSeProviderIPM.Create(ACBrNFSe);
    proIPMa:    Result := TACBrNFSeProviderIPMa.Create(ACBrNFSe);
    proISSDSF:  Result := TACBrNFSeProviderISSDSF.Create(ACBrNFSe);
    proLencois: Result := TACBrNFSeProviderLencois.Create(ACBrNFSe);
    proSiat:    Result := TACBrNFSeProviderSiat.Create(ACBrNFSe);
    proSigISS:  Result := TACBrNFSeProviderSigISS.Create(ACBrNFSe);
    proSmarAPD: Result := TACBrNFSeProviderSmarAPD.Create(ACBrNFSe);
    proSP:      Result := TACBrNFSeProviderSP.Create(ACBrNFSe);

    proWebFisco:
      Result := TACBrNFSeProviderWebFisco.Create(ACBrNFSe);
  else
    Result := nil;
  end;
end;

end.
