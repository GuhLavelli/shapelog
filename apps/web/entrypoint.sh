#!/bin/bash
set -e

# Remove stale PID file para evitar erro ao reiniciar o servidor
rm -f /app/tmp/pids/server.pid

exec "$@"
