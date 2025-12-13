#!/usr/bin/env bash
set -euo pipefail

WEB_USER="boeingfa18"
WEB_PASS="class701!"
WEB_ROOT="/var/www/webdav"
HTPASSWD_FILE="/etc/apache2/webdav.passwd"
SITE_CONF="/etc/apache2/sites-available/webdav.conf"

if [[ "${EUID}" -ne 0 ]]; then
  exec sudo -p "[webdav] sudo password: " -- "$0" "$@"
fi

apt-get update
apt-get install -y apache2 apache2-utils

install -d -m 755 "${WEB_ROOT}"
chown -R www-data:www-data "${WEB_ROOT}"

cat > "${SITE_CONF}" <<SITE
<VirtualHost *:80>
  ServerName webdav.local
  DocumentRoot ${WEB_ROOT}

  <Directory ${WEB_ROOT}>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require valid-user
    AuthType Basic
    AuthName "Restricted WebDAV"
    AuthUserFile ${HTPASSWD_FILE}
    Dav On
  </Directory>

  ErrorLog \${APACHE_LOG_DIR}/webdav_error.log
  CustomLog \${APACHE_LOG_DIR}/webdav_access.log combined
</VirtualHost>
SITE

a2enmod dav dav_fs auth_basic

a2ensite webdav.conf

htpasswd -b -c "${HTPASSWD_FILE}" "${WEB_USER}" "${WEB_PASS}"
chown root:www-data "${HTPASSWD_FILE}"
chmod 640 "${HTPASSWD_FILE}"

systemctl enable --now apache2
systemctl reload apache2

echo "WebDAV configured at http://<server_ip>/ with user '${WEB_USER}'."
