object frlDANFeEventoRL: TfrlDANFeEventoRL
  Left = 283
  Top = 181
  Caption = 'frlDANFeEventoLR'
  ClientHeight = 595
  ClientWidth = 794
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poMainFormCenter
  Scaled = False
  TextHeight = 13
  object RLEvento: TRLReport
    Left = 0
    Top = -2
    Width = 794
    Height = 1123
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    PreviewOptions.ShowModal = True
    PreviewOptions.Caption = 'DANFe'
    ShowProgress = False
  end
  object RLPDFFilter1: TRLPDFFilter
    DocumentInfo.Author = 'FortesReport 3.23 - Copyright '#169' 1999-2009 Fortes Inform'#225'tica'
    DocumentInfo.Creator = 'Projeto ACBr (Componente NF-e)'
    DisplayName = 'Documento PDF'
    Left = 416
    Top = 104
  end
end
