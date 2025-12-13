#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  exec sudo -p "[install_all] sudo password: " -- "$0" "$@"
fi

SCRIPT_DIR=$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)

bash "${SCRIPT_DIR}/install_cloudflared.sh"
bash "${SCRIPT_DIR}/install_cockpit.sh"
bash "${SCRIPT_DIR}/install_webdav.sh"
bash "${SCRIPT_DIR}/install_rustdesk.sh"

echo "All requested applications have been installed."
