# Justificativa — Q05 (BAB)

> **Status:** concluído

| Componente | Onde aparece no prompt |
|------------|------------------------|
| **Before** | Seção `[BEFORE]`: YAML legado completo + lista de problemas (1 réplica, latest, secrets expostos) — define **estado atual**. |
| **After** | Seção `[AFTER]`: bullet list do padrão HVT (HA, imagem versionada, secretKeyRef, resources, probes, securityContext) — define **estado desejado**. |
| **Bridge** | Seção `[BRIDGE]`: 5 instruções de transformação (preservar identidade, substituir secrets, adicionar requisitos, comentários en_US, YAML apply-ready) — define **como ir de A para B**. |

BAB foi indicado no enunciado porque a tarefa é uma **transformação de estado** (legado → produção moderna), não uma tarefa rápida isolada (RTF) nem análise orientada a meta (TAG).
