#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SETUP_SCRIPT="$ROOT_DIR/scripts/reforge-setup.sh"

APP_DIR="$HOME/.local/share/applications"
APP_LAUNCHER="$APP_DIR/reforge-setup.desktop"
DESKTOP_DIR="$HOME/Desktop"
DESKTOP_LAUNCHER="$DESKTOP_DIR/reforge-setup.desktop"

shell_quote() {
  printf "'%s'" "$(printf "%s" "$1" | sed "s/'/'\\\\''/g")"
}

write_launcher() {
  local target="$1"
  local command

  command="cd $(shell_quote "$ROOT_DIR") && exec bash scripts/reforge-setup.sh"

  cat > "$target" <<EOF
[Desktop Entry]
Type=Application
Name=Reforge Setup Center
Comment=Launch Reforge Linux Setup Center
Exec=bash -lc "$command"
Icon=utilities-terminal
Terminal=true
Categories=System;Utility;
StartupNotify=false
EOF

  chmod +x "$target"
}

if [[ ! -f "$SETUP_SCRIPT" ]]; then
  echo "ERROR: Reforge Setup Center not found at: $SETUP_SCRIPT"
  exit 1
fi

mkdir -p "$APP_DIR"
write_launcher "$APP_LAUNCHER"
echo "Installed application launcher:"
echo "  $APP_LAUNCHER"

if [[ -d "$DESKTOP_DIR" ]]; then
  write_launcher "$DESKTOP_LAUNCHER"
  echo "Installed desktop launcher:"
  echo "  $DESKTOP_LAUNCHER"
else
  echo "Desktop folder not found, skipping desktop launcher:"
  echo "  $DESKTOP_DIR"
fi

echo
echo "Reforge Setup Center launcher installed."
