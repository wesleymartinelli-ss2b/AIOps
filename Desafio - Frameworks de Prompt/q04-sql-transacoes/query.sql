-- Monthly transaction report by category (Ledger / Hill Valley Tech)
-- Reference date: 2026-04-24 | Last 6 rolling months
-- Jennifer Parker -> presentation to Goldie Wilson

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
  -- Rolling 6 months from reference date 2026-04-24 (inclusive start, exclusive end+1 day)
  AND COALESCE(t.completed_at, t.created_at) >= TIMESTAMPTZ '2025-10-24 00:00:00+00'
  AND COALESCE(t.completed_at, t.created_at) <  TIMESTAMPTZ '2026-04-25 00:00:00+00'
GROUP BY
  DATE_TRUNC('month', COALESCE(t.completed_at, t.created_at)),
  t.category
ORDER BY
  mes ASC,
  categoria ASC;
