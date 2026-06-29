#!/usr/bin/env bash

set -Eeuo pipefail

log() {
  echo
  echo "==> $1"
}

warn() {
  echo
  echo "WARNING: $1"
}

error_exit() {
  echo
  echo "ERROR: $1"
  exit 1
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    error_exit "This script must run as root."
  fi
}

detect_apt() {
  if ! command -v apt-get >/dev/null 2>&1; then
    error_exit "apt-get not found. This profile currently supports Debian/MX/Ubuntu-based systems only."
  fi
}

install_packages() {
  detect_apt
  log "Updating package lists..."
  apt-get update

  log "Installing packages: $*"
  DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

pause() {
  echo
  read -rp "Press Enter to continue..."
}