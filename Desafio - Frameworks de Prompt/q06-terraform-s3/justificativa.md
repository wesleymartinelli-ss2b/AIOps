# Justificativa — Q06 (CARE)

> **Status:** concluído

| Componente | Onde aparece no prompt |
|------------|------------------------|
| **Context** | Seção `[CONTEXT]`: padrão Strickland (tags, prefixo, requisitos S3, variables) + trecho do módulo VPC de referência — pano de fundo denso e regras de compliance. |
| **Action** | Seção `[ACTION]`: lista de arquivos a criar (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`) e variáveis mínimas — o que fazer. |
| **Result** | Seção `[RESULT]`: módulo aderente, reutilizável, sem secrets, pronto para plan/apply — entrega esperada. |
| **Example** | Seção `[EXAMPLE]`: `examples/basic/main.tf` chamando o módulo no estilo VPC — modelo concreto de consumo. |

CARE foi indicado no enunciado porque há **contexto denso** (compliance + exemplo VPC) e a saída deve ser **replicável** por outros times via Example.
