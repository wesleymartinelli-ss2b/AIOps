# Justificativa — Q02 (RTF)

> **Status:** concluído

| Componente | Onde aparece no prompt |
|------------|------------------------|
| **Role** | Seção `[ROLE]`: *"engenheiro SRE sênior, especialista em backup e restore de PostgreSQL em AWS"* — define o perfil técnico esperado. |
| **Task** | Seção `[TASK]`: tabela do ambiente (host, porta, banco, S3, paths, retenção) + lista numerada das 6 ações obrigatórias (pg_dump, gzip, upload, retenção 30d, log, exit code). |
| **Format** | Seção `[FORMAT]`: script único em bloco `bash`, comentários en_US, 3 linhas de cron em PT-BR ao final — define forma da entrega. |

RTF foi o framework indicado no enunciado e adequado à tarefa operacional bem delimitada (um script, requisitos explícitos).
