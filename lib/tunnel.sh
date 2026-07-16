#!/usr/bin/env bash
# lib/tunnel.sh — Cloudflare Tunnel untuk ROC ecosystem (label: ag.roadfx.biz.id)
# Subcommand: install | login | create | up | up-bg | down | status | url | quick | help
set -uo pipefail

CFD_BIN="$(command -v cloudflared 2>/dev/null || true)"
CFD_HOME="${CLOUDFLARED_HOME:-$HOME/.cloudflared}"
ROC_CFD_DIR="$HOME/.roc-containers/cloudflared"
TUN_NAME="${ROC_TUNNEL_NAME:-roc-ag-hp}"
TUN_HOST="${ROC_TUNNEL_HOST:-ag.roadfx.biz.id}"
TUN_TARGET="${ROC_TUNNEL_TARGET:-http://localhost:5905}"
PIDFILE="$ROC_CFD_DIR/tunnel.pid"
LOGFILE="$ROC_CFD_DIR/tunnel.log"

G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; C='\033[0;36m'; B='\033[1m'; D='\033[2m'; N='\033[0m'
ok(){   printf "  ${G}[✓]${N} %s\n" "$*"; }
warn(){ printf "  ${Y}[!]${N} %s\n" "$*"; }
err(){  printf "  ${R}[✗]${N} %s\n" "$*"; }
note(){ printf "  ${D}%s${N}\n" "$*"; }

need_cfd(){
  [ -n "$CFD_BIN" ] || { err "cloudflared belum terinstall — jalankan: roc-tunnel install"; exit 1; }
}

cmd_install(){
  if command -v pkg &>/dev/null; then
    pkg install -y cloudflared && ok "cloudflared terinstall via pkg"
  else
    warn "pkg tidak ditemukan (bukan Termux?) — pasang cloudflared manual: https://github.com/cloudflare/cloudflared/releases"
  fi
  CFD_BIN="$(command -v cloudflared 2>/dev/null || true)"
  [ -n "$CFD_BIN" ] && cloudflared --version
}

cmd_login(){
  need_cfd
  mkdir -p "$CFD_HOME"
  echo -e "${B}Login Cloudflare (satu kali):${N}"
  note "cloudflared akan mencetak URL — buka di browser HP, login, pilih zone roadfx.biz.id"
  cloudflared tunnel login
  [ -f "$CFD_HOME/cert.pem" ] && ok "cert.pem tersimpan di $CFD_HOME" || warn "cert.pem belum ada — ulangi login"
}

cmd_create(){
  need_cfd
  [ -f "$CFD_HOME/cert.pem" ] || { err "belum login — jalankan: roc-tunnel login"; exit 1; }
  mkdir -p "$ROC_CFD_DIR"
  # 1) tunnel (idempoten)
  if cloudflared tunnel list 2>/dev/null | grep -q " $TUN_NAME\b"; then
    ok "tunnel '$TUN_NAME' sudah ada — pakai ulang"
  else
    cloudflared tunnel create "$TUN_NAME" && ok "tunnel '$TUN_NAME' dibuat"
  fi
  local TID
  TID="$(cloudflared tunnel list -o json 2>/dev/null | python3 -c 'import json,sys
name=sys.argv[1]
for t in json.load(sys.stdin):
    if t.get("name")==name: print(t["id"]); break
' "$TUN_NAME" 2>/dev/null || true)"
  [ -n "$TID" ] || TID="$(cloudflared tunnel list 2>/dev/null | awk -v n="$TUN_NAME" '$2==n{print $1; exit}')"
  [ -n "$TID" ] || { err "gagal membaca tunnel id"; exit 1; }
  printf '%s\n' "$TID" > "$ROC_CFD_DIR/tunnel.id"
  # 2) ingress config
  cat > "$ROC_CFD_DIR/config.yml" <<EOF
tunnel: $TID
credentials-file: $CFD_HOME/$TID.json
ingress:
  - hostname: $TUN_HOST
    service: $TUN_TARGET
  - service: http_status:404
EOF
  ok "ingress: https://$TUN_HOST → $TUN_TARGET (config: $ROC_CFD_DIR/config.yml)"
  # 3) DNS route (idempoten)
  cloudflared tunnel route dns "$TUN_NAME" "$TUN_HOST" 2>/dev/null \
    && ok "DNS: $TUN_HOST → tunnel" \
    || note "DNS route mungkin sudah ada (abaikan bila error 'already exists')"
  note "override env: ROC_TUNNEL_NAME · ROC_TUNNEL_HOST · ROC_TUNNEL_TARGET"
}

cmd_up(){
  need_cfd
  [ -f "$ROC_CFD_DIR/config.yml" ] || { err "belum create — jalankan: roc-tunnel create"; exit 1; }
  echo -e "${B}🌐 Tunnel UP${N} → ${C}https://$TUN_HOST${N} → $TUN_TARGET"
  note "biarkan sesi ini terbuka (atau pakai: roc-tunnel up-bg)"
  exec cloudflared tunnel --config "$ROC_CFD_DIR/config.yml" run
}

cmd_up_bg(){
  need_cfd
  [ -f "$ROC_CFD_DIR/config.yml" ] || { err "belum create — jalankan: roc-tunnel create"; exit 1; }
  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    warn "tunnel sudah jalan (pid $(cat "$PIDFILE"))"; exit 0
  fi
  mkdir -p "$ROC_CFD_DIR"
  nohup cloudflared tunnel --config "$ROC_CFD_DIR/config.yml" run > "$LOGFILE" 2>&1 &
  echo $! > "$PIDFILE"
  sleep 3
  if kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    ok "tunnel background pid $(cat "$PIDFILE")"
    echo -e "  ${B}URL publik:${N} https://$TUN_HOST"
    note "log: $LOGFILE · berhenti: roc-tunnel down"
  else
    err "tunnel mati — cek log: tail -20 $LOGFILE"; exit 1
  fi
}

cmd_down(){
  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill "$(cat "$PIDFILE")" && rm -f "$PIDFILE" && ok "tunnel dihentikan"
  else
    warn "tidak ada tunnel background aktif"
  fi
}

cmd_status(){
  echo -e "${B}🌐 roc-tunnel status${N}"
  echo -e "  ${C}binary:${N}    ${CFD_BIN:-belum terinstall (roc-tunnel install)}"
  echo -e "  ${C}cert:${N}      $([ -f "$CFD_HOME/cert.pem" ] && echo OK || echo 'belum login')"
  echo -e "  ${C}tunnel:${N}    $TUN_NAME ${D}($(cat "$ROC_CFD_DIR/tunnel.id" 2>/dev/null || echo 'belum create'))${N}"
  echo -e "  ${C}hostname:${N}  https://$TUN_HOST → $TUN_TARGET"
  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo -e "  ${C}proses:${N}    ${G}RUNNING${N} (pid $(cat "$PIDFILE"))"
  else
    echo -e "  ${C}proses:${N}    ${D}stop${N}"
  fi
  if command -v curl &>/dev/null && [ -f "$ROC_CFD_DIR/tunnel.id" ]; then
    local code
    code=$(curl -s -m 8 -o /dev/null -w '%{http_code}' "https://$TUN_HOST/" 2>/dev/null || echo 000)
    case "$code" in
      2*|3*|401|403) echo -e "  ${C}probe:${N}     ${G}$code${N} https://$TUN_HOST/" ;;
      *) echo -e "  ${C}probe:${N}     ${R}$code${N} https://$TUN_HOST/" ;;
    esac
  fi
}

cmd_url(){ echo "https://$TUN_HOST"; }

cmd_quick(){
  need_cfd
  warn "mode quick = URL acak *.trycloudflare.com (sementara, tanpa Access) — hanya untuk uji"
  exec cloudflared tunnel --url "$TUN_TARGET"
}

case "${1:-help}" in
  install) cmd_install ;;
  login) cmd_login ;;
  create) shift; cmd_create "$@" ;;
  up|run) cmd_up ;;
  up-bg|bg) cmd_up_bg ;;
  down|stop) cmd_down ;;
  status|st) cmd_status ;;
  url) cmd_url ;;
  quick) cmd_quick ;;
  *)
    echo -e "${B}roc-tunnel${N} — Cloudflare Tunnel untuk layanan ROC"
    echo "  install   pasang cloudflared (pkg/Brew)"
    echo "  login     OAuth sekali (buka URL di browser HP)"
    echo "  create    buat tunnel + ingress $TUN_HOST → $TUN_TARGET + DNS"
    echo "  up        jalankan foreground   |  up-bg   background (nohup)"
    echo "  down      hentikan background   |  status  ringkasan + probe"
    echo "  url       cetak URL publik      |  quick   uji trycloudflare acak"
    ;;
esac
