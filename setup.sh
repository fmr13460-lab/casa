#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Maltego Graph Installer
# Kali Linux / Debian-based distributions
# ============================================================

VERSION="4.13.0"
PACKAGE="Maltego.v${VERSION}.deb"
URL="https://downloads.maltego.com/maltego-v4/linux/${PACKAGE}"

TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

echo "=========================================="
echo "       Maltego Graph Installer"
echo "=========================================="
echo

# Check that we're running on Debian/Kali
if ! command -v apt >/dev/null 2>&1; then
    echo "[!] This installer requires a Debian-based system."
    exit 1
fi

# Check architecture
ARCH="$(dpkg --print-architecture)"

if [[ "$ARCH" != "amd64" ]]; then
    echo "[!] Unsupported architecture: $ARCH"
    echo "[!] This installer currently supports amd64."
    exit 1
fi

echo "[+] Architecture: $ARCH"

# Check sudo
if ! command -v sudo >/dev/null 2>&1; then
    echo "[!] sudo is not installed."
    exit 1
fi

# Update repositories
echo
echo "[*] Updating package lists..."
sudo apt update

# Install required tools
echo
echo "[*] Installing required dependencies..."
sudo apt install -y ca-certificates curl

# Download Maltego
echo
echo "[*] Downloading Maltego ${VERSION}..."
echo "[*] ${URL}"
echo

curl \
    --fail \
    --location \
    --progress-bar \
    "$URL" \
    --output "$TMP_DIR/$PACKAGE"

# Check that the download exists
if [[ ! -s "$TMP_DIR/$PACKAGE" ]]; then
    echo "[!] Download failed."
    exit 1
fi

echo
echo "[+] Download completed."

# Check that it is actually a Debian package
if ! dpkg-deb --info "$TMP_DIR/$PACKAGE" >/dev/null 2>&1; then
    echo "[!] The downloaded file is not a valid Debian package."
    echo "[!] The download URL may have changed."
    exit 1
fi

echo "[+] Debian package verified."

# Install
echo
echo "[*] Installing Maltego..."
sudo apt install -y "$TMP_DIR/$PACKAGE"

echo
echo "=========================================="
echo "       Maltego installation complete!"
echo "=========================================="
echo
echo "Run Maltego with:"
echo
echo "    maltego"
echo

# Ask whether to launch
read -r -p "Start Maltego now? [Y/n] " answer

if [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]; then
    echo
    echo "[*] Starting Maltego..."
    exec maltego
fi
