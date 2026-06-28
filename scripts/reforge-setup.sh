#!/usr/bin/env bash

set -e

PROJECT_NAME="Reforge Linux"
SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

show_header() {
  clear
  echo "======================================"
  echo "        $PROJECT_NAME Setup Center     "
  echo "======================================"
  echo
  echo "Old hardware. New purpose."
  echo
}

show_menu() {
  echo
  echo "What do you want this old PC to become?"
  echo
  echo "1) File Server / NAS Lite"
  echo "2) Ad-Blocking DNS Server"
  echo "3) Media Server"
  echo "4) System Info"
  echo "5) Exit"
  echo
}

show_system_info() {
  echo
  echo "System Information"
  echo "------------------"
  echo "Hostname: $(hostname)"
  echo "Kernel: $(uname -r)"
  echo "Architecture: $(uname -m)"
  echo "Memory:"
  free -h
  echo
  echo "Disk:"
  df -h /
  echo
  read -rp "Press Enter to continue..."
}

run_profile() {
  case "$1" in
    1)
      bash "$ROOT_DIR/profiles/file-server/install.sh"
      ;;
    2)
      bash "$ROOT_DIR/profiles/ad-blocking-dns/install.sh"
      ;;
    3)
      bash "$ROOT_DIR/profiles/media-server/install.sh"
      ;;
    *)
      echo "Invalid profile."
      ;;
  esac
}

main() {
  while true; do
    show_header
    show_menu
    read -rp "Select an option: " choice

    case "$choice" in
      1|2|3)
        run_profile "$choice"
        ;;
      4)
        show_system_info
        ;;
      5)
        echo "Exiting Reforge Setup Center."
        exit 0
        ;;
      *)
        echo "Invalid option."
        sleep 1
        ;;
    esac
  done
}

main
