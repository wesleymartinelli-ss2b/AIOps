# Output — Q04

> **Status:** concluído  
> **Query gerada:** [query.sql](./query.sql)

Resposta do Composer 2.5 ao prompt TAG.

---

## Query SQL

```sql
-- Monthly transaction report by category (Ledger / Hill Valley Tech)
-- Reference date: 2026-04-24 | Last 6 rolling months

SELECT
  TO_CHAR(
    DATE_TRUNC('month', COALESCE(t.completed_at, t.created_at)),
    'YYYY-MM'
  ) AS mes,
  t.category AS categoria,
  COUNT(*) AS quantidade_transacoes,
  ROUND(SUM(t.amount_cents) / 100.0, 2) AS volume_total_brl
FROM transactions t
WHERE t.status = 'completed'
  AND COALESCE(t.completed_at, t.created_at) >= TIMESTAMPTZ '2025-10-24 00:00:00+00'
  AND COALESCE(t.completed_at, t.created_at) <  TIMESTAMPTZ '2026-04-25 00:00:00+00'
GROUP BY
  DATE_TRUNC('month', COALESCE(t.completed_at, t.created_at)),
  t.category
ORDER BY
  mes ASC,
  categoria ASC;
```

---

## Assumptions

| Item | Decisão |
|------|---------|
| **Janela de 6 meses** | Corridos a partir de 2026-04-24 → de `2025-10-24` (inclusivo) até `2026-04-24` (inclusivo), implementado com `< 2026-04-25`. |
| **Data da transação** | `completed_at`; fallback para `created_at` se `completed_at` for NULL. |
| **Volume em reais** | `amount_cents / 100.0` com `ROUND(..., 2)`. |
| **Categorias** | Não filtradas explicitamente — todas as `completed` entram; em produção aparecem `subscription`, `one_time`, `refund`, `credit_adjustment`. |

Meses cobertos no agrupamento: **2025-10**, **2025-11**, **2025-12**, **2026-01**, **2026-02**, **2026-03**, **2026-04** (transações dentro da janela rolling).
