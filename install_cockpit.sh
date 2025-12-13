#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  exec sudo -p "[cockpit] sudo password: " -- "$0" "$@"
fi

apt-get update
apt-get install -y cockpit

systemctl enable --now cockpit.socket

echo "Cockpit installed. Access the web console on port 9090."
