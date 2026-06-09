#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  Created by: ivansslo (2026)
#  License: MIT
#  Repo: https://github.com/ivansslo/isdocker
# ─────────────────────────────────────────────────────────────────
#  isdocker · Ubuntu Desktop (VNC)
#  Image : ubuntu:22.04
#  Port  : 5901 (VNC)
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/source.env"

cd "$(dirname "${BASH_SOURCE[0]}")"

IMAGE_NAME="ubuntu:22.04"
CONTAINER_NAME="ubuntu-vnc"

case $PORT in
  ''|*[!0-9]*) PORT=5901 ;;
  *) [ "$PORT" -gt 1023 ] && [ "$PORT" -lt 65536 ] || PORT=5901 ;;
esac

DATA_DIR="$(pwd)/../../data-$CONTAINER_NAME"
mkdir -p "$DATA_DIR/root"

udocker_check
udocker_prune
udocker_create "$CONTAINER_NAME" "$IMAGE_NAME"

echo -e "\n${YELLOW}[*] Preparing Ubuntu Desktop (XFCE)...${RESET}"
echo -e "${DIM}    This may take a while depending on your internet speed.${RESET}\n"

udocker_run --entrypoint "bash -c" -p "${PORT}:5901" \
  -e _PORT="$PORT" -e TZ="$(get_tz)" \
  -v "$DATA_DIR/root:/root" \
  "$CONTAINER_NAME" '
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y --no-install-recommends \
      xfce4 xfce4-goodies tightvncserver xterm \
      curl wget git nano sudo dbus-x11 2>/dev/null || true
    
    mkdir -p /root/.vnc
    echo "vncpass" | vncpasswd -f > /root/.vnc/passwd
    chmod 600 /root/.vnc/passwd
    
    echo "#!/bin/sh
    xrdb $HOME/.Xresources
    startxfce4 &" > /root/.vnc/xstartup
    chmod +x /root/.vnc/xstartup
    
    # Clean up old locks
    vncserver -kill :1 >/dev/null 2>&1 || true
    rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 >/dev/null 2>&1 || true
    
    echo ""
    echo "[*] Ubuntu VNC Desktop ready!"
    echo "[*] Address: localhost:$_PORT"
    echo "[*] Password: vncpass"
    echo ""
    
    USER=root vncserver :1 -geometry 1280x720 -depth 24 && tail -f /root/.vnc/*.log
  '
