[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/sftpgo-2?utm_medium=integration&utm_source=button&utm_campaign=sftpgo)

# SFTPGo on Railway

A Railway template for [SFTPGo](https://github.com/drakkan/sftpgo) **2.7.6**, an SFTP, HTTP/S, FTP/S and WebDAV server with a web admin panel, a web client for users, a REST API and per-user storage on the local disk, S3, Google Cloud Storage, Azure Blob or another SFTP server.

## What the template deploys

One service, built from this repo:

- `Dockerfile`: the official `drakkan/sftpgo:v2.7.6` image, pinned by digest, plus the settings below.
- `railway-start.sh`: refuses to start without an admin password, makes the Railway volume writable for the image's `sftpgo` user (uid 1000), then runs `sftpgo serve` as that user.
- A volume at `/var/lib/sftpgo` holds everything that must survive a redeploy:

| Path on the volume | What |
|---|---|
| `sftpgo.db` | SQLite database: admins, users, folders, groups, shares, events |
| `data/` | User home directories (local storage) |
| `backups/` | Backups made from the admin panel or the event manager |
| `hostkeys/` | SSH host keys, so SFTP clients don't see a changed key after a redeploy |

| Port | What | How to reach it |
|---|---|---|
| `$PORT` (8080) | Web admin (`/web/admin`), web client (`/web/client`), REST API (`/api/v2`), health check (`/healthz`) | The service's Railway domain (HTTPS) |
| 2022 | SFTP (and SCP) | The service's TCP proxy, shown in its Networking settings (`RAILWAY_TCP_PROXY_DOMAIN`:`RAILWAY_TCP_PROXY_PORT`) |

FTP/S and WebDAV are off: FTP needs a range of passive ports, and Railway gives a service one TCP proxy port and one HTTP domain.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `PORT` | `8080` | Port of the web panel, the REST API and the health check |
| `SFTPGO_DEFAULT_ADMIN_USERNAME` | `admin` | Username of the first admin, created on the first start |
| `SFTPGO_DEFAULT_ADMIN_PASSWORD` | generated secret | Password of the first admin. The container refuses to start without it |
| `SFTPGO_HTTPD__SIGNING_PASSPHRASE` | generated secret | Key that signs login sessions, so a redeploy doesn't log everyone out |

The first admin is created only when the database has no admin yet. Changing `SFTPGO_DEFAULT_ADMIN_PASSWORD` later doesn't change the password: change it in the web admin instead.

Any other [SFTPGo setting](https://docs.sftpgo.com/2.7/config-file/) can be added as an `SFTPGO_<SECTION>__<KEY>` variable, for example `SFTPGO_SMTP__HOST` for email or `SFTPGO_HTTPD__BINDINGS__0__OIDC__CONFIG_URL` for single sign-on.

## Using it

1. Open the service's domain at `/web/admin` and sign in as `admin` with the password from the service's Variables tab (`SFTPGO_DEFAULT_ADMIN_PASSWORD`). Set up two-factor authentication for the admin if you like.
2. Create a user under **Users**. Leave its storage as "Local disk" to keep files on the volume, or pick S3, Google Cloud Storage, Azure Blob or SFTP.
3. Connect with any SFTP client: `sftp -P YOUR-TCP-PROXY-PORT USERNAME@YOUR-TCP-PROXY-DOMAIN`. Users can also sign in to the web client at the domain's root.

## Updates

Updates are merged to `main` here. Railway shows deployers of this template an "update available" notice, and they choose when to apply it. Each version is listed in [CHANGELOG.md](CHANGELOG.md), breaking changes first. Back up the volume (or use **Maintenance → Backup** in the web admin) before applying a new minor version of SFTPGo.
