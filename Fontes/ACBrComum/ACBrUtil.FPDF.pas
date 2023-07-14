{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{ Direitos Autorais Reservados (c) 2023 Daniel Simoes de Almeida               }


{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }

{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }

{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }

{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }

{ Daniel Sim�es de Almeida - daniel@projetoacbr.com.br - www.projetoacbr.com.br}
{       Rua Coronel Aureliano de Camargo, 963 - Tatu� - SP - 18270-170         }
{******************************************************************************}

{  Algumas fun�oes dessa Unit foram extraidas de outras Bibliotecas, veja no   }
{ cabe�alho das Fun�oes no c�digo abaixo a origem das informa�oes, e autores...}

{******************************************************************************}

{$I ACBr.inc}

unit ACBrUtil.FPDF;

interface

uses ACBr_fpdf,
     ACBr_fpdf_ext,
     ACBrUtil.Strings;

type
  TACBrFPDFExt = class(TFPDFExt)
    public
      procedure Cell(vWidth: Double; vHeight: Double = 0; const vText: String = '';
        const vBorder: String = '0'; vLineBreak: Integer = 0; const vAlign: String = '';
        vFill: Boolean = False; vLink: String = ''); override;
  end;

implementation

{ TACBrFPDFExt }

procedure TACBrFPDFExt.Cell(vWidth, vHeight: Double; const vText,
  vBorder: String; vLineBreak: Integer; const vAlign: String; vFill: Boolean;
  vLink: String);
begin
  inherited Cell(vWidth, vHeight, NativeStringToAnsi(vText),
  vBorder, vLineBreak, vAlign, vFill, vLink);
end;

end.
