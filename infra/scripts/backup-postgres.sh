#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ROOT_DIR}/infra/production.env"
COMPOSE_FILE="${ROOT_DIR}/infra/docker-compose.prod.yml"
BACKUP_DIR="${ROOT_DIR}/infra/backups"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Arquivo ${ENV_FILE} nao encontrado." >&2
  exit 1
fi

set -a
source "${ENV_FILE}"
set +a

mkdir -p "${BACKUP_DIR}"

timestamp="$(date -u +"%Y%m%dT%H%M%SZ")"
backup_file="${BACKUP_DIR}/${POSTGRES_DB}_${timestamp}.sql.gz"

docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T db \
  pg_dump --clean --if-exists --no-owner --no-privileges -U "${POSTGRES_USER}" "${POSTGRES_DB}" | gzip > "${backup_file}"

echo "Backup criado em ${backup_file}"
