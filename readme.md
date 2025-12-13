# Ubuntu Server Setup Scripts

These scripts install a small set of common utilities on Ubuntu with minimal user interaction. Each script handles privilege escalation with `sudo`, performs repository setup, installs the package, and enables the relevant service where appropriate. The `install_all.sh` wrapper runs every installer in sequence if you want a one-shot setup.

## Prerequisites
- Ubuntu system with internet access (tested on modern LTS releases).
- A user with `sudo` privileges (scripts will prompt for your password if not already root).
- Ability to open outbound HTTPS connections so APT repositories and keys can be fetched.

## Quick start
1. Clone or download this repository to the target server.
2. Make the scripts executable (if needed):
   ```bash
   chmod +x install_*.sh
   ```
3. Run the installer you need. You do **not** need to preface with `sudo`—the scripts will re-exec with elevation:
   ```bash
   bash ./install_cockpit.sh
   ```
4. To install everything at once, use the wrapper **after confirming all installer scripts are present**:
   ```bash
   bash ./install_all.sh
   ```
   The wrapper expects all of the individual installer scripts (the `install_*.sh` files) to live in the **same directory** as
   `install_all.sh`. If you download files individually, place them in one folder so the wrapper can find each installer.
   Missing files will cause the wrapper to exit early with "file not found" errors.

### Using `install_all.sh` safely
If you want the "install everything" path, double-check the following before running the wrapper:
1. All installer scripts are present: `install_cloudflared.sh`, `install_cockpit.sh`, `install_webdav.sh`, and `install_rustdesk.sh`.
2. They live in the **same directory** as `install_all.sh` (the wrapper sources them by relative path).
3. They are executable: run `chmod +x install_*.sh` if in doubt.
4. You are running the wrapper from that directory: e.g., `cd ~/Ubuntu-Server-Setup && bash ./install_all.sh`.

If you move the scripts elsewhere, keep the set together; the wrapper does not search other directories or subfolders for
missing installers.

## What each script does
### `install_cloudflared.sh`
Installs Cloudflare's `cloudflared` tunnel client from the official APT repository.
- Adds Cloudflare's signing key to `/etc/apt/keyrings/cloudflare-main.gpg` and a new source list entry.
- Installs the `cloudflared` package via `apt-get`.
- Prints a reminder to create and configure a tunnel; no systemd service is configured by default.

### `install_cockpit.sh`
Installs the Cockpit web console for server management.
- Installs `cockpit` via APT and enables the `cockpit.socket` unit so the web UI listens on port **9090**.
- After completion, browse to `https://<server>:9090/` and log in with your system credentials.

### `install_webdav.sh`
Configures a basic Apache WebDAV server.
- Installs `apache2` and `apache2-utils`.
- Creates the document root at `/var/www/webdav` (owned by `www-data`).
- Writes `/etc/apache2/sites-available/webdav.conf` with a VirtualHost on port **80** and enables it alongside the `dav`, `dav_fs`, and `auth_basic` modules.
- Creates an HTTP basic auth user **`boeingfa18`** with password **`class701!`** stored at `/etc/apache2/webdav.passwd` and locks down permissions.
- Enables and reloads Apache so the site is active.

> ⚠️ **Security note:** Change the default WebDAV credentials before exposing the server publicly. Update `WEB_USER` and `WEB_PASS` in `install_webdav.sh`, or regenerate `/etc/apache2/webdav.passwd` with `htpasswd` after installation.

### `install_rustdesk.sh`
Installs the RustDesk remote desktop client/server components.
- Adds the RustDesk APT repository and signing key at `/usr/share/keyrings/rustdesk-archive-keyring.gpg`.
- Installs `rustdesk` via APT.
- Enables and starts the `rustdesk` systemd service.

### `install_all.sh`
Runs each of the individual installer scripts in the following order:
1. Cloudflared
2. Cockpit
3. WebDAV
4. RustDesk

Use this when you want every component installed in one pass.

## Verification
After running an installer, you can confirm the service status:
- Cloudflared: `cloudflared --version`
- Cockpit: `systemctl status cockpit.socket`
- WebDAV: `curl -u <user>:<pass> http://localhost/` and check Apache logs in `/var/log/apache2/`.
- RustDesk: `systemctl status rustdesk`

## Customization tips
- To change WebDAV credentials or document root, edit `WEB_USER`, `WEB_PASS`, and `WEB_ROOT` at the top of `install_webdav.sh` before running it.
- If you need to pin specific package versions, add the appropriate `apt-mark hold` commands to the relevant scripts after installation.
- For air-gapped environments, mirror the referenced APT repositories internally and update the source list paths accordingly.

## Troubleshooting
- If an installer fails due to APT repository reachability, verify DNS and HTTPS egress from the server.
- When rerunning scripts, they will re-add repositories and reinstall packages; this is normally safe but you can remove the corresponding `.list` files in `/etc/apt/sources.list.d/` first if needed.
- Logs for systemd-managed services are available via `journalctl -u <service>`.
