#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE_WALLPAPER="$ROOT_DIR/branding/wallpapers/reforge-wallpaper.png"
SYSTEM_WALLPAPER_DIR="/usr/share/backgrounds/reforge-linux"
SYSTEM_WALLPAPER="$SYSTEM_WALLPAPER_DIR/reforge-wallpaper.png"

if [[ "${EUID}" -ne 0 ]]; then
  echo "This installer needs administrator permission to copy branding into system locations."
  exec sudo bash "$SCRIPT_PATH" "$@"
fi

print_manual_instructions() {
  echo
  echo "Manual wallpaper setup:"
  echo "  1. Open XFCE Desktop Settings."
  echo "  2. Choose this wallpaper:"
  echo "     $SYSTEM_WALLPAPER"
  echo "  3. Apply it to the active display/workspace."
}

set_xfce_wallpaper_for_user() {
  local target_user="${SUDO_USER:-}"
  local display_value="${DISPLAY:-:0}"
  local properties=""

  if [[ -z "$target_user" || "$target_user" == "root" ]]; then
    echo "No normal desktop user detected; skipping automatic XFCE wallpaper setup."
    print_manual_instructions
    return 0
  fi

  if ! command -v xfconf-query >/dev/null 2>&1; then
    echo "xfconf-query not found; skipping automatic XFCE wallpaper setup."
    print_manual_instructions
    return 0
  fi

  echo
  echo "Attempting to set XFCE wallpaper for user: $target_user"

  properties="$(
    sudo -u "$target_user" env DISPLAY="$display_value" xfconf-query -c xfce4-desktop -l 2>/dev/null \
      | grep '/last-image$' || true
  )"

  if [[ -z "$properties" ]]; then
    echo "Could not detect XFCE wallpaper properties automatically."
    print_manual_instructions
    return 0
  fi

  while IFS= read -r property; do
    [[ -z "$property" ]] && continue
    sudo -u "$target_user" env DISPLAY="$display_value" xfconf-query \
      -c xfce4-desktop \
      -p "$property" \
      -s "$SYSTEM_WALLPAPER" >/dev/null 2>&1 || true
  done <<< "$properties"

  echo "XFCE wallpaper update attempted. If it did not change visually, use the manual steps below."
  print_manual_instructions
}

if [[ ! -f "$SOURCE_WALLPAPER" ]]; then
  echo "No wallpaper found yet. Add branding/wallpapers/reforge-wallpaper.png first."
  exit 0
fi

echo "Installing Reforge Linux wallpaper..."
install -d -m 0755 "$SYSTEM_WALLPAPER_DIR"
install -m 0644 "$SOURCE_WALLPAPER" "$SYSTEM_WALLPAPER"

echo "Installed wallpaper:"
echo "  $SYSTEM_WALLPAPER"

set_xfce_wallpaper_for_user

echo
echo "Reforge Linux branding install complete."
