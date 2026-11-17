# SFTPGo for Railway: official image, pinned by version and digest.
FROM drakkan/sftpgo:v2.7.6@sha256:1edd28d80de2a008863fbfc58c8ff7db47b1b410bae48d4e6076192337809b11

# Everything stateful lives on the Railway volume mounted at /var/lib/sftpgo:
# the SQLite database, user home directories, backups and the SSH host keys.
ENV SFTPGO_DATA_PROVIDER__DRIVER=sqlite \
    SFTPGO_DATA_PROVIDER__NAME=/var/lib/sftpgo/sftpgo.db \
    SFTPGO_DATA_PROVIDER__USERS_BASE_DIR=/var/lib/sftpgo/data \
    SFTPGO_DATA_PROVIDER__BACKUPS_PATH=/var/lib/sftpgo/backups \
    SFTPGO_DATA_PROVIDER__CREATE_DEFAULT_ADMIN=true \
    SFTPGO_SFTPD__BINDINGS__0__PORT=2022 \
    SFTPGO_SFTPD__HOST_KEYS=/var/lib/sftpgo/hostkeys/id_rsa,/var/lib/sftpgo/hostkeys/id_ecdsa,/var/lib/sftpgo/hostkeys/id_ed25519 \
    SFTPGO_HTTPD__BINDINGS__0__PROXY_ALLOWED=10.0.0.0/8,100.64.0.0/10,172.16.0.0/12,192.168.0.0/16,fc00::/7 \
    SFTPGO_HTTPD__BINDINGS__0__CLIENT_IP_PROXY_HEADER=X-Forwarded-For

# The start script runs as root only to fix the volume's ownership,
# then drops to the image's unprivileged sftpgo user (uid 1000).
USER root
COPY --chmod=755 railway-start.sh /usr/local/bin/railway-start.sh

EXPOSE 8080 2022
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
