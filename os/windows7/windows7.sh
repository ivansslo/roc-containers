#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  Created by: ivansslo (2026)
#  License: MIT
#  Repo: https://github.com/ivansslo/isdocker
# ─────────────────────────────────────────────────────────────────
#  isdocker · Windows 7 Lite
#  Image : dockurr/windows
#  Port  : 8007 (Web VNC) / 5901 (VNC)
# ─────────────────────────────────────────────────────────────────
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/source.env"

cd "$(dirname "${BASH_SOURCE[0]}")"

IMAGE_NAME="dockurr/windows"
CONTAINER_NAME="windows-7"

echo -e "${YELLOW}[*] Checking QEMU dependencies...${RESET}"
pkg install qemu-utils qemu-system-x86-64-headless -y &>/dev/null

case $PORT in
  ''|*[!0-9]*) PORT=8007 ;;
  *) [ "$PORT" -gt 1023 ] && [ "$PORT" -lt 65536 ] || PORT=8007 ;;
esac

DATA_DIR="$(pwd)/../../data-$CONTAINER_NAME"
mkdir -p "$DATA_DIR"

udocker_check
udocker_prune
udocker_create "$CONTAINER_NAME" "$IMAGE_NAME"

echo -e "\n${GREEN}[*] Starting Windows 7 (Lighter than Win11)...${RESET}"
echo -e "${CYAN}[*] Web VNC : http://localhost:$PORT${RESET}"
echo -e "${CYAN}[*] VNC Port: localhost:5901${RESET}\n"

udocker_run --entrypoint "bash -c" \
  -p "${PORT}:8006" \
  -p "5901:5900" \
  -e VERSION="win7" \
  -e RAM_SIZE="2G" \
  -e CPU_CORES="2" \
  -v "$DATA_DIR:/storage" \
  "$CONTAINER_NAME"
