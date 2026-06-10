#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  Created by: ivansslo (2026)
#  License: MIT
#  Repo: https://github.com/ivansslo/isdocker
# ─────────────────────────────────────────────────────────────────
#  isdocker · Windows 11 Lite (Tiny11)
#  Image : dockurr/windows
#  Port  : 8006 (Web VNC) / 5900 (VNC) / 3389 (RDP)
# ─────────────────────────────────────────────────────────────────
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/source.env"

cd "$(dirname "${BASH_SOURCE[0]}")"

IMAGE_NAME="dockurr/windows"
CONTAINER_NAME="windows-11"

# Ensure QEMU is installed in Termux
echo -e "${YELLOW}[*] Checking QEMU dependencies...${RESET}"
pkg install qemu-utils qemu-system-x86-64-headless -y &>/dev/null

case $PORT in
  ''|*[!0-9]*) PORT=8006 ;;
  *) [ "$PORT" -gt 1023 ] && [ "$PORT" -lt 65536 ] || PORT=8006 ;;
esac

DATA_DIR="$(pwd)/../../data-$CONTAINER_NAME"
mkdir -p "$DATA_DIR"

udocker_check
udocker_prune
udocker_create "$CONTAINER_NAME" "$IMAGE_NAME"

echo -e "\n${RED}${BOLD}[!] WARNING: Windows 11 is VERY heavy for Termux.${RESET}"
echo -e "${YELLOW}[*] Recommended: 4GB+ RAM and Snapdragon 845+ equivalents.${RESET}"
echo -e "${YELLOW}[*] The script will use dockurr/windows (Tiny11 version).${RESET}"
echo -e "${CYAN}[*] Web VNC : http://localhost:$PORT${RESET}"
echo -e "${CYAN}[*] VNC Port: localhost:5900 (vncpass)${RESET}"
echo -e "${CYAN}[*] RDP Port: localhost:3389${RESET}\n"

# Run with Web, VNC, and RDP ports mapped
udocker_run --entrypoint "bash -c" \
  -p "${PORT}:8006" \
  -p "5900:5900" \
  -p "3389:3389" \
  -e VERSION="tiny11" \
  -e RAM_SIZE="4G" \
  -e CPU_CORES="4" \
  -e DISK_SIZE="64G" \
  -v "$DATA_DIR:/storage" \
  "$CONTAINER_NAME"
