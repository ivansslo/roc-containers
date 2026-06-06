#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  isdocker · Alpine Linux (latest)
#  Image : alpine:latest
#  Port  : 2225 (SSH)
# ─────────────────────────────────────────────────────────────────
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/source.env"

cd "$(dirname "${BASH_SOURCE[0]}")"

IMAGE_NAME="alpine:latest"
CONTAINER_NAME="alpine-server"

case $PORT in
  ''|*[!0-9]*) PORT=2225 ;;
  *) [ "$PORT" -gt 1023 ] && [ "$PORT" -lt 65536 ] || PORT=2225 ;;
esac

DATA_DIR="$(pwd)/../../data-$CONTAINER_NAME"
mkdir -p "$DATA_DIR/root"

udocker_check
udocker_prune
udocker_create "$CONTAINER_NAME" "$IMAGE_NAME"

if [ -n "$1" ]; then
  cmd="$*"
  udocker_run --entrypoint "sh -c" -p "${PORT}:22" \
    -v "$DATA_DIR/root:/root" "$CONTAINER_NAME" "$cmd"
else
  udocker_run --entrypoint "sh -c" -p "${PORT}:22" \
    -e _PORT="$PORT" \
    -v "$DATA_DIR/root:/root" \
    "$CONTAINER_NAME" '
      apk update -q
      apk add --no-cache openssh curl wget git nano bash 2>/dev/null || true
      ssh-keygen -A &>/dev/null
      sed -i -e "s/#PermitRootLogin.*/PermitRootLogin yes/" \
              -e "s/#PasswordAuthentication.*/PasswordAuthentication yes/" \
              /etc/ssh/sshd_config
      echo "root:alpine" | chpasswd
      echo ""
      echo "[*] Alpine Linux ready — ssh root@localhost -p '"'"'$_PORT'"'"'  (pass: alpine)"
      echo ""
      exec /usr/sbin/sshd -D -p "$_PORT"
    '
fi

exit $?
