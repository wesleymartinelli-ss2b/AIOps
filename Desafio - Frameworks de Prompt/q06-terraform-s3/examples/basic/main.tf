# Exemplo basico de uso do modulo hvt-s3-bucket
# Ambiente: dev | Execute: terraform init && terraform plan

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "ledger_backups_bucket" {
  source = "../../modules/s3-bucket"

  environment           = "dev"
  owner                 = "sre-team"
  cost_center           = "platform-ops"
  bucket_suffix         = "ledger-backups"
  logging_target_bucket = "hvt-access-logs-dev"
  logging_prefix        = "ledger-backups/"
}

output "bucket_id" {
  description = "ID do bucket de exemplo"
  value       = module.ledger_backups_bucket.bucket_id
}

output "bucket_arn" {
  description = "ARN do bucket de exemplo"
  value       = module.ledger_backups_bucket.bucket_arn
}
