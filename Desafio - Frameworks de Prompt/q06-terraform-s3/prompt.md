# Prompt — Q06 Módulo Terraform S3

> **Status:** concluído  
> **Framework:** CARE

---

## [CONTEXT]

A Hill Valley Tech exige que todo módulo Terraform novo siga o **padrão interno de IaC** (Strickland / compliance):

1. **Tags obrigatórias** em todo recurso: `Owner`, `CostCenter`, `Environment`
2. **Prefixo `hvt-`** nos nomes de recursos
3. **Todo bucket S3** com:
   - Encryption habilitada (SSE-S3 mínimo)
   - Versioning ativo
   - Block public access total
   - Logging configurado
4. **Variáveis** em `variables.tf` com `description` e `type` obrigatórios

Doc Brown pediu um **módulo reutilizável** para buckets S3, consumido por todos os times.

**Referência de estilo** (módulo VPC existente):

```hcl
variable "environment" {
  description = "Nome do ambiente (dev, staging, production)"
  type        = string
}

locals {
  common_tags = {
    Owner       = var.owner
    CostCenter  = var.cost_center
    Environment = var.environment
  }
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = merge(local.common_tags, {
    Name = "hvt-vpc-${var.environment}"
  })
}
```

## [ACTION]

Crie o módulo Terraform em `modules/s3-bucket/` com:

- `main.tf` — bucket + versioning + encryption + public access block + logging
- `variables.tf` — todas com description e type
- `outputs.tf` — `bucket_id`, `bucket_arn`, `bucket_domain_name`
- `versions.tf` — provider AWS `>= 5.0`

Variáveis mínimas esperadas: `environment`, `owner`, `cost_center`, `bucket_suffix`, `logging_target_bucket` (bucket de destino dos access logs).

## [RESULT]

Módulo aderente ao padrão HVT, pronto para `terraform init/plan/apply`, reutilizável por qualquer time, sem valores secretos hardcoded.

## [EXAMPLE]

Inclua `examples/basic/main.tf` que:

- Chama o módulo com valores de exemplo (`dev`, owner, cost_center, suffix)
- Referencia o módulo via path relativo `../../modules/s3-bucket`
- Segue o mesmo estilo declarativo do VPC

## [FORMAT]

- Arquivos HCL separados por path (indique cada arquivo claramente).
- Comentários nos `.tf` em **en_US**.
- Instruções breves em PT-BR no topo de `examples/basic/main.tf` (comentário).
