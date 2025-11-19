#!/usr/bin/env bash
set -euo pipefail

# Generar llaves del host si no existen (requerido en imágenes mínimas)
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  ssh-keygen -A
fi

echo ">> Iniciando sshd con parámetros mínimos"
/usr/sbin/sshd -D -e

