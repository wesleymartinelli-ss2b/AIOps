# Output — Q07

> **Status:** concluído  
> **Runbook:** [runbook-memoria-chronos.md](./runbook-memoria-chronos.md)

Resposta do Composer 2.5 ao prompt RISE.

---

## Entrega

Runbook procedural completo em markdown (PT-BR) com:

- **7 passos** (0–6): acknowledge → pods/HPA → eventos → logs/métricas → Ledger/Reactor → restart → rollback Argo CD
- Comandos `kubectl`, `aws sqs`, `argocd` por passo
- Tabela **verificação esperada** e **se falhar** em cada etapa
- **6 critérios** objetivos de escalação `@chronos-core`
- **5 critérios** de encerramento (+ 15 min estáveis)
- Checklist final + templates Slack

Documento completo: [`runbook-memoria-chronos.md`](./runbook-memoria-chronos.md).
