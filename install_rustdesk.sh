#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  exec sudo -p "[rustdesk] sudo password: " -- "$0" "$@"
fi

install_repo_rustdesk() {
  echo "Adding RustDesk APT repository..."
  install -d /usr/share/keyrings

  curl -fsSL --retry 3 --retry-delay 2 https://static.rustdesk.com/key.pub |
    gpg --dearmor |
    tee /usr/share/keyrings/rustdesk-archive-keyring.gpg >/dev/null || return 1

  echo "deb [signed-by=/usr/share/keyrings/rustdesk-archive-keyring.gpg] https://static.rustdesk.com/apt $(lsb_release -cs) main" |
    tee /etc/apt/sources.list.d/rustdesk.list >/dev/null || return 1

  apt-get update || return 1
  apt-get install -y rustdesk || return 1
}

install_fallback_rustdesk() {
  local arch package_url package_tmp
  arch=$(dpkg --print-architecture)
  package_url="https://github.com/rustdesk/rustdesk/releases/latest/download/rustdesk-${arch}.deb"
  package_tmp=$(mktemp --suffix=.rustdesk.deb)

  echo "Downloading RustDesk package directly (fallback)..."
  curl -fL --retry 3 --retry-delay 2 -o "${package_tmp}" "${package_url}"

  dpkg -i "${package_tmp}" || true
  apt-get install -fy
  rm -f "${package_tmp}"
}

if install_repo_rustdesk; then
  echo "RustDesk installed from repository."
else
  echo "Repository installation failed; attempting fallback download." >&2
  install_fallback_rustdesk
fi

systemctl enable --now rustdesk

echo "RustDesk installed and service started."
