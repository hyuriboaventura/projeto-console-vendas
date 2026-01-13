# Projeto Console Vendas (Teste Técnico)

Aplicação console desenvolvida em Delphi para simular um sistema simples de cadastro, consultas e vendas de carros, atendendo aos requisitos de um teste técnico.

## Estrutura do Projeto

O projeto foi organizado em units, separando as responsabilidades:

- **UnitDB.pas**  
  Responsável por gerenciar a conexão com o banco de dados.

- **UnitClientes.pas**  
  Define a estrutura (classe) do objeto Cliente.

- **UnitCarros.pas**  
  Define a estrutura (classe) do objeto Carro.

- **UnitVendas.pas**  
  Lógica de vendas, consultas SQL e exclusões conforme regras do teste.

- **ConsoleVendas.dpr**  
  Aplicação console responsável pelo fluxo principal e execução das regras do teste.

## Tecnologias Utilizadas

- Delphi 10.1 Berlin
- Aplicação Console
- Banco de Dados: PostgreSQL
- Acesso a dados: FireDAC

## Funcionalidades

- Criação das tabelas do banco de dados
- Cadastro de clientes, carros e vendas
- Inserção automática de dados para testes
- Consultas SQL conforme regras do teste
- Exclusão de vendas conforme regras do teste
- Execução via menu em aplicação console

## Como Executar

1. Criar um banco de dados com o nome `sorteio`
2. Abrir o projeto no Delphi
3. Executar o arquivo `ConsoleVendas.dpr`

## Prints

As imagens do sistema em execução estão disponíveis na pasta `prints`.

## Observações

Todos os dados sensíveis utilizados no projeto, como CPF, são fictícios e foram gerados automaticamente apenas para fins de teste.

---

Autor: Hyuri Boaventura
