# Ubuntu Server Setup Scripts

These Bash scripts install and configure a few helpful services on Ubuntu with minimal interaction. Each installer elevates privileges automatically, fetches the right repositories, installs packages, and starts services. Run a single script for one tool or use the wrapper to install everything at once.

## Supported installers
- **Cloudflared** – Cloudflare tunnel client.
- **Cockpit** – Web console on port 9090.
- **WebDAV (Apache)** – Simple WebDAV endpoint with basic auth.
- **RustDesk** – Remote desktop/relay service.

## Quick start
1. Clone or download this repository on the target Ubuntu machine.
2. Ensure the scripts are executable:
   ```bash
   chmod +x install_*.sh
   ```
3. Run the installer you need (no need to preface with `sudo`):
   ```bash
   bash ./install_cockpit.sh
   ```
4. To install everything together, run:
   ```bash
   bash ./install_all.sh
   ```

> **Tip:** The wrapper expects all `install_*.sh` scripts to be in the same directory. If you copy files individually, place them together before running `install_all.sh`.

## Configuration knobs
You can override defaults by setting environment variables before running the scripts, for example:

```bash
WEB_USER=myuser WEB_PASS='strong-password' bash ./install_webdav.sh
```

Available variables:
- `WEB_USER`, `WEB_PASS`, `WEB_ROOT`, `HTPASSWD_FILE`, `SITE_CONF` in `install_webdav.sh`.

## What each script does
### `install_cloudflared.sh`
- Installs prerequisites, adds the official Cloudflare APT repository, and installs `cloudflared`.
- Leaves service configuration to you; create and run a tunnel after installation.

### `install_cockpit.sh`
- Installs `cockpit` via APT.
- Enables and starts `cockpit.socket` so you can browse to `https://<server>:9090/` with system credentials.

### `install_webdav.sh`
- Installs Apache with WebDAV modules and writes a dedicated site at `/etc/apache2/sites-available/webdav.conf`.
- Creates the document root (default `/var/www/webdav`) owned by `www-data`.
- Generates HTTP basic auth credentials (defaults are `boeingfa18` / `class701!`—change these!).
- Enables Apache, required modules, and the WebDAV site.

### `install_rustdesk.sh`
- Installs prerequisites, adds the RustDesk APT repository, and installs `rustdesk`.
- Falls back to downloading the latest `.deb` if the repository install fails.
- Enables and starts the `rustdesk` service.

### `install_all.sh`
- Checks that all installer scripts exist and are executable.
- Runs installers in order: Cloudflared → Cockpit → WebDAV → RustDesk.

## Verification
After running an installer, confirm status with:
- Cloudflared: `cloudflared --version`
- Cockpit: `systemctl status cockpit.socket`
- WebDAV: `curl -u <user>:<pass> http://localhost/`
- RustDesk: `systemctl status rustdesk`

## Security notes
- **Change the WebDAV credentials** before exposing the service to the internet. Set `WEB_USER` and `WEB_PASS` or rerun `htpasswd` manually.
- Run these scripts only on systems you trust; they add external repositories and packages.

## Troubleshooting
- Repository errors: verify DNS/HTTPS egress and rerun the script.
- Re-running scripts is safe; they recreate config and re-enable services if needed.
- View service logs with `journalctl -u <service>` or Apache logs in `/var/log/apache2/`.
