unit UnitCarros;

interface

uses
  System.SysUtils, StrUtils, UnitDB;

type

  TCarros = class
    private
    FIDCarro: Integer;
    FModelo: string;
    FDataLancamento: TDateTime;
    public
    property IDCarro: Integer read FIDCarro write FIDCarro;
    property Modelo: string read FModelo write FModelo;
    property DataLancamento: TDateTime read FDataLancamento write FDataLancamento;

    function InserirCarro(pConexaoBanco: TDB): string;
  end;

implementation

{ TCarros }

function TCarros.InserirCarro(pConexaoBanco: TDB): string;
var
  vSQL: string;
begin
  vSQL := 'INSERT INTO carros (modelo, data_lancamento) VALUES (' +
          QuotedStr(FModelo) + ', ' + QuotedStr(FormatDateTime('yyyy-mm-dd', FDataLancamento)) +
          ') Returning idcarro; ';

  Result := pConexaoBanco.InserirDadosBD(vSQL);
end;

end.

