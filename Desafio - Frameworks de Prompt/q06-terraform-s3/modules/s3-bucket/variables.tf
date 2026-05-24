variable "environment" {
  description = "Nome do ambiente (dev, staging, production)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment deve ser dev, staging ou production."
  }
}

variable "owner" {
  description = "Time ou pessoa responsavel pelo recurso (tag Owner)"
  type        = string
}

variable "cost_center" {
  description = "Centro de custo para billing (tag CostCenter)"
  type        = string
}

variable "bucket_suffix" {
  description = "Sufixo do bucket apos o prefixo hvt- (ex.: ledger-backups, app-assets)"
  type        = string
}

variable "logging_target_bucket" {
  description = "Nome do bucket S3 de destino para access logs (deve existir previamente)"
  type        = string
}

variable "logging_prefix" {
  description = "Prefixo opcional para objetos de access log neste bucket"
  type        = string
  default     = "access-logs/"
}
