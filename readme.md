# Ubuntu Server Setup Scripts

Bash installers for common Ubuntu services. Each script auto-elevates, installs packages, and starts services. Run one installer or the all-in-one wrapper.

## Installers
- **Cloudflared** (tunnel client)
- **Cockpit** (web console on port 9090)
- **WebDAV (Apache)** (basic-auth WebDAV endpoint)
- **RustDesk** (remote desktop/relay)

## Quick start
```bash
chmod +x install_*.sh
bash ./install_cockpit.sh
# or
bash ./install_all.sh
```

> Keep all `install_*.sh` files in the same directory when using `install_all.sh`.

## Configuration
Set overrides as env vars (WebDAV example):
```bash
WEB_USER=myuser WEB_PASS='strong-password' bash ./install_webdav.sh
```
WebDAV variables: `WEB_USER`, `WEB_PASS`, `WEB_ROOT`, `HTPASSWD_FILE`, `SITE_CONF`.

## Script behavior (high level)
- **cloudflared:** adds Cloudflare repo + installs package; you create/run tunnels.
- **cockpit:** installs via APT, enables `cockpit.socket` (`https://<server>:9090/`).
- **webdav:** sets up Apache WebDAV site, doc root, and basic auth (defaults are `boeingfa18` / `class701!`).
- **rustdesk:** installs from repo or falls back to latest `.deb`, enables service.
- **install_all:** validates scripts, runs Cloudflared → Cockpit → WebDAV → RustDesk.

## Verify
- `cloudflared --version`
- `systemctl status cockpit.socket`
- `curl -u <user>:<pass> http://localhost/`
- `systemctl status rustdesk`

## Notes
- Change WebDAV credentials before exposing to the internet.
- Scripts add external repos; use on trusted systems.
- Logs: `journalctl -u <service>` or `/var/log/apache2/`.
