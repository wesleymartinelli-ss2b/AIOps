# Output — Q06

> **Status:** concluído

Resposta do Composer 2.5 ao prompt CARE. Módulo Terraform gerado nos paths abaixo.

---

## Estrutura gerada

```
modules/s3-bucket/
├── main.tf
├── variables.tf
├── outputs.tf
└── versions.tf

examples/basic/
└── main.tf
```

---

## Conformidade com padrão HVT

| Requisito | Implementação |
|-----------|---------------|
| Tags Owner, CostCenter, Environment | `locals.common_tags` + `merge()` em `aws_s3_bucket` |
| Prefixo `hvt-` | `bucket_name = "hvt-${var.bucket_suffix}-${var.environment}"` |
| Encryption SSE-S3 | `aws_s3_bucket_server_side_encryption_configuration` (AES256) |
| Versioning | `aws_s3_bucket_versioning` status Enabled |
| Block public access | `aws_s3_bucket_public_access_block` (4 flags true) |
| Logging | `aws_s3_bucket_logging` → `logging_target_bucket` |
| variables description + type | Todas em `variables.tf` |
| Estilo VPC | `locals`, `merge(tags)`, naming `hvt-*` |

---

## Outputs do módulo

- `bucket_id`
- `bucket_arn`
- `bucket_domain_name`

---

## Assumptions

- Bucket de access logs (`logging_target_bucket`) **já existe** — padrão comum em contas AWS corporativas (ex.: `hvt-access-logs-dev`).
- Provider AWS >= 5.x; recursos S3 split (bucket + sub-resources) conforme provider moderno.
