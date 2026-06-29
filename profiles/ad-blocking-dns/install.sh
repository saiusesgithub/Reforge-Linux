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

PIHOLE_REPO_URL="https://github.com/pi-hole/pi-hole.git"
INSTALLER_DIR="/tmp/reforge-pihole-installer"
PIHOLE_DIR="$INSTALLER_DIR/pi-hole"

confirm() {
  local prompt="$1"
  local answer

  read -rp "$prompt" answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

local_ip() {
  hostname -I 2>/dev/null | awk '{print $1}'
}

show_existing_install_menu() {
  echo
  echo "Pi-hole appears to be installed already."
  echo
  echo "1) Show Pi-hole status"
  echo "2) Run Pi-hole update"
  echo "3) Exit back to setup center"
  echo
  read -rp "Select an option: " existing_choice

  case "$existing_choice" in
    1)
      pihole status || warn "Pi-hole status command was unavailable or returned a non-zero status."
      ;;
    2)
      if pihole -up; then
        log "Pi-hole update completed."
      else
        warn "Pi-hole update did not complete successfully."
      fi
      ;;
    3)
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
  echo "Reforge Ad-Blocking DNS Server"
  echo "--------------------------------"
  echo "This profile will install Pi-hole, a network-wide DNS ad blocker."
  echo
  echo "Important:"
  echo "  - For best results, this PC should have a stable/static local IP."
  echo "  - Reforge Linux will NOT change router settings automatically."
  echo "  - After installation, set your router or device DNS to this PC's IP."
  echo "  - Pi-hole may use DNS port 53 and web port 80."
  echo
}

print_installer_guidance() {
  echo
  echo "Pi-hole installer guidance"
  echo "--------------------------"
  echo "When Pi-hole shows 'Static IP Needed', select 'Continue'."
  echo "Do not press Enter blindly if 'Exit' is selected."
  echo "For real use, router DHCP reservation/static IP is recommended."
  echo
}

check_port_with_ss() {
  local port="$1"
  local protocol="$2"

  case "$protocol" in
    tcp)
      ss -H -ltnp 2>/dev/null | awk -v port=":$port" '$4 ~ port "$" {print}'
      ;;
    udp)
      ss -H -lunp 2>/dev/null | awk -v port=":$port" '$4 ~ port "$" {print}'
      ;;
  esac
}

preflight_ports() {
  local conflicts=""

  if ! command -v ss >/dev/null 2>&1; then
    warn "Could not check ports because 'ss' is not available."
    return 0
  fi

  log "Checking for services already using DNS and web ports"

  local dns_tcp
  local dns_udp
  local http_tcp

  dns_tcp="$(check_port_with_ss 53 tcp || true)"
  dns_udp="$(check_port_with_ss 53 udp || true)"
  http_tcp="$(check_port_with_ss 80 tcp || true)"

  if [[ -n "$dns_tcp" ]]; then
    conflicts+=$'\n'"DNS 53/tcp appears busy:"$'\n'"$dns_tcp"$'\n'
  fi

  if [[ -n "$dns_udp" ]]; then
    conflicts+=$'\n'"DNS 53/udp appears busy:"$'\n'"$dns_udp"$'\n'
  fi

  if [[ -n "$http_tcp" ]]; then
    conflicts+=$'\n'"HTTP 80/tcp appears busy:"$'\n'"$http_tcp"$'\n'
  fi

  if [[ -z "$conflicts" ]]; then
    echo "No obvious port conflicts found."
    return 0
  fi

  warn "Possible Pi-hole port conflicts found."
  echo "$conflicts"
  echo "Reforge will not stop or kill any services automatically."
  echo

  if ! confirm "Continue anyway? [y/N] "; then
    error_exit "Pi-hole installation cancelled because of possible port conflicts."
  fi
}

prepare_installer_dir() {
  if [[ -e "$INSTALLER_DIR" ]]; then
    if [[ "$INSTALLER_DIR" != "/tmp/reforge-pihole-installer" ]]; then
      error_exit "Refusing to remove unexpected installer directory: $INSTALLER_DIR"
    fi

    rm -rf "$INSTALLER_DIR"
  fi

  mkdir -p "$INSTALLER_DIR"
}

allow_ufw_ports() {
  if ! command -v ufw >/dev/null 2>&1; then
    return 0
  fi

  if ufw status | grep -q "Status: active"; then
    log "Allowing Pi-hole ports through UFW firewall"
    ufw allow 53/tcp || true
    ufw allow 53/udp || true
    ufw allow 80/tcp || true
  fi
}

run_pihole_status() {
  if command -v pihole >/dev/null 2>&1; then
    if command -v sudo >/dev/null 2>&1; then
      sudo pihole status || warn "Pi-hole status command was unavailable or returned a non-zero status."
    else
      pihole status || warn "Pi-hole status command was unavailable or returned a non-zero status."
    fi
  else
    warn "Pi-hole command was not found after installation."
  fi
}

update_pihole_gravity() {
  if ! command -v pihole >/dev/null 2>&1; then
    warn "Skipping gravity update because the Pi-hole command was not found."
    return 0
  fi

  log "Updating Pi-hole gravity"
  if ! pihole -g; then
    warn "Pi-hole gravity update failed. Review the command output above."
  fi

  log "Restarting Pi-hole FTL service"
  systemctl restart pihole-FTL || warn "Could not restart pihole-FTL. Review the command output above."
}

print_completion() {
  local ip_address
  ip_address="$(local_ip)"

  echo
  echo "======================================"
  echo " Pi-hole setup complete"
  echo "======================================"
  echo
  echo "Admin dashboard:"
  echo "  http://$ip_address/admin"
  echo
  echo "DNS server IP:"
  echo "  $ip_address"
  echo
  echo "Router setup:"
  echo "  Set your router's DNS server to this IP, or manually set this IP as DNS on individual devices."
  echo
  echo "Testing:"
  echo "  After setting DNS, visit the Pi-hole dashboard and check query logs."
  echo
  echo "Important:"
  echo "  This PC should remain powered on for network-wide blocking to work."
  echo
}

main() {
  log "Starting Reforge Ad-Blocking DNS Server profile"

  detect_apt

  if command -v pihole >/dev/null 2>&1; then
    show_existing_install_menu
    exit 0
  fi

  print_preinstall_warning
  if ! confirm "Continue with Pi-hole installation? [y/N] "; then
    echo "Pi-hole installation cancelled."
    pause
    exit 0
  fi

  preflight_ports
  install_packages curl git ca-certificates lsb-release

  log "Preparing Pi-hole installer"
  prepare_installer_dir

  log "Cloning official Pi-hole installer"
  git clone --depth 1 "$PIHOLE_REPO_URL" "$PIHOLE_DIR"

  print_installer_guidance

  log "Running official Pi-hole installer"
  if ! bash "$PIHOLE_DIR/automated install/basic-install.sh"; then
    error_exit "Pi-hole installer failed. Review the installer output above and try again."
  fi

  update_pihole_gravity
  allow_ufw_ports

  log "Checking Pi-hole status"
  run_pihole_status

  print_completion
  pause
}

main "$@"
