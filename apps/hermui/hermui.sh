#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  Created by: ivansslo (2026)
#  License: MIT
#  Repo: https://github.com/ivansslo/roc-containers
# ─────────────────────────────────────────────────────────────────
#  roc-containers · Hermes UI
#  Clone: ivansslo/hermes-ui
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/source.env" 2>/dev/null || true

# Colors
: "${RED:=$'\033[0;31m'}"; : "${GREEN:=$'\033[0;32m'}"; : "${YELLOW:=$'\033[1;33m'}"
: "${CYAN:=$'\033[0;36m'}"; : "${BOLD:=$'\033[1m'}"; : "${DIM:=$'\033[2m'}"; : "${RESET:=$'\033[0m'}"

HERMUI_DIR="$HOME/.roc-containers/apps/hermui/hermes-ui"
HERMUI_REPO="https://github.com/ivansslo/hermes-ui"
HERMUI_FALLBACK=0

# Clone or update hermes-ui repo
# FIX v1.4.0: repo ivansslo/hermes-ui tidak lagi publik (404) — jangan
# exit 1; degradasi gracefully ke dashboard bundel roc-agentsroute.
hermui_ensure() {
  if [ ! -d "$HERMUI_DIR/.git" ]; then
    echo -e "${YELLOW}[*] Cloning Hermes UI...${RESET}"
    git clone --depth 1 "$HERMUI_REPO" "$HERMUI_DIR" 2>/dev/null
    if [ $? -ne 0 ]; then
      HERMUI_FALLBACK=1
      echo -e "${YELLOW}[!] Repo hermes-ui tidak tersedia (404/privat) — pakai dashboard bundel.${RESET}"
      return 1
    fi
    echo -e "${GREEN}[✓] Repo berhasil di-clone${RESET}"
  else
    echo -e "${DIM}[*] Updating Hermes UI...${RESET}"
    git -C "$HERMUI_DIR" pull --ff-only 2>/dev/null || true
  fi
}

# Dashboard bundel (roc-agentsroute) sebagai pengganti hermes-ui
_hermui_dashboard() {
  local d1="$HOME/.roc-containers/apps/roc-agent/dashboard"
  local d2="$HOME/.roc-containers/ui"
  if [ -f "$d1/index.html" ]; then echo "$d1/index.html"
  elif [ -f "$d2/roc-containers-ui.html" ]; then echo "$d2/roc-containers-ui.html"
  else echo ""; fi
}

# Show README / docs
hermui_docs() {
  hermui_ensure
  if [ "$HERMUI_FALLBACK" = 1 ]; then
    echo -e "${CYAN}${BOLD}Hermes UI (fallback) — Dashboard bundel roc-agentsroute${RESET}\n"
    local f; f="$(_hermui_dashboard)"
    [ -n "$f" ] && echo -e "  File: ${BOLD}$f${RESET}\n  Jalankan: ${CYAN}roc-hermui run${RESET} untuk menyajikannya di browser."
    return 0
  fi
  if [ -f "$HERMUI_DIR/README.md" ]; then
    cat "$HERMUI_DIR/README.md"
  else
    echo -e "${YELLOW}[!] README.md tidak ditemukan${RESET}"
  fi
}

# List contents
hermui_list() {
  hermui_ensure
  if [ "$HERMUI_FALLBACK" = 1 ]; then
    local f; f="$(_hermui_dashboard)"
    echo -e "${BOLD}Hermes UI (fallback) — file bundel:${RESET}\n"
    [ -n "$f" ] && ls -lh "$f" && echo -e "\n${DIM}Path: $f${RESET}"
    return 0
  fi
  echo -e "${BOLD}Hermes UI — Repo Contents:${RESET}\n"
  ls -1 "$HERMUI_DIR/" | head -40
  echo ""
  echo -e "${DIM}Path: $HERMUI_DIR${RESET}"
}

# Open shell in repo dir
hermui_shell() {
  hermui_ensure
  if [ "$HERMUI_FALLBACK" = 1 ]; then
    local f; f="$(_hermui_dashboard)"
    [ -n "$f" ] && cd "$(dirname "$f")" && exec bash
    echo -e "${RED}[✗] Tidak ada dir untuk shell${RESET}"; return 1
  fi
  echo -e "${DIM}Hermes UI dir: $HERMUI_DIR${RESET}"
  cd "$HERMUI_DIR" && exec bash
}

# Install / setup dependencies
hermui_install() {
  hermui_ensure
  echo -e "${YELLOW}[*] Setting up Hermes UI...${RESET}"

  # Check for requirements.txt
  if [ -f "$HERMUI_DIR/requirements.txt" ]; then
    echo -e "${YELLOW}[*] Installing Python dependencies...${RESET}"
    if [ -x "$HOME/.hermes/python3_venv/bin/pip" ]; then
      "$HOME/.hermes/python3_venv/bin/pip" install -r "$HERMUI_DIR/requirements.txt" 2>/dev/null || true
    elif command -v pip &>/dev/null; then
      pip install -r "$HERMUI_DIR/requirements.txt" 2>/dev/null || true
    else
      echo -e "${YELLOW}[!] pip not found. Install: pkg install python${RESET}"
    fi
  fi

  # Check for package.json
  if [ -f "$HERMUI_DIR/package.json" ]; then
    echo -e "${YELLOW}[*] Installing npm dependencies...${RESET}"
    if command -v npm &>/dev/null; then
      cd "$HERMUI_DIR" && npm install --silent 2>/dev/null || true
    else
      echo -e "${YELLOW}[!] npm not found. Install: pkg install nodejs${RESET}"
    fi
  fi

  echo -e "${GREEN}[✓] Hermes UI setup selesai${RESET}"
}

# Run / serve
hermui_run() {
  hermui_ensure
  if [ "$HERMUI_FALLBACK" = 1 ]; then
    local f port py
    f="$(_hermui_dashboard)"
    if [ -z "$f" ]; then
      echo -e "${RED}[✗] Dashboard bundel tidak ditemukan. Jalankan roc-update.${RESET}"
      return 1
    fi
    port="${PORT:-8080}"
    py="python3"; [ -x "$HOME/.hermes/python3_venv/bin/python" ] && py="$HOME/.hermes/python3_venv/bin/python"
    echo -e "${GREEN}[✓] Hermes UI (dashboard bundel) → http://localhost:$port${RESET}"
    echo -e "  ${DIM}File: $f  ·  Ctrl+C untuk berhenti${RESET}"
    (cd "$(dirname "$f")" && exec "$py" -m http.server "$port" --bind 127.0.0.1)
    return $?
  fi
  echo -e "${YELLOW}[*] Starting Hermes UI...${RESET}"

  # Try npm start first
  if [ -f "$HERMUI_DIR/package.json" ] && grep -q '"start"' "$HERMUI_DIR/package.json"; then
    cd "$HERMUI_DIR" && npm start
  # Try python app
  elif [ -f "$HERMUI_DIR/app.py" ]; then
    local py="python3"
    [ -x "$HOME/.hermes/python3_venv/bin/python" ] && py="$HOME/.hermes/python3_venv/bin/python"
    cd "$HERMUI_DIR" && exec "$py" app.py "$@"
  elif [ -f "$HERMUI_DIR/main.py" ]; then
    local py="python3"
    [ -x "$HOME/.hermes/python3_venv/bin/python" ] && py="$HOME/.hermes/python3_venv/bin/python"
    cd "$HERMUI_DIR" && exec "$py" main.py "$@"
  else
    echo -e "${YELLOW}[!] Tidak ada entry point otomatis. Buka shell manual:${RESET}"
    echo -e "  ${CYAN}roc-hermui shell${RESET}"
  fi
}

# Main
hermui_main() {
  local cmd="${1:-}"

  if [ -z "$cmd" ]; then
    echo -e "${CYAN}${BOLD}"
    echo " ╔══════════════════════════════════════════════════════╗"
    echo " ║  Hermes UI — ivansslo/hermes-ui                     ║"
    echo " ╚══════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e " ${BOLD}Usage:${RESET}"
    echo -e "  ${CYAN}roc-hermui install${RESET}  Clone & install dependencies"
    echo -e "  ${CYAN}roc-hermui run${RESET}      Run / serve Hermes UI"
    echo -e "  ${CYAN}roc-hermui docs${RESET}     View README"
    echo -e "  ${CYAN}roc-hermui list${RESET}     List repo contents"
    echo -e "  ${CYAN}roc-hermui shell${RESET}    Open shell in repo dir"
    echo -e "  ${CYAN}roc-hermui update${RESET}   Pull latest changes"
    echo ""
    echo -e " ${DIM}Repo: ivansslo/hermes-ui${RESET}"
    echo -e " ${DIM}Path: $HERMUI_DIR${RESET}"
    return 0
  fi

  case "$cmd" in
install|setup|i)
  if hermui_ensure && [ "$HERMUI_FALLBACK" != 1 ]; then hermui_install
  else echo -e "${GREEN}[✓] Fallback aktif — tidak ada dependency (single-file dashboard)${RESET}"; fi
  ;;
run|start|serve|s)
  shift
  hermui_run "$@"
  ;;
docs|readme|help|h)
  hermui_docs
  ;;
list|ls)
  hermui_list
  ;;
shell|sh)
  hermui_shell
  ;;
update|up|pull)
  echo -e "${YELLOW}[*] Updating Hermes UI...${RESET}"
  if [ -d "$HERMUI_DIR/.git" ]; then git -C "$HERMUI_DIR" pull --ff-only 2>/dev/null || true
  else hermui_ensure || true; fi
  echo -e "${GREEN}[✓] Updated${RESET}"
  ;;
    clone)
      hermui_ensure
      ;;
    *)
      echo -e "${RED}Unknown command: $cmd${RESET}"
      echo -e "Run ${CYAN}roc-hermui${RESET} for usage"
      ;;
  esac
}

hermui_main "$@"
