#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  Created by: ivansslo (2026)
#  License: MIT
#  Repo: https://github.com/ivansslo/roc-containers
# ─────────────────────────────────────────────────────────────────
#  roc-containers · lsmod — Module System for roc-ai
#  Clone: ivansslo/lsmod
#  Provides: Agent Mode, Chat, Coding, Error Functions
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/source.env" 2>/dev/null || true

# Colors
: "${RED:=$'\033[0;31m'}"; : "${GREEN:=$'\033[0;32m'}"; : "${YELLOW:=$'\033[1;33m'}"
: "${CYAN:=$'\033[0;36m'}"; : "${BLUE:=$'\033[0;34m'}"; : "${MAGENTA:=$'\033[0;35m'}"
: "${BOLD:=$'\033[1m'}"; : "${DIM:=$'\033[2m'}"; : "${RESET:=$'\033[0m'}"

LSMOD_DIR="$HOME/.roc-containers/apps/ai/modules/lsmod"
LSMOD_REPO="https://github.com/ivansslo/lsmod"
LSMOD_DATA_DIR="$HOME/.roc-containers/data-lsmod"

# ──────────────────────────────────────────────────────────────
#  Core Functions
# ──────────────────────────────────────────────────────────────

lsmod_ensure() {
  if [ ! -d "$LSMOD_DIR/.git" ]; then
    echo -e "${YELLOW}[*] Cloning lsmod (Module System)...${RESET}"
    GIT_TERMINAL_PROMPT=0 git clone --depth 1 "$LSMOD_REPO" "$LSMOD_DIR" 2>/dev/null
    if [ $? -ne 0 ]; then
      echo -e "${RED}[✗] Gagal clone repo. Cek koneksi internet.${RESET}"
      return 1
    fi
    echo -e "${GREEN}[✓] lsmod berhasil di-clone${RESET}"
  else
    echo -e "${DIM}[*] Updating lsmod...${RESET}"
    git -C "$LSMOD_DIR" pull --ff-only 2>/dev/null || true
  fi
  mkdir -p "$LSMOD_DATA_DIR"
}

# Load API keys from env (NO hardcoded keys)
lsmod_load_keys() {
  # Load from hermes_keys
  [ -f "$HOME/.hermes_keys" ] && source "$HOME/.hermes_keys" 2>/dev/null
  if [ -f "$HOME/.hermes/.keys" ]; then
    while IFS='=' read -r key val; do
      [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
      val="${val%\"}" ; val="${val#\"}" ; val="${val%\'}" ; val="${val#\'}"
      [ -z "${!key:-}" ] && export "$key=$val"
    done < "$HOME/.hermes/.keys"
  fi
}

# ──────────────────────────────────────────────────────────────
#  Agent Mode
# ──────────────────────────────────────────────────────────────
lsmod_agent() {
  lsmod_ensure
  lsmod_load_keys

  echo -e "${MAGENTA}${BOLD}"
  echo " ╔══════════════════════════════════════════════════════╗"
  echo " ║  🤖 lsmod — Agent Mode                              ║"
  echo " ╚══════════════════════════════════════════════════════╝"
  echo -e "${RESET}"

  local prompt="${*:-}"
  if [ -z "$prompt" ]; then
    echo -e "  ${YELLOW}Usage:${RESET} roc-ai agent <task>"
    echo -e "  ${DIM}Example: roc-ai agent 'analyze this codebase'${RESET}"
    return 0
  fi

  # Delegate to roc-agent (hermes) with agent mode
  if command -v roc-agent &>/dev/null; then
    echo -e "${CYAN}[*] Delegating to roc-agent...${RESET}"
    exec roc-agent agent "$prompt"
  else
    # Fallback: use lsmod's node CLI
    if [ -f "$LSMOD_DIR/termux/lasokamodule.js" ] && command -v node &>/dev/null; then
      cd "$LSMOD_DIR" && node termux/lasokamodule.js menu
    else
      echo -e "${RED}[✗] roc-agent tidak tersedia. Jalankan: roc-agent setup${RESET}"
      return 1
    fi
  fi
}

# ──────────────────────────────────────────────────────────────
#  Chat Mode
# ──────────────────────────────────────────────────────────────
lsmod_chat() {
  lsmod_load_keys

  echo -e "${CYAN}${BOLD}"
  echo " ╔══════════════════════════════════════════════════════╗"
  echo " ║  💬 lsmod — Chat Mode                               ║"
  echo " ╚══════════════════════════════════════════════════════╝"
  echo -e "${RESET}"

  # Delegate to roc-agent chat
  if command -v roc-agent &>/dev/null; then
    exec roc-agent chat "${@:-}"
  else
    echo -e "${RED}[✗] roc-agent tidak tersedia. Jalankan: roc-agent setup${RESET}"
    return 1
  fi
}

# ──────────────────────────────────────────────────────────────
#  Coding Mode
# ──────────────────────────────────────────────────────────────
lsmod_coding() {
  lsmod_load_keys

  echo -e "${GREEN}${BOLD}"
  echo " ╔══════════════════════════════════════════════════════╗"
  echo " ║  💻 lsmod — Coding Mode                             ║"
  echo " ╚══════════════════════════════════════════════════════╝"
  echo -e "${RESET}"

  local task="${*:-}"
  if [ -z "$task" ]; then
    echo -e "  ${YELLOW}Usage:${RESET} roc-ai code <task>"
    echo -e "  ${DIM}Example: roc-ai code 'write a python web scraper'${RESET}"
    return 0
  fi

  if command -v roc-agent &>/dev/null; then
    exec roc-agent code "$task"
  else
    echo -e "${RED}[✗] roc-agent tidak tersedia. Jalankan: roc-agent setup${RESET}"
    return 1
  fi
}

# ──────────────────────────────────────────────────────────────
#  Error Handler
# ──────────────────────────────────────────────────────────────
lsmod_error() {
  lsmod_load_keys

  echo -e "${RED}${BOLD}"
  echo " ╔══════════════════════════════════════════════════════╗"
  echo " ║  🐛 lsmod — Error Handler                           ║"
  echo " ╚══════════════════════════════════════════════════════╝"
  echo -e "${RESET}"

  local error_msg="${*:-}"
  if [ -z "$error_msg" ]; then
    echo -e "  ${YELLOW}Usage:${RESET} roc-ai error <error_message>"
    echo -e "  ${DIM}Example: roc-ai error 'ModuleNotFoundError: No module named flask'${RESET}"
    return 0
  fi

  if command -v roc-agent &>/dev/null; then
    exec roc-agent ask "Fix this error: $error_msg"
  else
    echo -e "${RED}[✗] roc-agent tidak tersedia. Jalankan: roc-agent setup${RESET}"
    return 1
  fi
}

# ──────────────────────────────────────────────────────────────
#  Status
# ──────────────────────────────────────────────────────────────
lsmod_status() {
  echo -e "${CYAN}${BOLD}lsmod Module Status:${RESET}\n"

  # Repo
  if [ -d "$LSMOD_DIR/.git" ]; then
    local ver=$(git -C "$LSMOD_DIR" describe --tags --always 2>/dev/null || git -C "$LSMOD_DIR" rev-parse --short HEAD 2>/dev/null)
    echo -e "  ${BOLD}Repo:${RESET}    ${GREEN}✓ installed${RESET}  ${DIM}($ver)${RESET}"
  else
    echo -e "  ${BOLD}Repo:${RESET}    ${RED}✗ not cloned${RESET}  ${DIM}(run: roc-ai install)${RESET}"
  fi

  # Modes
  local modes_ok=0
  if command -v roc-agent &>/dev/null; then
    echo -e "  ${BOLD}Agent:${RESET}   ${GREEN}✓ roc-agent available${RESET}"
    echo -e "  ${BOLD}Chat:${RESET}    ${GREEN}✓ roc-agent available${RESET}"
    echo -e "  ${BOLD}Coding:${RESET}  ${GREEN}✓ roc-agent available${RESET}"
    echo -e "  ${BOLD}Error:${RESET}   ${GREEN}✓ roc-agent available${RESET}"
    modes_ok=1
  else
    echo -e "  ${BOLD}Agent:${RESET}   ${YELLOW}⚠ roc-agent not found${RESET}"
    echo -e "  ${BOLD}Chat:${RESET}    ${YELLOW}⚠ roc-agent not found${RESET}"
    echo -e "  ${BOLD}Coding:${RESET}  ${YELLOW}⚠ roc-agent not found${RESET}"
    echo -e "  ${BOLD}Error:${RESET}   ${YELLOW}⚠ roc-agent not found${RESET}"
  fi

  # Node.js (lsmod native)
  if command -v node &>/dev/null; then
    echo -e "  ${BOLD}Node.js:${RESET} ${GREEN}✓ $(node --version)${RESET}  ${DIM}(lsmod native)${RESET}"
  else
    echo -e "  ${BOLD}Node.js:${RESET} ${YELLOW}— not installed${RESET}"
  fi

  # API Keys
  lsmod_load_keys
  local keys_ok=0
  for k in GROQ_KEY OPENAI_KEY OR_KEY GEMINI_API_KEY; do
    if [ -n "${!k:-}" ]; then
      keys_ok=$((keys_ok + 1))
    fi
  done
  if [ "$keys_ok" -gt 0 ]; then
    echo -e "  ${BOLD}API Keys:${RESET} ${GREEN}✓ $keys_ok configured${RESET}"
  else
    echo -e "  ${BOLD}API Keys:${RESET} ${RED}✗ none configured${RESET}  ${DIM}(run: roc-agent setup)${RESET}"
  fi
}

# ──────────────────────────────────────────────────────────────
#  Install / Setup
# ──────────────────────────────────────────────────────────────
lsmod_install() {
  lsmod_ensure

  echo -e "${YELLOW}[*] Setting up lsmod module system...${RESET}"

  # Termux deps
  if [ -d /data/data/com.termux ]; then
    echo -e "${DIM}[*] Installing Termux dependencies...${RESET}"
    pkg install -y nodejs p7zip 2>/dev/null || true
  fi

  # Make scripts executable
  [ -f "$LSMOD_DIR/termux/lasokamodule.js" ] && chmod +x "$LSMOD_DIR/termux/lasokamodule.js"
  [ -f "$LSMOD_DIR/termux/setup.sh" ] && chmod +x "$LSMOD_DIR/termux/setup.sh"
  [ -f "$LSMOD_DIR/termux/install.sh" ] && chmod +x "$LSMOD_DIR/termux/install.sh"

  # Remove hardcoded keys from config/keys.json (security)
  if [ -f "$LSMOD_DIR/config/keys.json" ]; then
    echo -e "${YELLOW}[*] Sanitizing hardcoded keys...${RESET}"
    echo '{}' > "$LSMOD_DIR/config/keys.json"
    echo -e "${GREEN}[✓] Hardcoded keys removed${RESET}"
  fi

  # Install lasokamodule command
  if [ -f "$LSMOD_DIR/termux/lasokamodule.js" ] && command -v node &>/dev/null; then
    local bin_dir="${PREFIX:-$HOME/.local}/bin"
    cp "$LSMOD_DIR/termux/lasokamodule.js" "$bin_dir/lasokamodule" 2>/dev/null || true
    chmod +x "$bin_dir/lasokamodule" 2>/dev/null || true
    echo -e "${GREEN}[✓] lasokamodule command installed${RESET}"
  fi

  echo -e "${GREEN}[✓] lsmod module system ready${RESET}"
}

# ──────────────────────────────────────────────────────────────
#  lsmod native (lasokamodule)
# ──────────────────────────────────────────────────────────────
lsmod_native() {
  lsmod_ensure
  if [ -f "$LSMOD_DIR/termux/lasokamodule.js" ] && command -v node &>/dev/null; then
    cd "$LSMOD_DIR" && exec node termux/lasokamodule.js "$@"
  else
    echo -e "${RED}[✗] lsmod native membutuhkan Node.js${RESET}"
    echo -e "  ${CYAN}pkg install nodejs${RESET}"
    return 1
  fi
}

# ──────────────────────────────────────────────────────────────
#  Main
# ──────────────────────────────────────────────────────────────
lsmod_main() {
  local cmd="${1:-}"
  shift 2>/dev/null || true

  if [ -z "$cmd" ]; then
    echo -e "${MAGENTA}${BOLD}"
    echo " ╔══════════════════════════════════════════════════════╗"
    echo " ║  lsmod — Module System for roc-ai                   ║"
    echo " ║  ivansslo/lsmod                                     ║"
    echo " ╚══════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e " ${BOLD}Modes:${RESET}"
    echo -e "  ${CYAN}roc-ai agent <task>${RESET}  🤖 Agent Mode"
    echo -e "  ${CYAN}roc-ai chat${RESET}         💬 Chat Mode (interactive)"
    echo -e "  ${CYAN}roc-ai code <task>${RESET>  💻 Coding Mode"
    echo -e "  ${CYAN}roc-ai error <msg>${RESET}  🐛 Error Handler"
    echo ""
    echo -e " ${BOLD}Management:${RESET}"
    echo -e "  ${CYAN}roc-ai install${RESET}    Install lsmod + dependencies"
    echo -e "  ${CYAN}roc-ai status${RESET}     Check module & service status"
    echo -e "  ${CYAN}roc-ai native${RESET}     Run lasokamodule native CLI"
    echo -e "  ${CYAN}roc-ai update${RESET}     Update lsmod to latest"
    echo ""
    echo -e " ${DIM}Repo: ivansslo/lsmod${RESET}"
    echo -e " ${DIM}Path: $LSMOD_DIR${RESET}"
    return 0
  fi

  case "$cmd" in
    agent|a)
      lsmod_agent "$@"
      ;;
    chat|c)
      lsmod_chat "$@"
      ;;
    code|coding|co)
      lsmod_coding "$@"
      ;;
    error|err|e|fix)
      lsmod_error "$@"
      ;;
    install|setup|i)
      lsmod_install
      ;;
    status|st|ps)
      lsmod_status
      ;;
    native|lsmod|l)
      lsmod_native "$@"
      ;;
    update|up|pull)
      if [ -d "$LSMOD_DIR/.git" ]; then
        echo -e "${YELLOW}[*] Updating lsmod...${RESET}"
        git -C "$LSMOD_DIR" pull --ff-only 2>/dev/null || true
        # Re-sanitize keys
        [ -f "$LSMOD_DIR/config/keys.json" ] && echo '{}' > "$LSMOD_DIR/config/keys.json"
        echo -e "${GREEN}[✓] Updated${RESET}"
      else
        lsmod_ensure
      fi
      ;;
    *)
      echo -e "${RED}Unknown command: $cmd${RESET}"
      echo -e "Run ${CYAN}roc-ai${RESET} for usage"
      ;;
  esac
}

lsmod_main "$@"
