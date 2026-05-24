#!/usr/bin/env bash
#
# Daily PostgreSQL backup for Ledger (Hill Valley Tech)
# Dumps ledger_prod, compresses, uploads to S3, enforces retention.
#
set -euo pipefail

# --- Configuration ---
readonly PGHOST="${PGHOST:-ledger-db.internal.hvt.io}"
readonly PGPORT="${PGPORT:-5432}"
readonly PGDATABASE="${PGDATABASE:-ledger_prod}"
readonly PGUSER="${PGUSER:-backup_user}"
readonly AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
readonly S3_BUCKET="hvt-ledger-backups"
readonly BACKUP_DIR="/var/backups/ledger"
readonly LOG_FILE="/var/log/ledger-backup.log"
readonly RETENTION_DAYS=30

# --- Logging ---
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S %Z')] $*" | tee -a "$LOG_FILE"
}

die() {
  log "ERROR: $*"
  exit 1
}

# --- Preconditions ---
command -v pg_dump >/dev/null 2>&1 || die "pg_dump not found"
command -v aws >/dev/null 2>&1 || die "aws CLI not found"
[[ -n "${PGPASSWORD:-}" ]] || die "PGPASSWORD is not set"

mkdir -p "$BACKUP_DIR"

# --- Backup ---
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
BACKUP_NAME="ledger_prod_${TIMESTAMP}.sql.gz"
LOCAL_PATH="${BACKUP_DIR}/${BACKUP_NAME}"
S3_URI="s3://${S3_BUCKET}/${BACKUP_NAME}"

log "Starting backup of ${PGDATABASE}@${PGHOST}:${PGPORT}"

export PGHOST PGPORT PGDATABASE PGUSER

if ! pg_dump --no-owner --no-acl -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" \
  | gzip -c > "$LOCAL_PATH"; then
  die "pg_dump failed"
fi

LOCAL_SIZE="$(du -h "$LOCAL_PATH" | cut -f1)"
log "Dump completed: ${LOCAL_PATH} (${LOCAL_SIZE})"

# --- Upload to S3 ---
if ! aws s3 cp "$LOCAL_PATH" "$S3_URI" --region "$AWS_DEFAULT_REGION"; then
  die "S3 upload failed for ${S3_URI}"
fi

log "Uploaded to ${S3_URI}"

# --- Remove local file after successful upload ---
rm -f "$LOCAL_PATH"
log "Removed local file ${LOCAL_PATH}"

# --- S3 retention: delete objects older than RETENTION_DAYS ---
log "Applying S3 retention policy (${RETENTION_DAYS} days)"

CUTOFF_EPOCH="$(date -d "${RETENTION_DAYS} days ago" +%s)"

while IFS=$'\t' read -r key last_modified; do
  [[ -z "$key" || "$key" == "None" ]] && continue

  mod_epoch="$(date -d "$last_modified" +%s 2>/dev/null)" || continue

  if (( mod_epoch < CUTOFF_EPOCH )); then
    if aws s3 rm "s3://${S3_BUCKET}/${key}" --region "$AWS_DEFAULT_REGION"; then
      log "Deleted expired backup: s3://${S3_BUCKET}/${key} (LastModified: ${last_modified})"
    else
      die "Failed to delete expired object: ${key}"
    fi
  fi
done < <(
  aws s3api list-objects-v2 \
    --bucket "$S3_BUCKET" \
    --region "$AWS_DEFAULT_REGION" \
    --query 'Contents[].[Key,LastModified]' \
    --output text 2>/dev/null || true
)

log "Backup finished successfully"
exit 0
