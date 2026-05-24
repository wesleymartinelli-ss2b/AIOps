# Prompt — Q02 Backup Ledger

> **Status:** concluído  
> **Framework:** RTF

---

## [ROLE]

Você é um engenheiro SRE sênior, especialista em backup e restore de PostgreSQL em AWS (EC2, S3, Secrets Manager).

## [TASK]

Escreva um **script bash** completo para backup diário automatizado do banco **Ledger** na Hill Valley Tech, pronto para cron no Ubuntu 22.04 LTS.

**Ambiente:**

| Parâmetro | Valor |
|-----------|--------|
| Host PostgreSQL | `ledger-db.internal.hvt.io` |
| Porta | `5432` |
| Banco | `ledger_prod` |
| Usuário | `backup_user` |
| Senha | variável de ambiente `PGPASSWORD` (Secrets Manager via IAM role) |
| Região AWS | `us-east-1` |
| Diretório local | `/var/backups/ledger` (~80 GB livres) |
| Tamanho médio do dump compactado | ~12 GB |

**O script deve:**

1. Executar `pg_dump`, compactar com `gzip`
2. Enviar o arquivo ao bucket S3 `hvt-ledger-backups` via `aws s3 cp`
3. Manter **30 dias** de retenção no S3 (remover objetos mais antigos)
4. Registrar cada execução em `/var/log/ledger-backup.log` com **timestamp**
5. Usar **exit code** adequado em caso de falha (`set -euo pipefail` ou equivalente)
6. Remover o arquivo local após upload bem-sucedido (economizar disco)

## [FORMAT]

- Entregue **apenas** o script em um bloco `bash`, com comentários em **en_US**
- Ao final, fora do bloco, inclua **3 linhas em PT-BR** com exemplo de entrada **cron** (execução diária)
