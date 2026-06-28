#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ "${EUID}" -ne 0 ]]; then
  echo "This profile needs administrator permission."
  exec sudo bash "$SCRIPT_PATH" "$@"
fi

source "$ROOT_DIR/scripts/common.sh"

SHARE_NAME="ReforgeShare"
SHARE_DIR="/srv/reforge/share"
SHARE_GROUP="reforge-share"
SMB_CONF="/etc/samba/smb.conf"
BACKUP_CONF="/etc/samba/smb.conf.reforge.bak"

TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "")}"

if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
  error_exit "Could not detect the normal user. Run this from your regular account using sudo."
fi

log "Starting Reforge File Server profile"

install_packages samba

log "Creating share group"
if ! getent group "$SHARE_GROUP" >/dev/null; then
  groupadd "$SHARE_GROUP"
fi

log "Adding user '$TARGET_USER' to share group"
usermod -aG "$SHARE_GROUP" "$TARGET_USER"

log "Creating shared folder at $SHARE_DIR"
mkdir -p "$SHARE_DIR"
chown -R "$TARGET_USER:$SHARE_GROUP" "$SHARE_DIR"
chmod -R 2775 "$SHARE_DIR"

log "Creating a welcome file"
cat > "$SHARE_DIR/README.txt" <<EOF
Welcome to Reforge Linux File Server.

This folder is shared on your local network using Samba.

Share name:
$SHARE_NAME

Local path:
$SHARE_DIR
EOF

log "Backing up Samba configuration"
if [[ ! -f "$BACKUP_CONF" ]]; then
  cp "$SMB_CONF" "$BACKUP_CONF"
fi

log "Updating Samba configuration"

# Remove old Reforge block if it exists
sed -i '/# BEGIN REFORGE FILE SERVER/,/# END REFORGE FILE SERVER/d' "$SMB_CONF"

cat >> "$SMB_CONF" <<EOF

# BEGIN REFORGE FILE SERVER
[$SHARE_NAME]
   path = $SHARE_DIR
   browseable = yes
   read only = no
   guest ok = no
   valid users = @$SHARE_GROUP
   force group = $SHARE_GROUP
   create mask = 0664
   directory mask = 2775
# END REFORGE FILE SERVER
EOF

log "Testing Samba configuration"
testparm -s

log "Enabling and restarting Samba services"
systemctl enable smbd >/dev/null 2>&1 || true
systemctl restart smbd

if systemctl list-unit-files | grep -q '^nmbd.service'; then
  systemctl enable nmbd >/dev/null 2>&1 || true
  systemctl restart nmbd || true
fi

if command -v ufw >/dev/null 2>&1; then
  if ufw status | grep -q "Status: active"; then
    log "Allowing Samba through UFW firewall"
    ufw allow Samba || true
  fi
fi

echo
echo "Samba user setup"
echo "----------------"
echo "You need to set a Samba password for user: $TARGET_USER"
echo "This can be the same as your Linux password, or a different one."
echo

smbpasswd -a "$TARGET_USER"

IP_ADDRESS="$(hostname -I | awk '{print $1}')"

echo
echo "======================================"
echo " Reforge File Server setup complete"
echo "======================================"
echo
echo "Shared folder:"
echo "  $SHARE_DIR"
echo
echo "Share name:"
echo "  $SHARE_NAME"
echo
echo "Access from Windows:"
echo "  \\\\$IP_ADDRESS\\$SHARE_NAME"
echo
echo "Access from Linux file manager:"
echo "  smb://$IP_ADDRESS/$SHARE_NAME"
echo
echo "User:"
echo "  $TARGET_USER"
echo
echo "Important:"
echo "  You may need to log out and log back in for group permissions to fully apply."
echo

pause