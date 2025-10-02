```md
# Projeto de Banco de Dados para E-commerce (MySQL)

Este repositório contém o esquema de um banco de dados relacional para um sistema de e-commerce, implementado em MySQL. O projeto inclui a criação de tabelas, inserção de dados de exemplo e uma coleção de consultas SQL para extrair informações de negócio relevantes.

## Visão Geral do Projeto

O objetivo deste projeto é modelar os principais processos de um e-commerce, abrangendo:
* **Clientes:** Cadastro de pessoas físicas (PF) e jurídicas (PJ).
* **Produtos:** Catálogo de produtos, estoque e fornecedores.
* **Pedidos:** Ciclo de vida de um pedido, desde a criação até o pagamento.
* **Vendedores:** Associação de vendedores aos pedidos.
* **Estrutura Flexível:** Uma entidade central `people` permite que uma mesma pessoa possa ser cliente, vendedor ou fornecedor, evitando duplicidade de dados.

## Estrutura do Banco de Dados

O esquema foi projetado de forma normalizada para garantir a integridade e a escalabilidade dos dados. As principais tabelas são:

* `people`: Tabela central que armazena informações básicas de indivíduos ou empresas. Possui flags (`is_seller`, `is_supplier`) para identificar seus papéis.
* `customers`: Armazena dados específicos de clientes, com uma validação para diferenciar PF (com CPF) e PJ (com CNPJ).
* `products`: Contém o catálogo de produtos com informações como SKU, nome e preço.
* `inventory`: Controla a quantidade de cada produto em estoque.
* `suppliers`: Fornecedores de produtos, vinculados à tabela `people`.
* `sellers`: Vendedores da plataforma, também vinculados à tabela `people`.
* `orders`: Registra todos os pedidos feitos pelos clientes, associando cliente, vendedor e endereço de entrega.
* `order_items`: Tabela associativa que detalha os produtos, quantidades e preços de cada pedido.
* `payment_methods` e `order_payments`: Gerenciam as formas e os registros de pagamento.


## Como Usar

Para configurar o banco de dados em seu ambiente local, siga os passos abaixo.

**Pré-requisitos:**
* Um servidor MySQL instalado.
* Um cliente de banco de dados, como o MySQL Workbench.

**Instruções:**
1.  **Crie o Banco de Dados:** Abra seu cliente de banco de dados e conecte-se ao servidor MySQL.
2.  **Execute o Script de Criação:** Copie todo o conteúdo do arquivo `schema.sql` para uma nova janela de consulta.
3.  **Execute:** Rode o script inteiro. Ele irá:
    * Criar o schema `ecommerce`.
    * Criar todas as tabelas e seus relacionamentos.
    * Inserir dados de exemplo para popular o banco.
4.  **Verifique a Instalação:** Após a execução, atualize a lista de schemas. Você verá o banco `ecommerce` com todas as tabelas e dados prontos para uso.

## Consultas de Exemplo (`consultas.sql`)

O arquivo `consultas.sql` contém uma série de queries para demonstrar como extrair insights do banco de dados. Abaixo está a descrição de cada uma delas:

1.  **Listar todos os produtos:**
    * **Propósito:** Uma visão geral de todos os itens cadastrados no catálogo, ordenados por nome.

2.  **Verificar produtos com estoque baixo:**
    * **Propósito:** Identificar produtos que precisam de reposição (com menos de 20 unidades em estoque).

3.  **Calcular o valor total por pedido:**
    * **Propósito:** Derivar o valor total de cada pedido somando os itens, útil para conferência e relatórios.

4.  **Ordenar clientes por maior valor gasto:**
    * **Propósito:** Criar um ranking de clientes com base no total de compras, fundamental para estratégias de fidelização.

5.  **Filtrar clientes com mais de um pedido:**
    * **Propósito:** Identificar clientes recorrentes.

6.  **Listar produtos, seus fornecedores e estoque:**
    * **Propósito:** Uma consulta completa para gestão de suprimentos, mostrando quem fornece cada produto e a quantidade disponível.

7.  **Identificar se algum vendedor também é fornecedor:**
    * **Propósito:** Verificar a existência de entidades com múltiplos papéis na plataforma.

8.  **Exibir a relação de produtos por fornecedor:**
    * **Propósito:** Gerar um catálogo que agrupa quais produtos cada fornecedor oferece.

9.  **Ranking dos 5 produtos mais vendidos (por valor):**
    * **Propósito:** Identificar os produtos de maior receita para o negócio.

10. **Encontrar clientes sem forma de pagamento cadastrada:**
    * **Propósito:** Identificar possíveis pontos de atrito no processo de compra ou clientes com cadastro incompleto.

11. **Relatório de vendas mensais (últimos 6 meses):**
    * **Propósito:** Acompanhar o desempenho de vendas ao longo do tempo.

12. **Listar vendedores que venderam mais de R$ 1000:**
    * **Propósito:** Identificar vendedores de alta performance, útil para comissionamento e análise de equipe.
```
