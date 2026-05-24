# Justificativa — Q07 (RISE)

> **Status:** concluído

| Componente | Onde aparece no prompt |
|------------|------------------------|
| **Role** | Seção `[ROLE]`: autor de runbooks SRE, público plantonista sem deep knowledge — define tom e nível de detalhe. |
| **Input** | Seção `[INPUT]`: alerta exato, tabela do ambiente (EKS, HPA, Argo CD, deps, ferramentas, Slack, SLA escalação) — contexto operacional. |
| **Steps** | Seção `[STEPS]`: estrutura obrigatória por passo (ação, comando, verificação, se falhar) + lista mínima de cobertura (triagem → encerramento). |
| **Expectation** | Seção `[EXPECTATION]`: markdown PT-BR, ≤ 40 min, autossuficiente, checklist e template Slack — critérios de sucesso da entrega. |

RISE foi indicado no enunciado porque o deliverable é um **workflow procedural** com passos claros e resultado mensurável (incidente encerrado), não análise estratégica (TAG) nem transformação de artefato (BAB).
