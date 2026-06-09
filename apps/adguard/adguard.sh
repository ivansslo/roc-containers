#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  Created by: ivansslo (2026)
#  License: MIT
#  Repo: https://github.com/ivansslo/isdocker
# ─────────────────────────────────────────────────────────────────
#  isdocker · AdGuard Home
#  Image : adguard/adguardhome
#  Port  : 8123  (Web UI)
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/source.env"

cd "$(dirname "${BASH_SOURCE[0]}")"

IMAGE_NAME="adguard/adguardhome"
CONTAINER_NAME="adguardhome"

case $PORT in
  ''|*[!0-9]*) PORT=8123 ;;
  *) [ "$PORT" -gt 1023 ] && [ "$PORT" -lt 65536 ] || PORT=8123 ;;
esac

udocker_check
udocker_prune
udocker_create "$CONTAINER_NAME" "$IMAGE_NAME"

DATA_DIR="$(pwd)/../../data-$CONTAINER_NAME"
mkdir -p "$DATA_DIR/config"

_LIBNETSTUB_VOL="-v $(proot_write_tmp "$(cat "$(pwd)/../../lib/libnetstub.sh")")":/.libnetstub/libnetstub.sh

if [ -n "$1" ]; then
  cmd="$*"
  udocker_run --entrypoint "bash -c" -p "${PORT}:8123" \
    -e _PORT="$PORT" -e TZ="$(get_tz)" \
    $_LIBNETSTUB_VOL \
    -v "$(mktemp):/proc/sys/net/ipv4/ip_forward" \
    -v "$DATA_DIR/config:/config" \
    "$CONTAINER_NAME" ". /.libnetstub/libnetstub.sh; $cmd"
else
  udocker_run --entrypoint "bash -c" -p "${PORT}:8123" \
    -e _PORT="$PORT" -e TZ="$(get_tz)" \
    $_LIBNETSTUB_VOL \
    -v "$(mktemp):/proc/sys/net/ipv4/ip_forward" \
    -v "$DATA_DIR/config:/config" \
    "$CONTAINER_NAME" '
      echo -e "127.0.0.1   localhost.localdomain localhost\n::1         localhost.localdomain localhost ip6-localhost ip6-loopback\nfe00::0     ip6-localnet\nff00::0     ip6-mcastprefix\nff02::1     ip6-allnodes\nff02::2     ip6-allrouters\nff02::3     ip6-allhosts" >/etc/hosts
      if [[ ! -f /.libnetstub/libnetstub.so && -f /.libnetstub/libnetstub.sh ]]; then
          apk add --no-cache --virtual libnetstub-deps gcc musl-dev linux-headers patch && \
          mkdir -p /.libnetstub && \
          echo "ENV=~/.rc" >> ~/.profile && \
          echo ". /.libnetstub/libnetstub.sh" | tee -a ~/.rc ~/.bashrc ~/.zshrc >/dev/null
          . /.libnetstub/libnetstub.sh
          apk del libnetstub-deps
      fi
      . /.libnetstub/libnetstub.sh
      mkdir -p /var/log/adguardhome
      rm -f /var/log/adguardhome/*.log
      touch /var/log/adguardhome/{stdout,stderr}.log
      tail -F /var/log/adguardhome/stdout.log &
      tail -F /var/log/adguardhome/stderr.log >&2 &
      command -v start-stop-daemon &>/dev/null || apk add --no-cache openrc
      command -v yq &>/dev/null || apk add --no-cache yq
      [ -f /config/configuration.yaml ] || echo -e "assist_pipeline:\nbluetooth:\ncloud:\nconversation:\nenergy:\ngo2rtc:\nhistory:\nhomeassistant_alerts:\nlogbook:\nmedia_source:\nmobile_app:\nmy:\nssdp:\nstream:\nsun:\nusb:\nwebhook:\nzeroconf:\nfrontend:\n  themes: !include_dir_merge_named themes\nautomation: !include automations.yaml\nscript: !include scripts.yaml\nscene: !include scenes.yaml" > /config/configuration.yaml
      yq eval ".http.server_port = \"$_PORT\" | del(.dhcp)" -i /config/configuration.yaml &>/dev/null
      touch /config/{automations,scripts,scenes}.yaml
      _PIDFILE="$(mktemp)"
      start-stop-daemon -mp "$_PIDFILE" --stdout /var/log/adguardhome/stdout.log --stderr /var/log/adguardhome/stderr.log \
          -bSx "$(command -v bash)" -- -c "exec $(command -v AdGuardHome) --config /config/AdGuardHome.yaml --work-dir /config --no-check-update" && \
      while start-stop-daemon -Ktp "$_PIDFILE" &>/dev/null; do sleep 10; done
    '
fi

exit $?
