#!/usr/bin/env bash
set -euo pipefail

log() {
  printf "[cloudflared] %s\n" "$*"
}

if [[ "${EUID}" -ne 0 ]]; then
  exec sudo -p "[cloudflared] sudo password: " -- "$0" "$@"
fi

log "Adding Cloudflare APT repository..."
apt-get update -y
apt-get install -y curl gnupg lsb-release ca-certificates

install -d /etc/apt/keyrings
curl -fsSL --retry 3 --retry-delay 2 https://pkg.cloudflare.com/cloudflare-main.gpg \
  | tee /etc/apt/keyrings/cloudflare-main.gpg >/dev/null

echo "deb [signed-by=/etc/apt/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" \
  | tee /etc/apt/sources.list.d/cloudflared.list >/dev/null

apt-get update -y
apt-get install -y cloudflared

log "cloudflared installation complete. Configure a tunnel and service as needed."
