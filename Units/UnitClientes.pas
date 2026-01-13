unit UnitClientes;

interface

uses
  System.SysUtils, StrUtils, UnitDB;

type

  TClientes = class
    private
    FIDCliente: Integer;
    FNome: string;
    FCPF: string;
    public
    property IDCliente: Integer read FIDCliente write FIDCliente;
    property Nome: string read FNome write FNome;
    property CPF: string read FCPF write FCPF;

    function InserirCliente(pConexaoBanco: TDB): string;
  end;

implementation

{ TCliente }

function TClientes.InserirCliente(pConexaoBanco: TDB): string;
var
  Comando: string;
begin
  Comando := 'INSERT INTO clientes (nome, cpf) VALUES (' +
          QuotedStr(FNome) + ', ' + QuotedStr(FCPF) + ') Returning idcliente; ';

  Result:= pConexaoBanco.InserirDadosBD(Comando);
end;

end.
