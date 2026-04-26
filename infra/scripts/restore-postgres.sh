#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Uso: $0 infra/backups/arquivo.sql.gz" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ROOT_DIR}/infra/production.env"
COMPOSE_FILE="${ROOT_DIR}/infra/docker-compose.prod.yml"
BACKUP_FILE="$1"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Arquivo ${ENV_FILE} nao encontrado." >&2
  exit 1
fi

if [[ ! -f "${BACKUP_FILE}" ]]; then
  echo "Backup ${BACKUP_FILE} nao encontrado." >&2
  exit 1
fi

set -a
source "${ENV_FILE}"
set +a

echo "Restaurando ${BACKUP_FILE} no banco ${POSTGRES_DB}."
echo "Isto sobrescreve dados existentes se o dump contiver comandos conflitantes."

gunzip -c "${BACKUP_FILE}" | docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T db \
  psql -U "${POSTGRES_USER}" "${POSTGRES_DB}"
