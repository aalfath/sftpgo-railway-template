#!/bin/sh
# Start SFTPGo on Railway: web admin, web client and REST API on $PORT,
# SFTP on 2022 (Railway TCP proxy), all state on the volume at /var/lib/sftpgo.
set -eu

DATA=/var/lib/sftpgo

if [ -z "${SFTPGO_DEFAULT_ADMIN_PASSWORD:-}" ]; then
  echo "SFTPGO_DEFAULT_ADMIN_PASSWORD is empty. Set it (the template generates one) so the admin account is never left open." >&2
  exit 1
fi
export SFTPGO_DEFAULT_ADMIN_USERNAME="${SFTPGO_DEFAULT_ADMIN_USERNAME:-admin}"
export SFTPGO_HTTPD__BINDINGS__0__PORT="${PORT:-8080}"

mkdir -p "$DATA/data" "$DATA/backups" "$DATA/hostkeys"

if [ "$(id -u)" = "0" ]; then
  # A fresh Railway volume is owned by root; hand it to the sftpgo user once.
  if [ "$(stat -c %u "$DATA")" != "1000" ]; then
    chown -R 1000:1000 "$DATA"
  fi
  chown 1000:1000 "$DATA/data" "$DATA/backups" "$DATA/hostkeys"
  chmod 700 "$DATA/backups" "$DATA/hostkeys"
  exec setpriv --reuid=1000 --regid=1000 --init-groups -- sftpgo serve "$@"
fi

exec sftpgo serve "$@"
