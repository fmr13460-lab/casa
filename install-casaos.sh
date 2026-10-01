#!/usr/bin/env bash
#
# CasaOS installer for Debian
# Uses the official CasaOS installer from IceWhaleTech.
#
# Usage:
#   chmod +x install-casaos.sh
#   sudo ./install-casaos.sh
#
# Official installer:
#   https://get.casaos.io
#

set -Eeuo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()  { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

trap 'die "Installation failed on line $LINENO."' ERR

[[ "${EUID}" -eq 0 ]] || die "Run this script as root: sudo ./install-casaos.sh"

[[ -r /etc/os-release ]] || die "/etc/os-release was not found."
. /etc/os-release

[[ "${ID:-}" == "debian" ]] || die "This script is intended for Debian. Detected: ${ID:-unknown}"

if [[ -n "${VERSION_ID:-}" ]]; then
    log "Detected Debian ${VERSION_ID}."
fi

if ! command -v curl >/dev/null 2>&1; then
    log "Installing curl..."
    apt-get update
    apt-get install -y curl ca-certificates
fi

if ! command -v curl >/dev/null 2>&1; then
    die "curl could not be installed."
fi

warn "CasaOS will modify your Debian server and install required components."
warn "Make sure you have a backup of important data before continuing."

echo
read -r -p "Continue with CasaOS installation? [y/N] " answer
[[ "${answer}" =~ ^[Yy]$ ]] || { log "Installation cancelled."; exit 0; }

log "Starting the official CasaOS installer..."
curl -fsSL https://get.casaos.io | bash

log "CasaOS installation completed."

echo
log "Check the service with:"
echo "  systemctl status casaos --no-pager"
echo
log "Find your server IP with:"
echo "  hostname -I"
echo
log "Then open CasaOS in a browser using the server's IP address."
