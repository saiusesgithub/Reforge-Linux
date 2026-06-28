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

MEDIA_ROOT="/srv/reforge/media"
MEDIA_GROUP="reforge-media"
JELLYFIN_KEYRING="/etc/apt/keyrings/jellyfin.gpg"
JELLYFIN_SOURCE="/etc/apt/sources.list.d/jellyfin.sources"
JELLYFIN_KEY_URL="https://repo.jellyfin.org/jellyfin_team.gpg.key"

TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "")}"

confirm() {
  local prompt="$1"
  local answer

  read -rp "$prompt" answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

local_ip() {
  hostname -I 2>/dev/null | awk '{print $1}'
}

jellyfin_installed() {
  command -v jellyfin >/dev/null 2>&1 || systemctl list-unit-files --type=service 2>/dev/null | grep -q '^jellyfin\.service'
}

print_access_url() {
  local ip_address
  ip_address="$(local_ip)"

  echo
  echo "Jellyfin URL:"
  echo "  http://$ip_address:8096"
}

show_existing_install_menu() {
  echo
  echo "Jellyfin appears to be installed already."
  echo
  echo "1) Show Jellyfin service status"
  echo "2) Restart Jellyfin service"
  echo "3) Print access URL"
  echo "4) Exit back to setup center"
  echo
  read -rp "Select an option: " existing_choice

  case "$existing_choice" in
    1)
      systemctl status jellyfin --no-pager || warn "Could not show Jellyfin service status."
      ;;
    2)
      systemctl restart jellyfin || warn "Could not restart Jellyfin service."
      ;;
    3)
      print_access_url
      ;;
    4)
      return 0
      ;;
    *)
      warn "Invalid option."
      ;;
  esac

  pause
}

print_preinstall_warning() {
  echo
  echo "Reforge Media Server"
  echo "--------------------"
  echo "This profile will install Jellyfin, a home media server."
  echo "Jellyfin lets you stream movies, shows, music, and videos from this old PC to other devices."
  echo
  echo "Important:"
  echo "  - Reforge Linux will create media folders under $MEDIA_ROOT."
  echo "  - Jellyfin usually runs on port 8096."
  echo "  - Place media files inside the created folders after installation."
  echo
}

setup_media_folders() {
  log "Creating media folders"

  if ! getent group "$MEDIA_GROUP" >/dev/null; then
    groupadd "$MEDIA_GROUP"
  fi

  if [[ -n "$TARGET_USER" && "$TARGET_USER" != "root" ]]; then
    usermod -aG "$MEDIA_GROUP" "$TARGET_USER"
  else
    warn "Could not detect a normal sudo user to add to the media group."
  fi

  mkdir -p "$MEDIA_ROOT" \
    "$MEDIA_ROOT/movies" \
    "$MEDIA_ROOT/shows" \
    "$MEDIA_ROOT/music" \
    "$MEDIA_ROOT/videos"

  chown root:"$MEDIA_GROUP" "$MEDIA_ROOT" \
    "$MEDIA_ROOT/movies" \
    "$MEDIA_ROOT/shows" \
    "$MEDIA_ROOT/music" \
    "$MEDIA_ROOT/videos"
  chmod 2775 "$MEDIA_ROOT" \
    "$MEDIA_ROOT/movies" \
    "$MEDIA_ROOT/shows" \
    "$MEDIA_ROOT/music" \
    "$MEDIA_ROOT/videos"

  if [[ ! -e "$MEDIA_ROOT/README.txt" ]]; then
    cat > "$MEDIA_ROOT/README.txt" <<EOF
Reforge Linux Media Server

Place your media files in these folders:

- Movies: $MEDIA_ROOT/movies
- Shows:  $MEDIA_ROOT/shows
- Music:  $MEDIA_ROOT/music
- Videos: $MEDIA_ROOT/videos

After installing Jellyfin, open the web setup wizard and add these folders as libraries.
EOF
    chown root:"$MEDIA_GROUP" "$MEDIA_ROOT/README.txt"
    chmod 0664 "$MEDIA_ROOT/README.txt"
  fi
}

detect_jellyfin_repo() {
  if [[ ! -r /etc/os-release ]]; then
    error_exit "Could not read /etc/os-release. Cannot safely configure the Jellyfin repository."
  fi

  # shellcheck disable=SC1091
  source /etc/os-release

  local distro_id="${ID:-}"
  local codename="${VERSION_CODENAME:-}"
  local repo_family=""

  case "$distro_id" in
    debian)
      repo_family="debian"
      ;;
    mx)
      repo_family="debian"
      codename="${DEBIAN_CODENAME:-}"
      ;;
    ubuntu)
      repo_family="ubuntu"
      ;;
    *)
      error_exit "Unsupported distribution '$distro_id'. This profile currently supports Debian/MX/Ubuntu apt-based systems only."
      ;;
  esac

  if [[ -z "$codename" ]]; then
    error_exit "Could not detect a supported Debian/Ubuntu codename from /etc/os-release. Refusing to guess Jellyfin repository suite."
  fi

  echo "$repo_family $codename"
}

configure_jellyfin_repo() {
  local repo_info
  local repo_family
  local codename
  local arch
  local tmp_key

  repo_info="$(detect_jellyfin_repo)"
  repo_family="${repo_info%% *}"
  codename="${repo_info#* }"
  arch="$(dpkg --print-architecture)"
  tmp_key="/tmp/reforge-jellyfin-key.gpg"

  log "Configuring official Jellyfin apt repository"

  install -d -m 0755 /etc/apt/keyrings
  curl -fsSL "$JELLYFIN_KEY_URL" -o "$tmp_key"
  gpg --dearmor --yes -o "$JELLYFIN_KEYRING" "$tmp_key"
  chmod 0644 "$JELLYFIN_KEYRING"
  rm -f "$tmp_key"

  cat > "$JELLYFIN_SOURCE" <<EOF
Types: deb
URIs: https://repo.jellyfin.org/$repo_family
Suites: $codename
Components: main
Architectures: $arch
Signed-By: $JELLYFIN_KEYRING
EOF
}

allow_ufw_port() {
  if ! command -v ufw >/dev/null 2>&1; then
    return 0
  fi

  if ufw status | grep -q "Status: active"; then
    log "Allowing Jellyfin through UFW firewall"
    ufw allow 8096/tcp || true
  fi
}

start_jellyfin_service() {
  if systemctl list-unit-files --type=service 2>/dev/null | grep -q '^jellyfin\.service'; then
    log "Enabling and starting Jellyfin service"
    systemctl enable jellyfin >/dev/null 2>&1 || true
    systemctl restart jellyfin || warn "Could not restart Jellyfin service."
    systemctl status jellyfin --no-pager || warn "Could not show Jellyfin service status."
  else
    warn "Jellyfin service was not found after installation."
  fi
}

grant_jellyfin_media_access() {
  if id jellyfin >/dev/null 2>&1; then
    log "Adding Jellyfin service user to media group"
    usermod -aG "$MEDIA_GROUP" jellyfin
  else
    warn "Jellyfin user was not found after installation."
  fi
}

print_completion() {
  local ip_address
  ip_address="$(local_ip)"

  echo
  echo "======================================"
  echo " Jellyfin Media Server setup complete"
  echo "======================================"
  echo
  echo "Access Jellyfin from another device:"
  echo "  http://$ip_address:8096"
  echo
  echo "Media folders:"
  echo "  $MEDIA_ROOT/movies"
  echo "  $MEDIA_ROOT/shows"
  echo "  $MEDIA_ROOT/music"
  echo "  $MEDIA_ROOT/videos"
  echo
  echo "Instructions:"
  echo "  Open the Jellyfin URL, complete the first-time setup wizard, and add the media folders as libraries."
  echo
  echo "Important:"
  echo "  This PC should remain powered on while streaming."
  echo
}

main() {
  log "Starting Reforge Media Server profile"

  detect_apt

  if jellyfin_installed; then
    show_existing_install_menu
    exit 0
  fi

  print_preinstall_warning
  if ! confirm "Continue with Jellyfin Media Server installation? [y/N] "; then
    echo "Jellyfin installation cancelled."
    pause
    exit 0
  fi

  setup_media_folders
  install_packages curl ca-certificates gnupg apt-transport-https
  configure_jellyfin_repo

  log "Installing Jellyfin"
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y jellyfin

  grant_jellyfin_media_access
  start_jellyfin_service
  allow_ufw_port
  print_completion
  pause
}

main "$@"
