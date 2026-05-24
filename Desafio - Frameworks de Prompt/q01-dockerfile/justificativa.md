# Justificativa — Q01 (RTF)

> **Status:** concluído

| Componente | Onde aparece no prompt |
|------------|------------------------|
| **Role** | Seção `[ROLE]`: *"engenheiro DevOps sênior, especialista em containers Python para Kubernetes em produção"* — define expertise e tom técnico. |
| **Task** | Seção `[TASK]`: estrutura do projeto, `requirements.txt`, porta 8080, gunicorn, env vars `DATABASE_URL`/`API_KEY`, usuário non-root, boas práticas — descreve **o que** gerar e **com quais restrições**. |
| **Format** | Seção `[FORMAT]`: entregar só o Dockerfile em bloco de código, comentários en_US, assumptions opcionais em PT-BR — define **como** deve vir a resposta. |

O framework RTF foi adequado porque a tarefa é **rápida e bem definida** (um artefato único), sem necessidade de contexto narrativo extenso (CARE) ou transformação before/after (BAB).
