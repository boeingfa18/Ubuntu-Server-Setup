#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  exec sudo -p "[rustdesk] sudo password: " -- "$0" "$@"
fi

install -d /usr/share/keyrings
curl -fsSL https://static.rustdesk.com/key.pub | gpg --dearmor | \
  tee /usr/share/keyrings/rustdesk-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/rustdesk-archive-keyring.gpg] https://static.rustdesk.com/apt $(lsb_release -cs) main" \
  | tee /etc/apt/sources.list.d/rustdesk.list >/dev/null

apt-get update
apt-get install -y rustdesk

systemctl enable --now rustdesk

echo "RustDesk installed and service started."
