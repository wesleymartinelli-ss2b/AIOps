# Prompt — Q04 SQL transações Ledger

> **Status:** concluído  
> **Framework:** TAG  
> **Data de referência:** 2026-04-24

---

## [TASK]

Escreva uma **query SQL** (PostgreSQL) para o relatório mensal de transações do **Ledger**, solicitado por Jennifer Parker para apresentação à Goldie.

**Schema:**

```sql
CREATE TABLE transactions (
  id              BIGSERIAL PRIMARY KEY,
  customer_id     BIGINT NOT NULL REFERENCES customers(id),
  category        VARCHAR(32) NOT NULL,
  amount_cents    BIGINT NOT NULL,
  status          VARCHAR(16) NOT NULL,
  payment_method  VARCHAR(16),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at    TIMESTAMPTZ
);

CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_category ON transactions(category);

CREATE TABLE customers (
  id          BIGSERIAL PRIMARY KEY,
  segment     VARCHAR(16) NOT NULL,
  country     CHAR(2) NOT NULL,
  signup_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Regras de negócio:**

- Categorias: `subscription`, `one_time`, `refund`, `credit_adjustment`
- Apenas `status = 'completed'`
- `amount_cents` → exibir volume em **reais (BRL)** com **2 casas decimais**
- Recorte: **últimos 6 meses corridos** a partir de **2026-04-24**
- Agrupar por **mês (`YYYY-MM`)** e **categoria**
- Métricas por linha: **quantidade de transações** e **volume total em reais**
- Ordenação: mês crescente, depois categoria crescente

## [ACTION]

1. Filtrar transações completed no intervalo de 6 meses (use `completed_at`; se nulo, `created_at`).
2. Agrupar com `DATE_TRUNC` / `TO_CHAR` para mês `YYYY-MM`.
3. Calcular `COUNT(*)` e `SUM(amount_cents) / 100.0` com arredondamento.
4. Ordenar conforme especificado.
5. Entregar **apenas a query** em bloco SQL; comentários em **en_US** (opcional, breves).

## [GOAL]

SQL pronto para Jennifer executar no PostgreSQL e obter a tabela consolidada dos **últimos 6 meses** para a apresentação de crescimento por categoria.
