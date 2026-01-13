unit UnitDB;

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.DApt,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client;

type
  TDB = class
  private
    FConn: TFDConnection;
    FDriver: TFDPhysPgDriverLink;
  public
    constructor Create;
    destructor Destroy; override;

    procedure CriarTabelas;
    function InserirDadosBD(pComando: string): string;
    function ExecutarSQL(pComando: string): TFDQuery;

    property Conn: TFDConnection read FConn;
  end;

implementation

{ TDB }

constructor TDB.Create;
begin
  inherited;
  FConn := TFDConnection.Create(nil);
  FDriver := TFDPhysPgDriverLink.Create(nil);

  FConn.Params.DriverID := 'PG';
  FConn.Params.Database := 'sorteio';
  FConn.Params.UserName := 'postgres';
  FConn.Params.Password := '@Ch3ls34';
  FConn.Params.Add('Server=localhost');
  FConn.Params.Add('Port=5432');
  FConn.LoginPrompt := False;
end;

procedure TDB.CriarTabelas;
begin
  FConn.StartTransaction;

  try
    FConn.ExecSQL('CREATE TABLE IF NOT EXISTS public.clientes (' +
                  '  idcliente BIGSERIAL, ' +
                  '  nome VARCHAR(100) NOT NULL, ' +
                  '  cpf VARCHAR(11) NOT NULL, ' +
                  '  CONSTRAINT clientes_pkey PRIMARY KEY(idcliente)); ');

    FConn.ExecSQL('CREATE TABLE IF NOT EXISTS public.carros (' +
                  '  idcarro BIGSERIAL, ' +
                  '  modelo VARCHAR(50) NOT NULL, ' +
                  '  data_lancamento DATE NOT NULL, ' +
                  ' CONSTRAINT veiculos_pkey PRIMARY KEY(idcarro)); ');

    FConn.ExecSQL('CREATE TABLE IF NOT EXISTS public.vendas ( ' +
                  '  idvenda BIGSERIAL, ' +
                  '  idcliente INTEGER NOT NULL, ' +
                  '  idcarro INTEGER NOT NULL, ' +
                  '  data_venda DATE NOT NULL, ' +
                  '  CONSTRAINT vendas_pkey PRIMARY KEY(idvenda), ' +
                  '  CONSTRAINT vendas_idcarro_fkey FOREIGN KEY (idcarro) ' +
                  '    REFERENCES public.carros(idcarro) ' +
                  '    ON DELETE NO ACTION ' +
                  '    ON UPDATE NO ACTION ' +
                  '    NOT DEFERRABLE, ' +
                  '  CONSTRAINT vendas_idcliente_fkey FOREIGN KEY (idcliente) ' +
                  '    REFERENCES public.clientes(idcliente) ' +
                  '    ON DELETE NO ACTION ' +
                  '    ON UPDATE NO ACTION ' +
                  '    NOT DEFERRABLE); ');

    FConn.Commit;
  except
    FConn.Rollback;
    raise;
  end;
end;

function TDB.InserirDadosBD(pComando: string): string;
var
  vQuery: TFDQuery;
begin
  Result := '';
  vQuery := TFDQuery.Create(nil);

  try
    vQuery.Connection := FConn;
    vQuery.SQL.Text := pComando;
    vQuery.Open;

    if not vQuery.Eof then
      Result := vQuery.Fields[0].AsString;
  finally
    vQuery.Free;
  end;
end;

function TDB.ExecutarSQL(pComando: string): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FConn;
  Result.SQL.Text := pComando;
  Result.Open;
end;

destructor TDB.Destroy;
begin
  FDriver.Free;
  FConn.Free;
  inherited;
end;

end.
