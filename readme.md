# Ubuntu Server Setup Scripts

This repository provides standalone installation scripts for common services and a convenience wrapper to run them all at once. Run each script on Ubuntu to install and configure the corresponding service. Each script self-elevates with `sudo` when needed and will prompt for your password if you are not already root.

## Available installers
- `install_cloudflared.sh` – Installs Cloudflare's `cloudflared` tunnel client from the official APT repository.
- `install_cockpit.sh` – Installs the Cockpit Project web console and enables the systemd socket on port 9090.
- `install_webdav.sh` – Configures an Apache-based WebDAV server at `/var/www/webdav` with the single user `boeingfa18` (password: `class701!`).
- `install_rustdesk.sh` – Installs RustDesk from the upstream APT repository and starts its service.
- `install_all.sh` – Runs all individual installer scripts in sequence.

## Usage
1. Make the scripts executable (if needed):
   ```bash
   chmod +x install_*.sh
   ```
2. Run the desired installer (no need to preface with `sudo`; a prompt will appear if elevation is required). For example, to run everything:
   ```bash
   bash ./install_all.sh
   ```

Each installer performs the necessary package setup and service enablement; consult the scripts for details.
