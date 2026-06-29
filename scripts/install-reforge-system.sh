#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

INSTALL_DIR="/opt/reforge-linux"
BIN_PATH="/usr/local/bin/reforge-setup"
SYSTEM_DESKTOP="/usr/share/applications/reforge-setup.desktop"

SETUP_SCRIPT="$ROOT_DIR/scripts/reforge-setup.sh"
INSTALLED_SETUP_SCRIPT="$INSTALL_DIR/scripts/reforge-setup.sh"

if [[ "${EUID}" -ne 0 ]]; then
  echo "This installer needs administrator permission."
  exec sudo bash "$SCRIPT_PATH" "$@"
fi

if [[ ! -f "$SETUP_SCRIPT" ]]; then
  echo "ERROR: Reforge Setup Center not found at: $SETUP_SCRIPT"
  exit 1
fi

copy_dir_if_present() {
  local name="$1"
  local src="$ROOT_DIR/$name"
  local dest="$INSTALL_DIR/$name"

  if [[ ! -d "$src" ]]; then
    return 0
  fi

  mkdir -p "$dest"
  (
    cd "$src"
    tar \
      --exclude='.git' \
      --exclude='__pycache__' \
      --exclude='.pytest_cache' \
      --exclude='.mypy_cache' \
      --exclude='.ruff_cache' \
      --exclude='node_modules' \
      --exclude='*.tmp' \
      --exclude='*~' \
      -cf - .
  ) | (
    cd "$dest"
    tar -xf -
  )
}

install_file_if_present() {
  local name="$1"
  local src="$ROOT_DIR/$name"

  if [[ -f "$src" ]]; then
    install -m 0644 "$src" "$INSTALL_DIR/$name"
  fi
}

write_command_wrapper() {
  cat > "$BIN_PATH" <<'EOF'
#!/usr/bin/env bash

set -Eeuo pipefail

SETUP_SCRIPT="/opt/reforge-linux/scripts/reforge-setup.sh"

if [[ ! -f "$SETUP_SCRIPT" ]]; then
  echo "ERROR: Reforge Setup Center not found at: $SETUP_SCRIPT"
  exit 1
fi

exec bash "$SETUP_SCRIPT" "$@"
EOF

  chmod 0755 "$BIN_PATH"
}

write_desktop_entry() {
  local target="$1"

  cat > "$target" <<'EOF'
[Desktop Entry]
Type=Application
Name=Reforge Setup Center
Comment=Turn old PCs into useful machines
Exec=xfce4-terminal -e "bash -lc 'reforge-setup'"
Icon=utilities-terminal
Terminal=false
Categories=System;Utility;
StartupNotify=false
EOF

  chmod 0755 "$target"
}

install_user_desktop_shortcut() {
  local target_user="${SUDO_USER:-}"
  local user_home=""
  local desktop_dir=""

  if [[ -z "$target_user" || "$target_user" == "root" ]]; then
    return 0
  fi

  user_home="$(getent passwd "$target_user" | cut -d: -f6)"
  if [[ -z "$user_home" ]]; then
    return 0
  fi

  desktop_dir="$user_home/Desktop"
  if [[ ! -d "$desktop_dir" ]]; then
    return 0
  fi

  write_desktop_entry "$desktop_dir/reforge-setup.desktop"
  chown "$target_user:" "$desktop_dir/reforge-setup.desktop" 2>/dev/null || true
}

echo "Installing Reforge Linux system files..."

mkdir -p "$INSTALL_DIR"
copy_dir_if_present "scripts"
copy_dir_if_present "profiles"
copy_dir_if_present "docs"
copy_dir_if_present "branding"
install_file_if_present "README.md"
install_file_if_present "LICENSE"

find "$INSTALL_DIR/scripts" -type f -name "*.sh" -exec chmod 0755 {} \;

write_command_wrapper
write_desktop_entry "$SYSTEM_DESKTOP"
install_user_desktop_shortcut

if [[ ! -f "$INSTALLED_SETUP_SCRIPT" ]]; then
  echo "ERROR: Installed setup script missing at: $INSTALLED_SETUP_SCRIPT"
  exit 1
fi

echo
echo "Reforge Linux system install complete."
echo
echo "Installed files:"
echo "  $INSTALL_DIR"
echo
echo "Command:"
echo "  reforge-setup"
echo
echo "Application launcher:"
echo "  $SYSTEM_DESKTOP"
echo
echo "Note:"
echo "  The desktop launcher uses xfce4-terminal, which is expected on MX Linux XFCE."
