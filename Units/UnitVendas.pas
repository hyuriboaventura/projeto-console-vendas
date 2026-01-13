unit UnitVendas;

interface

uses
  System.SysUtils, UnitDB;

type

  TVendas = class
    private
    FIDVenda: Integer;
    FIDCliente: Integer;
    FIDCarro: Integer;
    FDataVenda: TDateTime;
    public
    property IDVenda: Integer read FIDVenda write FIDVenda;
    property IDCliente: Integer read FIDCliente write FIDCliente;
    property IDCarro: Integer read FIDCarro write FIDCarro;
    property DataVenda: TDateTime read FDataVenda write FDataVenda;

    function InserirVenda(pConexaoBanco: TDB): string;
    function MontaSQLVendasMarea: string;
    function MontaSQLVendasUnoPorCliente: string;
    function MontaSQLClientesSemVenda: string;
    function MontaSQLClientesSorteados: string;
    procedure ExcluirVendasNaoSorteados(pConexaoBanco: TDB);
  end;

implementation

{ TVendas }

function TVendas.InserirVenda(pConexaoBanco: TDB): string;
var
  Comando: string;
begin
  Comando := 'INSERT INTO vendas (idcliente, idcarro, data_venda) VALUES (' +
          IntToStr(FIDCliente) + ', ' +
          IntToStr(FIDCarro) + ', ' +
          QuotedStr(FormatDateTime('yyyy-mm-dd', FDataVenda)) + ') Returning idvenda;';

  Result := pConexaoBanco.InserirDadosBD(Comando);
end;

procedure TVendas.ExcluirVendasNaoSorteados(pConexaoBanco: TDB);
var
  Comando: string;
begin
  Comando := 'DELETE FROM vendas v ' +
             'WHERE NOT EXISTS ( ' +
				     '                  SELECT 1 ' +
             '                  FROM ( ' +
             '                        SELECT v2.idcliente ' +
             '                        FROM vendas v2 ' +
             '                          INNER JOIN clientes c ON c.idcliente = v2.idcliente ' +
             '                          INNER JOIN carros ca ON ca.idcarro = v2.idcarro ' +
             '                        WHERE ca.modelo = ''Marea'' ' +
             '                          AND c.cpf LIKE ''0%'' ' +
             '                          AND ca.data_lancamento >= ''2021-01-01'' ' +
             '                          AND ca.data_lancamento < ''2022-01-01'' ' +
             '                          AND NOT EXISTS ( ' +
             '                                          SELECT 1 ' +
             '                                          FROM vendas v3 ' +
             '                                            INNER JOIN carros ca2 ON ca2.idcarro = v3.idcarro ' +
             '                                          WHERE v3.idcliente = c.idcliente ' +
             '                                            AND ca2.modelo = ''Marea'' ' +
             '                                          GROUP BY v3.idcliente ' +
             '                                          HAVING COUNT(*) >= 2 ' +
             '                                          ) ' +
             '                        GROUP BY v2.idcliente ' +
             '                        ORDER BY MIN(v2.data_venda) ' +
             '                        LIMIT 15 ' +
             '                        ) AS clientes_sorteados ' +
             '                  WHERE clientes_sorteados.idcliente = v.idcliente ' +
             '                  ); ';

  pConexaoBanco.Conn.ExecSQL(Comando);
end;

function TVendas.MontaSQLClientesSemVenda: string;
begin
  Result := 'SELECT COUNT(c.idcliente) AS qtd_nao_vendidos ' +
            'FROM clientes c ' +
            'WHERE NOT EXISTS ( ' +
            '                  SELECT v.idcliente ' +
            '                  FROM vendas v ' +
            '                  WHERE v.idcliente = c.idcliente ' +
            '                  ); ';
end;

function TVendas.MontaSQLClientesSorteados: string;
begin
  Result := 'SELECT v.idvenda, c.nome, ca.modelo , v.data_venda ' +
            'FROM vendas v ' +
            '  INNER JOIN clientes c ON c.idcliente = v.idcliente ' +
            '  INNER JOIN carros ca ON ca.idcarro = v.idcarro ' +
            'WHERE ca.modelo = ''Marea'' ' +
            '  AND c.cpf LIKE ''0%'' ' +
            '  AND ca.data_lancamento >= ''2021-01-01'' ' +
            '  AND ca.data_lancamento < ''2022-01-01'' ' +
            '  AND NOT EXISTS ( ' +
            '                  SELECT 1 ' +
            '                  FROM vendas v2 ' +
            '     	             INNER JOIN carros ca2 ON ca2.idcarro = v2.idcarro ' +
            '                  WHERE v2.idcliente = c.idcliente ' +
            '        	           AND ca2.modelo = ''Marea'' ' +
            '                  GROUP BY v2.idcliente ' +
            '                  HAVING COUNT(*) >= 2  ' +
            '                 ) ' + //Caso tenha comprado dois carros do modelo Marea está desclassificado
            'ORDER BY v.data_venda ASC ' +
            'LIMIT 15; '; //Considerando apenas os 15 primeiros registros
end;

function TVendas.MontaSQLVendasMarea: string;
begin
  Result := 'SELECT COUNT(v.idvenda) AS qtd_vendas_marea ' +
            'FROM vendas v ' +
            '  INNER JOIN carros c ON c.idcarro = v.idcarro ' +
            'WHERE c.modelo = ''Marea''; ';
end;

function TVendas.MontaSQLVendasUnoPorCliente: string;
begin
  Result := 'SELECT cl.idcliente, ' +
            '       cl.nome, ' +
            '       COUNT(v.idvenda) AS total_vendas ' +
            'FROM vendas v ' +
            '  INNER JOIN carros c ON c.idcarro = v.idcarro ' +
            '  INNER JOIN clientes cl ON cl.idcliente = v.idcliente ' +
            'WHERE c.modelo = ''Uno'' ' +
            'GROUP BY cl.idcliente, cl.nome; ';
end;

end.

