#!/usr/bin/env bash
set -euo pipefail

log() {
  printf "[cockpit] %s\n" "$*"
}

if [[ "${EUID}" -ne 0 ]]; then
  exec sudo -p "[cockpit] sudo password: " -- "$0" "$@"
fi

apt-get update -y
apt-get install -y cockpit

systemctl enable --now cockpit.socket

log "Cockpit installed. Access the web console on port 9090."
