#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  Created by: ivansslo (2026)
#  License: MIT
#  Repo: https://github.com/ivansslo/isdocker
# ─────────────────────────────────────────────────────────────────
#  isdocker · Alpine Desktop (VNC)
#  Image : alpine:latest
#  Port  : 5903 (VNC)
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/source.env"

cd "$(dirname "${BASH_SOURCE[0]}")"

IMAGE_NAME="alpine:latest"
CONTAINER_NAME="alpine-vnc"

case $PORT in
  ''|*[!0-9]*) PORT=5903 ;;
  *) [ "$PORT" -gt 1023 ] && [ "$PORT" -lt 65536 ] || PORT=5903 ;;
esac

DATA_DIR="$(pwd)/../../data-$CONTAINER_NAME"
mkdir -p "$DATA_DIR/root"

udocker_check
udocker_prune
udocker_create "$CONTAINER_NAME" "$IMAGE_NAME"

echo -e "\n${YELLOW}[*] Preparing Alpine Desktop (XFCE)...${RESET}"

udocker_run --entrypoint "bash -c" -p "${PORT}:5901" \
  -e _PORT="$PORT" -e TZ="$(get_tz)" \
  -v "$DATA_DIR/root:/root" \
  "$CONTAINER_NAME" '
    apk update
    apk add xfce4 xfce4-terminal tightvncserver dbus xsetroot xauth
    
    mkdir -p /root/.vnc
    echo "vncpass" | vncpasswd -f > /root/.vnc/passwd
    chmod 600 /root/.vnc/passwd
    
    echo "#!/bin/sh
    /usr/bin/startxfce4" > /root/.vnc/xstartup
    chmod +x /root/.vnc/xstartup
    
    vncserver -kill :1 >/dev/null 2>&1 || true
    rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 >/dev/null 2>&1 || true
    
    echo ""
    echo "[*] Alpine VNC Desktop ready!"
    echo "[*] Address: localhost:$_PORT"
    echo "[*] Password: vncpass"
    echo ""
    
    USER=root vncserver :1 -geometry 1280x720 -depth 24 && tail -f /root/.vnc/*.log
  '
