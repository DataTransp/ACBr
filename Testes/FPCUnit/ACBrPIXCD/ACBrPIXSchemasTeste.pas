unit ACBrPIXSchemasTeste;
 
{$I ACBr.inc}

interface

uses
  Classes, SysUtils,
  ACBrPIXSchemas,
  {$ifdef FPC}
   fpcunit, testutils, testregistry
  {$else}
   {$IFDEF DUNITX}
    DUnitX.TestFramework, DUnitX.DUnitCompatibility
   {$ELSE}
    TestFramework
   {$ENDIF}
  {$endif};

type

  { TTestCobrancaImediataExemplo1 }

  TTestCobrancaImediataExemplo1 = class(TTestCase)
  private
    fJSON: String;
    fACBrPixCob: TACBrPIXCobSolicitada;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure AtribuirELerValores;
    procedure AtribuirLerReatribuirEComparar;
  end;

  { TTestCobrancaImediataComSaquePIX }

  TTestCobrancaImediataComSaquePIX = class(TTestCase)
  private
    fJSON: String;
    fACBrPixCob: TACBrPIXCobSolicitada;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure AtribuirELerValores;
    procedure AtribuirLerReatribuirEComparar;
  end;

  { TTestCobrancaImediataComSaquePIX2 }

  TTestCobrancaImediataComSaquePIX2 = class(TTestCase)
  private
    fJSON: String;
    fACBrPixCob: TACBrPIXCobSolicitada;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure AtribuirELerValores;
    procedure AtribuirLerReatribuirEComparar;
  end;

  { TTestCobrancaImediataComSaquePIX3 }

  TTestCobrancaImediataComSaquePIX3 = class(TTestCase)
  private
    fJSON: String;
    fACBrPixCob: TACBrPIXCobSolicitada;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure AtribuirELerValores;
    procedure AtribuirLerReatribuirEComparar;
  end;

implementation

uses
  ACBrUtil;

{ TTestCobrancaImediataExemplo1 }

procedure TTestCobrancaImediataExemplo1.SetUp;
begin
  inherited;
  fACBrPixCob := TACBrPIXCobSolicitada.Create;

  // Nota, os Fontes dessa Unit est�o em CP1252, por isso usamos ACBrStr()
  fJSON := ACBrStr(
        '{'+
          '"calendario": {'+
            '"expiracao": 3600'+
          '},'+
          '"devedor": {'+
            '"cnpj": "12345678000195",'+
            '"nome": "Empresa de Servi�os SA"'+
          '},'+
          '"valor": {'+
            '"original": "37.00",'+
            '"modalidadeAlteracao": 1'+
          '},'+
          '"chave": "7d9f0335-8dcc-4054-9bf9-0dbd61d36906",'+
          '"solicitacaoPagador": "Servi�o realizado.",'+
          '"infoAdicionais": ['+
            '{'+
              '"nome": "Campo 1",'+
              '"valor": "Informa��o Adicional1 do PSP-Recebedor"'+
            '},'+
            '{'+
              '"nome": "Campo 2",'+
              '"valor": "Informa��o Adicional2 do PSP-Recebedor"'+
            '}'+
          ']'+
        '}');
end;

procedure TTestCobrancaImediataExemplo1.TearDown;
begin
  fACBrPixCob.Free;
  inherited TearDown;
end;

procedure TTestCobrancaImediataExemplo1.AtribuirELerValores;
begin
  fACBrPixCob.AsJSON := fJSON;
  CheckEquals(fACBrPixCob.calendario.expiracao, 3600);
  CheckEquals(fACBrPixCob.devedor.cnpj, '12345678000195');
  CheckEquals(fACBrPixCob.devedor.nome, ACBrStr('Empresa de Servi�os SA'));
  CheckEquals(fACBrPixCob.valor.original, 37);
  CheckEquals(fACBrPixCob.valor.modalidadeAlteracao, True);
  CheckEquals(fACBrPixCob.chave, '7d9f0335-8dcc-4054-9bf9-0dbd61d36906');
  CheckEquals(fACBrPixCob.solicitacaoPagador, ACBrStr('Servi�o realizado.'));
  CheckEquals(fACBrPixCob.infoAdicionais[0].nome, 'Campo 1');
  CheckEquals(fACBrPixCob.infoAdicionais[0].valor, ACBrStr('Informa��o Adicional1 do PSP-Recebedor'));
  CheckEquals(fACBrPixCob.infoAdicionais[1].nome, 'Campo 2');
  CheckEquals(fACBrPixCob.infoAdicionais[1].valor, ACBrStr('Informa��o Adicional2 do PSP-Recebedor'));
end;

procedure TTestCobrancaImediataExemplo1.AtribuirLerReatribuirEComparar;
var
  pc: TACBrPIXCobSolicitada;
  s: String;
begin
  fACBrPixCob.AsJSON := fJSON;
  s := fACBrPixCob.AsJSON;
  pc := TACBrPIXCobSolicitada.Create;
  try
    pc.AsJSON := s;
    CheckEquals(fACBrPixCob.calendario.expiracao, pc.calendario.expiracao);
    CheckEquals(fACBrPixCob.devedor.cnpj, pc.devedor.cnpj);
    CheckEquals(fACBrPixCob.devedor.nome, pc.devedor.nome);
    CheckEquals(fACBrPixCob.valor.original, pc.valor.original);
    CheckEquals(fACBrPixCob.valor.modalidadeAlteracao, pc.valor.modalidadeAlteracao);
    CheckEquals(fACBrPixCob.chave, pc.chave);
    CheckEquals(fACBrPixCob.solicitacaoPagador, pc.solicitacaoPagador);
    CheckEquals(fACBrPixCob.infoAdicionais[0].nome, pc.infoAdicionais[0].nome);
    CheckEquals(fACBrPixCob.infoAdicionais[0].valor, pc.infoAdicionais[0].valor);
    CheckEquals(fACBrPixCob.infoAdicionais[1].nome, pc.infoAdicionais[1].nome);
    CheckEquals(fACBrPixCob.infoAdicionais[1].valor, pc.infoAdicionais[1].valor);
  finally
    pc.Free;
  end;
end;

{ TTestCobrancaImediataComSaquePIX }

procedure TTestCobrancaImediataComSaquePIX.SetUp;
begin
  inherited;
  fACBrPixCob := TACBrPIXCobSolicitada.Create;

  // Nota, os Fontes dessa Unit est�o em CP1252, por isso usamos ACBrStr()
  fJSON := ACBrStr(
           '{'+
            '"devedor": {'+
              '"cnpj": "12345678000195",'+
              '"nome": "Empresa de Servi�os SA"'+
            '},'+
            '"valor": {'+
              '"original": "0.00",'+
              '"modalidadeAlteracao": 0,'+
              '"retirada": {'+
                '"saque": {'+
                  '"valor": "5.00",'+
                  '"modalidadeAlteracao": 0,'+
                  '"modalidadeAgente": "AGPSS",'+
                  '"prestadorDoServicoDeSaque": "12345678"'+
                '}'+
              '}'+
            '},'+
            '"chave": "7d9f0335-8dcc-4054-9bf9-0dbd61d36906"'+
           '}');
end;

procedure TTestCobrancaImediataComSaquePIX.TearDown;
begin
  fACBrPixCob.Free;
  inherited TearDown;
end;

procedure TTestCobrancaImediataComSaquePIX.AtribuirELerValores;
begin
  fACBrPixCob.AsJSON := fJSON;
  CheckEquals(fACBrPixCob.devedor.cnpj, '12345678000195');
  CheckEquals(fACBrPixCob.devedor.nome, ACBrStr('Empresa de Servi�os SA'));
  CheckEquals(fACBrPixCob.valor.original, 0);
  CheckEquals(fACBrPixCob.valor.modalidadeAlteracao, False);
  CheckEquals(fACBrPixCob.valor.retirada.saque.valor, 5);
  CheckEquals(fACBrPixCob.valor.retirada.saque.modalidadeAlteracao, False);
  CheckTrue(fACBrPixCob.valor.retirada.saque.modalidadeAgente = tpixmaAGPSS);
  CheckEquals(fACBrPixCob.valor.retirada.saque.prestadorDoServicoDeSaque, '12345678');
  CheckEquals(fACBrPixCob.chave, '7d9f0335-8dcc-4054-9bf9-0dbd61d36906');
end;

procedure TTestCobrancaImediataComSaquePIX.AtribuirLerReatribuirEComparar;
var
  pc: TACBrPIXCobSolicitada;
  s: String;
begin
  fACBrPixCob.AsJSON := fJSON;
  s := fACBrPixCob.AsJSON;
  pc := TACBrPIXCobSolicitada.Create;
  try
    pc.AsJSON := s;
    CheckEquals(fACBrPixCob.devedor.cnpj, pc.devedor.cnpj);
    CheckEquals(fACBrPixCob.devedor.nome, pc.devedor.nome);
    CheckEquals(fACBrPixCob.valor.original, pc.valor.original);
    CheckEquals(fACBrPixCob.valor.modalidadeAlteracao, pc.valor.modalidadeAlteracao);
    CheckEquals(fACBrPixCob.valor.retirada.saque.valor, pc.valor.retirada.saque.valor);
    CheckEquals(fACBrPixCob.valor.retirada.saque.modalidadeAlteracao, pc.valor.retirada.saque.modalidadeAlteracao);
    CheckTrue(fACBrPixCob.valor.retirada.saque.modalidadeAgente = pc.valor.retirada.saque.modalidadeAgente);
    CheckEquals(fACBrPixCob.valor.retirada.saque.prestadorDoServicoDeSaque, pc.valor.retirada.saque.prestadorDoServicoDeSaque);
    CheckEquals(fACBrPixCob.chave, pc.chave);
  finally
    pc.Free;
  end;
end;

{ TTestCobrancaImediataComSaquePIX2 }

procedure TTestCobrancaImediataComSaquePIX2.SetUp;
begin
  inherited;
  fACBrPixCob := TACBrPIXCobSolicitada.Create;

  // Nota, os Fontes dessa Unit est�o em CP1252, por isso usamos ACBrStr()
  fJSON := ACBrStr(
           '{'+
            '"devedor": {'+
              '"cnpj": "12345678000195",'+
              '"nome": "Empresa de Servi�os SA"'+
            '},'+
            '"valor": {'+
              '"original": "0.00",'+
              '"modalidadeAlteracao": 0,'+
              '"retirada": {'+
                '"saque": {'+
                  '"valor": "20.00",'+
                  '"modalidadeAlteracao": 1,'+
                  '"modalidadeAgente": "AGPSS",'+
                  '"prestadorDoServicoDeSaque": "12345678"'+
                '}'+
              '}'+
            '},'+
            '"chave": "7d9f0335-8dcc-4054-9bf9-0dbd61d36906"'+
           '}');
end;

procedure TTestCobrancaImediataComSaquePIX2.TearDown;
begin
  fACBrPixCob.Free;
  inherited TearDown;
end;

procedure TTestCobrancaImediataComSaquePIX2.AtribuirELerValores;
begin
  fACBrPixCob.AsJSON := fJSON;
  CheckEquals(fACBrPixCob.devedor.cnpj, '12345678000195');
  CheckEquals(fACBrPixCob.devedor.nome, ACBrStr('Empresa de Servi�os SA'));
  CheckEquals(fACBrPixCob.valor.original, 0);
  CheckEquals(fACBrPixCob.valor.modalidadeAlteracao, False);
  CheckEquals(fACBrPixCob.valor.retirada.saque.valor, 20);
  CheckEquals(fACBrPixCob.valor.retirada.saque.modalidadeAlteracao, True);
  CheckTrue(fACBrPixCob.valor.retirada.saque.modalidadeAgente = tpixmaAGPSS);
  CheckEquals(fACBrPixCob.valor.retirada.saque.prestadorDoServicoDeSaque, '12345678');
  CheckEquals(fACBrPixCob.chave, '7d9f0335-8dcc-4054-9bf9-0dbd61d36906');
end;

procedure TTestCobrancaImediataComSaquePIX2.AtribuirLerReatribuirEComparar;
var
  pc: TACBrPIXCobSolicitada;
  s: String;
begin
  fACBrPixCob.AsJSON := fJSON;
  s := fACBrPixCob.AsJSON;
  pc := TACBrPIXCobSolicitada.Create;
  try
    pc.AsJSON := s;
    CheckEquals(fACBrPixCob.devedor.cnpj, pc.devedor.cnpj);
    CheckEquals(fACBrPixCob.devedor.nome, pc.devedor.nome);
    CheckEquals(fACBrPixCob.valor.original, pc.valor.original);
    CheckEquals(fACBrPixCob.valor.modalidadeAlteracao, pc.valor.modalidadeAlteracao);
    CheckEquals(fACBrPixCob.valor.retirada.saque.valor, pc.valor.retirada.saque.valor);
    CheckEquals(fACBrPixCob.valor.retirada.saque.modalidadeAlteracao, pc.valor.retirada.saque.modalidadeAlteracao);
    CheckTrue(fACBrPixCob.valor.retirada.saque.modalidadeAgente = pc.valor.retirada.saque.modalidadeAgente);
    CheckEquals(fACBrPixCob.valor.retirada.saque.prestadorDoServicoDeSaque, pc.valor.retirada.saque.prestadorDoServicoDeSaque);
    CheckEquals(fACBrPixCob.chave, pc.chave);
  finally
    pc.Free;
  end;
end;

{ TTestCobrancaImediataComSaquePIX3 }

procedure TTestCobrancaImediataComSaquePIX3.SetUp;
begin
  inherited;
  fACBrPixCob := TACBrPIXCobSolicitada.Create;

  // Nota, os Fontes dessa Unit est�o em CP1252, por isso usamos ACBrStr()
  fJSON := ACBrStr(
                '{'+
                  '"devedor": {'+
                    '"cnpj": "12345678000195",'+
                    '"nome": "Empresa de Servi�os SA"'+
                  '},'+
                  '"valor": {'+
                    '"original": "10.00",'+
                    '"modalidadeAlteracao": 0,'+
                    '"retirada": {'+
                      '"troco": {'+
                        '"valor": "0.00",'+
                        '"modalidadeAlteracao": 1,'+
                        '"modalidadeAgente": "AGPSS",'+
                        '"prestadorDoServicoDeSaque": "12345678"'+
                      '}'+
                    '}'+
                  '},'+
                  '"chave": "7d9f0335-8dcc-4054-9bf9-0dbd61d36906"'+
                '}');
end;

procedure TTestCobrancaImediataComSaquePIX3.TearDown;
begin
  fACBrPixCob.Free;
  inherited TearDown;
end;

procedure TTestCobrancaImediataComSaquePIX3.AtribuirELerValores;
begin
  fACBrPixCob.AsJSON := fJSON;
  CheckEquals(fACBrPixCob.devedor.cnpj, '12345678000195');
  CheckEquals(fACBrPixCob.devedor.nome, ACBrStr('Empresa de Servi�os SA'));
  CheckEquals(fACBrPixCob.valor.original, 10);
  CheckEquals(fACBrPixCob.valor.modalidadeAlteracao, False);
  CheckEquals(fACBrPixCob.valor.retirada.troco.valor, 0);
  CheckEquals(fACBrPixCob.valor.retirada.troco.modalidadeAlteracao, True);
  CheckTrue(fACBrPixCob.valor.retirada.troco.modalidadeAgente = tpixmaAGPSS);
  CheckEquals(fACBrPixCob.valor.retirada.troco.prestadorDoServicoDeSaque, '12345678');
  CheckEquals(fACBrPixCob.chave, '7d9f0335-8dcc-4054-9bf9-0dbd61d36906');
end;

procedure TTestCobrancaImediataComSaquePIX3.AtribuirLerReatribuirEComparar;
var
  pc: TACBrPIXCobSolicitada;
  s: String;
begin
  fACBrPixCob.AsJSON := fJSON;
  s := fACBrPixCob.AsJSON;
  pc := TACBrPIXCobSolicitada.Create;
  try
    pc.AsJSON := s;
    CheckEquals(fACBrPixCob.devedor.cnpj, pc.devedor.cnpj);
    CheckEquals(fACBrPixCob.devedor.nome, pc.devedor.nome);
    CheckEquals(fACBrPixCob.valor.original, pc.valor.original);
    CheckEquals(fACBrPixCob.valor.modalidadeAlteracao, pc.valor.modalidadeAlteracao);
    CheckEquals(fACBrPixCob.valor.retirada.troco.valor, pc.valor.retirada.troco.valor);
    CheckEquals(fACBrPixCob.valor.retirada.troco.modalidadeAlteracao, pc.valor.retirada.troco.modalidadeAlteracao);
    CheckTrue(fACBrPixCob.valor.retirada.troco.modalidadeAgente = pc.valor.retirada.troco.modalidadeAgente);
    CheckEquals(fACBrPixCob.valor.retirada.troco.prestadorDoServicoDeSaque, pc.valor.retirada.troco.prestadorDoServicoDeSaque);
    CheckEquals(fACBrPixCob.chave, pc.chave);
  finally
    pc.Free;
  end;
end;

procedure _RegisterTest(ATesteName: String; ATestClass: TClass);
begin
  {$IfDef DUNITX}
   TDUnitX.RegisterTestFixture( ATestClass, ATesteName );
  {$ELSE}
   RegisterTest(ATesteName, TTestCaseClass(ATestClass){$IfNDef FPC}.Suite{$EndIf} );
  {$EndIf}
end;

initialization

  _RegisterTest('ACBrPIXCD.Schemas', TTestCobrancaImediataExemplo1);
  _RegisterTest('ACBrPIXCD.Schemas', TTestCobrancaImediataComSaquePIX);
  _RegisterTest('ACBrPIXCD.Schemas', TTestCobrancaImediataComSaquePIX2);
  _RegisterTest('ACBrPIXCD.Schemas', TTestCobrancaImediataComSaquePIX3);

end.

