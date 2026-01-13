program ConsoleVendas;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.DApt,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client,
  UnitDB in 'UnitDB.pas',
  UnitClientes in 'UnitClientes.pas',
  UnitCarros in 'UnitCarros.pas',
  UnitVendas in 'UnitVendas.pas';

const
  cNomes: array[0..4] of string = ('Hyuri', 'Mykaelle', 'Fred', 'Lucas', 'Layla');
  cCPF: array[0..4] of string = ('37694748052', '71456179004', '00231270070', '14985447030', '01543829066');
  cModelo: array[0..4] of string = ('Uno', 'Argo', 'Marea', 'Fiorino', 'Strada');
  cDataLancamento: array[0..4] of string = ('04/10/2004', '02/02/2022', '02/03/2021', '02/10/2025', '02/01/2022');
  cDataVenda: array[0..4] of string = ('01/10/2025', '02/11/2025', '03/12/2025', '10/01/2026', '01/01/2026');

var
  vDB: TDB;
  vClientes: TClientes;
  vCarros: TCarros;
  vVendas: TVendas;
  vQuery: TFDQuery;
  i, vOpcao: Integer;
  vData, vIdCliente, vIdCarro, vIdVenda, vAux, vComando: string;

begin
  vDB := TDB.Create;

  vData := '';
  vIdCliente := '';
  vIdCarro := '';
  vIdVenda := '';
  vAux := '';
  vComando := '';

  try
    repeat
      Writeln('====== CONSOLE VENDAS ==============================================');
      Writeln('                                                                    ');
      Writeln('Selecione uma das opções abaixo para continuar ou tecle 0 para sair. ');
      Writeln('                                                                    ');
      Writeln('** BANCO DE DADOS **');
      Writeln('--------------------------------------------------------------------');
      Writeln('1. Criar tabelas ');
      Writeln('--------------------------------------------------------------------');
      Writeln('** CADASTRO **');
      Writeln('--------------------------------------------------------------------');
      Writeln('2. Inserir cliente');
      Writeln('3. Inserir carro');
      Writeln('4. Inserir venda');
      Writeln('5. Inserir dados de teste (5, clientes, 5 carros e vendas) ');
      Writeln('6. Excluir vendas de clientes não sorteados ');
      Writeln('--------------------------------------------------------------------');
      Writeln('** CONSULTAS **');
      Writeln('--------------------------------------------------------------------');
      Writeln('7. Quantidade de vendas do carro Marea ');
      Writeln('8. Quantidade de vendas do carro Uno por cliente ');
      Writeln('9. Quantidade de clientes que não efetuaram venda ');
      Writeln('10. Listar clientes sorteados ');
      Writeln('--------------------------------------------------------------------');
      Writeln('                                                                    ');
      Readln(vOpcao);

      case vOpcao of
        1: //Criar Tabelas
          begin
            vDB.CriarTabelas;
            Writeln('Tabelas criadas com sucesso!');
          end;

        2: //Inserir Cliente
          begin
            vClientes := TClientes.Create;

            try
              Write('Nome: ');
              Readln(vAux);
              vClientes.Nome := vAux;

              Write('CPF: ');
              Readln(vAux);
              vClientes.CPF := vAux;

              vIdCliente := vClientes.InserirCliente(vDB);
              Writeln('Cliente inserido com sucesso! ' + 'Código: ' + vIdCliente);
            finally
              vClientes.Free;
            end;
          end;

        3: //Inserir Carro
          begin
            vCarros := TCarros.Create;

            try
              Write('Modelo: ');
              Readln(vAux);
              vCarros.Modelo := vAux;

              Write('Data de Lançamento (dd/mm/aaaa): ');
              Readln(vData);
              vCarros.DataLancamento := StrToDate(vData);

              vIdCarro := vCarros.InserirCarro(vDB);
              Writeln('Carro inserido com sucesso! ' + 'Código: ' + vIdCarro);
            finally
              vCarros.Free;
            end;
          end;

        4:  //Inserir Venda
          Begin
            vVendas := TVendas.Create;

            try
              Write('idcliente: ');
              Readln(vIdCliente);
              vVendas.IDCliente := StrToInt(vIdCliente);

              Write('idcarro: ');
              Readln(vIdCarro);
              vVendas.IDCarro := StrToInt(vIdCarro);

              Write('Data de venda (dd/mm/aaaa): ');
              Readln(vData);
              vVendas.DataVenda := StrToDate(vData);

              vIdVenda := vVendas.InserirVenda(vDB);
              Writeln('Venda inserida com sucesso! ' + 'Código: ' + vIdVenda);
            finally
              vVendas.Free;
            end;
          End;

        5:  //Inserir 5 clientes, 5 carros e vendas
          Begin
            vDB.Conn.StartTransaction;
            try
              for I := Low(cNomes) to High(cNomes) do
              begin
                vClientes := TClientes.Create;
                vCarros := TCarros.Create;
                vVendas := TVendas.Create;

                try
                  vClientes.Nome := cNomes[I];
                  vClientes.CPF := cCPF[I];
                  vIdCliente := vClientes.InserirCliente(vDB);

                  vCarros.Modelo := cModelo[I];
                  vData := cDataLancamento[I];
                  vCarros.DataLancamento := StrToDate(vData);
                  vIdCarro := vCarros.InserirCarro(vDB);

                  vVendas.IDCliente := StrToInt(vIdCliente);
                  vVendas.IDCarro := StrToInt(vIdCarro);
                  vData := cDataVenda[I];
                  vVendas.DataVenda := StrToDate(vData);

                  vIdVenda := vVendas.InserirVenda(vDB);

                  Writeln('Venda inserida com sucesso! ' + 'Código: ' + vIdVenda);
                finally
                  vClientes.Free;
                  vCarros.Free;
                  vVendas.Free;
                end;
              end;

              vDB.Conn.Commit;
            except
              vDB.Conn.Rollback;
              raise;
            end;
          End;

        6: //Excluir vendas de clientes não sorteados
          begin
            vDB.Conn.StartTransaction;
            try
              vVendas.ExcluirVendasNaoSorteados(vDB);
              vDB.Conn.Commit;
              Writeln('Vendas excluídas com sucesso!');
            except
              vDB.Conn.Rollback;
              raise;
            end;
          end;

        7: //Consultar vendas do carro Marea
          begin
            try
              vQuery := vDB.ExecutarSQL(vVendas.MontaSQLVendasMarea);

              if not vQuery.Eof then
              begin
                vAux := vQuery.Fields[0].AsString;
                Writeln('Quantidade de vendas do carro Marea: ' + vAux);
              end;
            finally
              vQuery.Free;
            end;
          end;

        8://Consultar vendas do carro Uno por cliente
          begin
            try
              vQuery := vDB.ExecutarSQL(vVendas.MontaSQLVendasUnoPorCliente);

              if vQuery.IsEmpty then
                Writeln('Nenhuma venda encontrada para o carro Uno!');

              while not vQuery.Eof do
              begin
                Writeln('Cliente: ' + vQuery.FieldByName('nome').AsString +
                        ' | Vendas Uno: ' + vQuery.FieldByName('total_vendas').AsString);

                vQuery.Next;
              end;
            finally
              vQuery.Free;
            end;
          end;

        9: //Listar clientes que não efetuaram venda
          begin
            try
              vQuery := vDB.ExecutarSQL(vVendas.MontaSQLClientesSemVenda);

              if not vQuery.Eof then
              begin
                vAux := vQuery.Fields[0].AsString;
                Writeln('Quantidade de clientes que não efetuaram venda: ' + vAux);
              end;
            finally
              vQuery.Free;
            end;
          end;

        10: //Clientes sorteados
           begin
             try
               vQuery := vDB.ExecutarSQL(vVendas.MontaSQLClientesSorteados);

               if vQuery.IsEmpty then
                Writeln('Nenhum registro encontrado!');

                while not vQuery.Eof do
                begin
                  Writeln('Cliente: ' + vQuery.FieldByName('nome').AsString +
                          ' | Modelo: ' + vQuery.FieldByName('modelo').AsString +
                          ' | Data Venda: ' + vQuery.FieldByName('data_venda').AsString);

                  vQuery.Next;
                end;
             finally
              vQuery.Free;
             end;
           end
      else
        Writeln('Opcao invalida! Tente novamente.');
      end;

      if vOpcao <> 0 then
      begin
        Writeln('                                      ');
        Writeln('Pressione ENTER para voltar ao menu...');
        Readln;
      end;

    until vOpcao = 0;

  finally
    vDB.Free;
  end;
end.
