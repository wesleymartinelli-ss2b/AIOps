# Output — Q02

> **Status:** concluído  
> **Artefato gerado:** [backup-ledger.sh](./backup-ledger.sh)

Resposta do Composer 2.5 ao prompt RTF.

---

## Script bash

Ver arquivo completo: [`backup-ledger.sh`](./backup-ledger.sh)

**Resumo do fluxo:**

1. Valida `pg_dump`, `aws` e `PGPASSWORD`
2. `pg_dump` → `gzip` → `/var/backups/ledger/ledger_prod_YYYYMMDD_HHMMSS.sql.gz`
3. `aws s3 cp` → `s3://hvt-ledger-backups/`
4. Remove arquivo local após upload
5. Lista objetos S3 e remove os com `LastModified` > 30 dias
6. Log com timestamp em `/var/log/ledger-backup.log`
7. `exit 1` em falhas via `die()`; `exit 0` no sucesso

---

## Cron (exemplo — PT-BR)

```
# Backup diário do Ledger às 02:00 (horário do servidor)
0 2 * * * /usr/local/bin/backup-ledger.sh >> /var/log/ledger-backup.log 2>&1
```

```
# Alternativa: domingo às 03:00 com variáveis explícitas (se não vierem do profile da instância)
0 3 * * * AWS_DEFAULT_REGION=us-east-1 /usr/local/bin/backup-ledger.sh
```

```
# Instalar script: chmod +x /usr/local/bin/backup-ledger.sh && chown root:root backup-ledger.sh
```
