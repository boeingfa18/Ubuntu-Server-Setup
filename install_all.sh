#!/usr/bin/env bash
set -euo pipefail

log() {
  printf "[install_all] %s\n" "$*"
}

if [[ "${EUID}" -ne 0 ]]; then
  exec sudo -p "[install_all] sudo password: " -- "$0" "$@"
fi

SCRIPT_DIR=$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)
INSTALLERS=(
  install_cloudflared.sh
  install_cockpit.sh
  install_webdav.sh
  install_rustdesk.sh
)

for installer in "${INSTALLERS[@]}"; do
  installer_path="${SCRIPT_DIR}/${installer}"
  if [[ ! -x "${installer_path}" ]]; then
    log "Missing or non-executable installer: ${installer_path}" >&2
    exit 1
  fi
done

for installer in "${INSTALLERS[@]}"; do
  log "Running ${installer}..."
  bash "${SCRIPT_DIR}/${installer}"
done

log "All requested applications have been installed."
