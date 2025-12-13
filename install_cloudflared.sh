#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  exec sudo -p "[cloudflared] sudo password: " -- "$0" "$@"
fi

echo "Adding Cloudflare APT repository..."
install -d /etc/apt/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | \
  tee /etc/apt/keyrings/cloudflare-main.gpg >/dev/null

echo "deb [signed-by=/etc/apt/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" \
  | tee /etc/apt/sources.list.d/cloudflared.list >/dev/null

apt-get update
apt-get install -y cloudflared

echo "cloudflared installation complete. Configure a tunnel and service as needed."
