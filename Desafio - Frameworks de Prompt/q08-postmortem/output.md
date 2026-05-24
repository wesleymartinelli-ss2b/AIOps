# Output — Q08

> **Status:** concluído  
> **Postmortem:** [postmortem-chronos.md](./postmortem-chronos.md)

Resposta do Composer 2.5 ao prompt **CARE**.

---

## Decisão recomendada (síntese)

**Rollback imediato para v2.47.0** — não scaling emergencial como ação primária.

| Evidência | Detalhe |
|-----------|---------|
| Pool exhausted | 20/20, 147 waiting |
| Timeout | 2000 ms (reduzido em v2.48.0) |
| Endpoint novo | `/v2/transactions/batch` falhando |
| RDS | 240/250 conexões ≈ 12 pods × pool 20 |
| Reactor | 50k msgs, lag 18 min |

**3 ações imediatas:** rollback Argo CD · drenar Reactor · congelar deploys.

Documento completo: [`postmortem-chronos.md`](./postmortem-chronos.md).
