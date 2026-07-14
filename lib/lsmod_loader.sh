#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  Created by: ivansslo (2026)
#  License: MIT
#  Repo: https://github.com/ivansslo/roc-containers
# ─────────────────────────────────────────────────────────────────
#  lsmod Loader — Shared Module System
#
#  Source file ini dari SEMUA roc-* script untuk akses lsmod:
#    source "$(dirname "${BASH_SOURCE[0]}")/../lib/lsmod_loader.sh"
#    atau
#    source "$HOME/.roc-containers/lib/lsmod_loader.sh"
#
#  Menyediakan:
#    - lsmod_agent <task>     → delegasi ke AI agent
#    - lsmod_chat             → interactive chat
#    - lsmod_code <task>      → coding assistant
#    - lsmod_error <msg>      → error handler / fix
#    - lsmod_load_keys        → load API keys dari env
#    - lsmod_propagate <app>  → inject lsmod ke container app
#    - lsmod_status           → cek module status
# ─────────────────────────────────────────────────────────────────

LSMOD_LOADER_VERSION="1.0.0"
LSMOD_DIR="$HOME/.roc-containers/apps/ai/modules/lsmod"
LSMOD_SH="$HOME/.roc-containers/apps/ai/lsmod.sh"
ROC_DIR="$HOME/.roc-containers"

# Solace connection (auto-load)
[ -f "$HOME/.config/hermes/solace.env" ] && source "$HOME/.config/hermes/solace.env" 2>/dev/null

# ──────────────────────────────────────────────────────────────
#  Colors (safe fallback)
# ──────────────────────────────────────────────────────────────
: "${RED:=$'\033[0;31m'}"; : "${GREEN:=$'\033[0;32m'}"; : "${YELLOW:=$'\033[1;33m'}"
: "${CYAN:=$'\033[0;36m'}"; : "${BLUE:=$'\033[0;34m'}"; : "${MAGENTA:=$'\033[0;35m'}"
: "${BOLD:=$'\033[1m'}"; : "${DIM:=$'\033[2m'}"; : "${RESET:=$'\033[0m'}"

# ──────────────────────────────────────────────────────────────
#  lsmod Ensure — clone jika belum ada
# ──────────────────────────────────────────────────────────────
lsmod_ensure() {
  if [ ! -d "$LSMOD_DIR/.git" ]; then
    echo -e "${YELLOW}[lsmod] Cloning module system...${RESET}"
    GIT_TERMINAL_PROMPT=0 git clone --depth 1 https://github.com/ivansslo/lsmod "$LSMOD_DIR" 2>/dev/null
    if [ $? -ne 0 ]; then
      echo -e "${RED}[lsmod] Gagal clone. Cek koneksi internet.${RESET}"
      return 1
    fi
    # Sanitize hardcoded keys
    [ -f "$LSMOD_DIR/config/keys.json" ] && echo '{}' > "$LSMOD_DIR/config/keys.json"
    echo -e "${GREEN}[lsmod] Module system ready${RESET}"
  fi
}

# ──────────────────────────────────────────────────────────────
#  Load API Keys — dari ~/.hermes_keys + ~/.hermes/.keys
# ──────────────────────────────────────────────────────────────
lsmod_load_keys() {
  [ -f "$HOME/.hermes_keys" ] && source "$HOME/.hermes_keys" 2>/dev/null
  if [ -f "$HOME/.hermes/.keys" ]; then
    while IFS='=' read -r key val; do
      [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
      # Skip invalid variable names (e.g. ₣IREBASE_API_KEY with Unicode chars)
      [[ ! "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] && continue
      val="${val%\"}" ; val="${val#\"}" ; val="${val%\'}" ; val="${val#\'}"
      [ -z "${!key:-}" ] && export "$key=$val"
    done < "$HOME/.hermes/.keys"
  fi
}

# ──────────────────────────────────────────────────────────────
#  lsmod Agent Mode — delegasi tugas ke AI agent
# ──────────────────────────────────────────────────────────────
lsmod_agent() {
  lsmod_load_keys
  local task="${*:-}"
  if [ -z "$task" ]; then
    echo -e "${YELLOW}[lsmod] Usage: lsmod_agent <task>${RESET}"
    return 1
  fi
  if command -v roc-agent &>/dev/null; then
    exec roc-agent agent "$task"
  else
    echo -e "${RED}[lsmod] roc-agent tidak tersedia. Jalankan: roc-agent setup${RESET}"
    return 1
  fi
}

# ──────────────────────────────────────────────────────────────
#  lsmod Chat Mode — interactive chat
# ──────────────────────────────────────────────────────────────
lsmod_chat() {
  lsmod_load_keys
  if command -v roc-agent &>/dev/null; then
    exec roc-agent chat "${@:-}"
  else
    echo -e "${RED}[lsmod] roc-agent tidak tersedia. Jalankan: roc-agent setup${RESET}"
    return 1
  fi
}

# ──────────────────────────────────────────────────────────────
#  lsmod Coding Mode — AI coding assistant
# ──────────────────────────────────────────────────────────────
lsmod_code() {
  lsmod_load_keys
  local task="${*:-}"
  if [ -z "$task" ]; then
    echo -e "${YELLOW}[lsmod] Usage: lsmod_code <task>${RESET}"
    return 1
  fi
  if command -v roc-agent &>/dev/null; then
    exec roc-agent code "$task"
  else
    echo -e "${RED}[lsmod] roc-agent tidak tersedia. Jalankan: roc-agent setup${RESET}"
    return 1
  fi
}

# ──────────────────────────────────────────────────────────────
#  lsmod Error Handler — analisis & fix error
# ──────────────────────────────────────────────────────────────
lsmod_error() {
  lsmod_load_keys
  local msg="${*:-}"
  if [ -z "$msg" ]; then
    echo -e "${YELLOW}[lsmod] Usage: lsmod_error <error_message>${RESET}"
    return 1
  fi
  if command -v roc-agent &>/dev/null; then
    exec roc-agent ask "Fix this error: $msg"
  else
    echo -e "${RED}[lsmod] roc-agent tidak tersedia. Jalankan: roc-agent setup${RESET}"
    return 1
  fi
}

# ──────────────────────────────────────────────────────────────
#  lsmod Propagate — inject lsmod ke container app
#  Usage: lsmod_propagate <app_name> <container_name> <data_dir>
#  Contoh: lsmod_propagate "crewai" "crewai-hermes" "/path/to/data"
# ──────────────────────────────────────────────────────────────
lsmod_propagate() {
  local app_name="$1"
  local container_name="$2"
  local data_dir="$3"

  if [ -z "$app_name" ]; then
    echo -e "${YELLOW}[lsmod] Usage: lsmod_propagate <app_name> <container> <data_dir>${RESET}"
    return 1
  fi

  # Ensure lsmod exists
  lsmod_ensure || return 1

  # Copy lsmod loader into container data dir
  local target_dir="$data_dir/root/.lsmod"
  mkdir -p "$target_dir"

  # Copy loader
  cp "$ROC_DIR/lib/lsmod_loader.sh" "$target_dir/lsmod_loader.sh" 2>/dev/null || true

  # Copy lsmod termux CLI
  if [ -f "$LSMOD_DIR/termux/lasokamodule.js" ]; then
    cp "$LSMOD_DIR/termux/lasokamodule.js" "$target_dir/lasokamodule.js" 2>/dev/null || true
  fi

  # Write a simple init script for the container
  cat > "$target_dir/init.sh" << 'LSMOD_INIT'
#!/bin/bash
# lsmod Container Init — sourced by AI agent containers
LSMOD_DIR="/root/.lsmod"
[ -f "$LSMOD_DIR/lsmod_loader.sh" ] && source "$LSMOD_DIR/lsmod_loader.sh" 2>/dev/null || true

# Container-local lsmod functions
lsmod_container_agent() {
  local task="$*"
  if command -v python3 &>/dev/null && [ -f "/root/venv/bin/python" ]; then
    /root/venv/bin/python -m agent "$task"
  else
    echo "[lsmod] Agent not available in this container"
  fi
}

lsmod_container_error() {
  local msg="$*"
  echo "[lsmod] Error reported: $msg"
  # Container-local error analysis
  if command -v python3 &>/dev/null; then
    /root/venv/bin/python -c "
import traceback, sys
print('[lsmod] Error Analysis:')
print(f'  Message: {sys.argv[1] if len(sys.argv) > 1 else \"N/A\"}')
print(f'  Python: {sys.version}')
print(f'  Path: {sys.path[:3]}')
" "$msg" 2>/dev/null || echo "[lsmod] Python analysis failed"
  fi
}
LSMOD_INIT
  chmod +x "$target_dir/init.sh" 2>/dev/null || true

  echo -e "${GREEN}[lsmod] ✅ Propagated to $app_name${RESET}  ${DIM}($target_dir)${RESET}"
}

# ──────────────────────────────────────────────────────────────
#  lsmod Status — cek module status
# ──────────────────────────────────────────────────────────────
lsmod_status() {
  echo -e "${MAGENTA}${BOLD}lsmod Module System v${LSMOD_LOADER_VERSION}${RESET}\n"

  # Repo
  if [ -d "$LSMOD_DIR/.git" ]; then
    local ver=$(git -C "$LSMOD_DIR" describe --tags --always 2>/dev/null || git -C "$LSMOD_DIR" rev-parse --short HEAD 2>/dev/null)
    echo -e "  ${BOLD}Module:${RESET}  ${GREEN}✓${RESET} lsmod ${DIM}($ver)${RESET}"
  else
    echo -e "  ${BOLD}Module:${RESET}  ${RED}✗ not installed${RESET}"
  fi

  # Loader
  if [ -f "$ROC_DIR/lib/lsmod_loader.sh" ]; then
    echo -e "  ${BOLD}Loader:${RESET}  ${GREEN}✓${RESET} lsmod_loader.sh"
  else
    echo -e "  ${BOLD}Loader:${RESET}  ${RED}✗ missing${RESET}"
  fi

  # Agent availability
  if command -v roc-agent &>/dev/null; then
    echo -e "  ${BOLD}Agent:${RESET}   ${GREEN}✓${RESET} roc-agent"
    echo -e "  ${BOLD}Chat:${RESET}    ${GREEN}✓${RESET} via roc-agent"
    echo -e "  ${BOLD}Code:${RESET}    ${GREEN}✓${RESET} via roc-agent"
    echo -e "  ${BOLD}Error:${RESET}   ${GREEN}✓${RESET} via roc-agent"
  else
    echo -e "  ${BOLD}Agent:${RESET}   ${YELLOW}⚠${RESET} roc-agent not found"
  fi

  # Propagated containers
  echo -e "\n  ${BOLD}Propagated to:${RESET}"
  local found=0
  for app in "$ROC_DIR"/apps/*/; do
    local app_name=$(basename "$app")
    local data_dir="$ROC_DIR/data-*"
    # Check if any data dir has .lsmod
    for d in "$ROC_DIR"/data-*/; do
      if [ -d "$d/root/.lsmod" ]; then
        local container_name=$(basename "$d" | sed 's/data-//')
        echo -e "  ${GREEN}●${RESET} $container_name"
        found=$((found + 1))
      fi
    done
    # Also check app-specific data dirs
    if [ -d "$app/data-root/root/.lsmod" ]; then
      echo -e "  ${GREEN}●${RESET} $app_name"
      found=$((found + 1))
    fi
  done
  if [ "$found" -eq 0 ]; then
    echo -e "  ${DIM}No containers yet. Run: roc-ai install${RESET}"
  fi

  # API Keys
  lsmod_load_keys
  local keys_ok=0
  for k in GROQ_KEY OPENAI_KEY OR_KEY GEMINI_API_KEY TOKEN; do
    if [ -n "${!k:-}" ]; then
      keys_ok=$((keys_ok + 1))
    fi
  done
  echo -e "\n  ${BOLD}API Keys:${RESET} ${keys_ok} configured ${DIM}($keys_ok/5)${RESET}"
}

# ──────────────────────────────────────────────────────────────
#  lsmod Route — route task ke agent yang tepat
#  Ini fitur istimewa untuk roc-ai sebagai pewaris lsmod
# ──────────────────────────────────────────────────────────────
lsmod_route() {
  local task="$1"
  local context="${2:-auto}"

  if [ -z "$task" ]; then
    echo -e "${YELLOW}[lsmod] Usage: lsmod_route <task> [context]${RESET}"
    return 1
  fi

  # Route berdasarkan konteks
  case "$context" in
    crew|crewai)
      echo -e "${CYAN}[lsmod] → Routing to CrewAI${RESET}"
      if [ -x "$ROC_DIR/apps/crewai/crewai.sh" ]; then
        bash "$ROC_DIR/apps/crewai/crewai.sh" run "$task"
      else
        lsmod_agent "$task"
      fi
      ;;
    hms|hermes)
      echo -e "${CYAN}[lsmod] → Routing to Hermes Agent${RESET}"
      if [ -x "$ROC_DIR/apps/hms/hms.sh" ]; then
        bash "$ROC_DIR/apps/hms/hms.sh" run "$task"
      else
        lsmod_agent "$task"
      fi
      ;;
    adk|invoice)
      echo -e "${CYAN}[lsmod] → Routing to ADK Invoice${RESET}"
      if [ -x "$ROC_DIR/apps/adk-invoice/adk-invoice.sh" ]; then
        bash "$ROC_DIR/apps/adk-invoice/adk-invoice.sh" cli "$task"
      else
        lsmod_agent "$task"
      fi
      ;;
    code|coding)
      lsmod_code "$task"
      ;;
    error|fix)
      lsmod_error "$task"
      ;;
    auto|*)
      # Auto-route: gunakan roc-agent (prioritas AI-best)
      lsmod_agent "$task"
      ;;
  esac
}

# ──────────────────────────────────────────────────────────────
#  lsmod Broadcast — kirim pesan ke semua AI agents
# ──────────────────────────────────────────────────────────────
lsmod_broadcast() {
  local message="$1"

  if [ -z "$message" ]; then
    echo -e "${YELLOW}[lsmod] Usage: lsmod_broadcast <message>${RESET}"
    return 1
  fi

  echo -e "${MAGENTA}${BOLD}[lsmod] Broadcasting to all AI agents:${RESET} $message\n"

  # Agent (roc-agent)
  if command -v roc-agent &>/dev/null; then
    echo -e "  ${GREEN}●${RESET} roc-agent ${DIM}→ available${RESET}"
  else
    echo -e "  ${RED}○${RESET} roc-agent ${DIM}→ not found${RESET}"
  fi

  # CrewAI
  if [ -f "$ROC_DIR/apps/crewai/crewai.sh" ]; then
    echo -e "  ${GREEN}●${RESET} roc-crewai ${DIM}→ available${RESET}"
  else
    echo -e "  ${DIM}○${RESET} roc-crewai ${DIM}→ not installed${RESET}"
  fi

  # Hermes Agent
  if [ -f "$ROC_DIR/apps/hms/hms.sh" ]; then
    echo -e "  ${GREEN}●${RESET} roc-hms ${DIM}→ available${RESET}"
  else
    echo -e "  ${DIM}○${RESET} roc-hms ${DIM}→ not installed${RESET}"
  fi

  # ADK
  if [ -f "$ROC_DIR/apps/adk-invoice/adk-invoice.sh" ]; then
    echo -e "  ${GREEN}●${RESET} roc-adk ${DIM}→ available${RESET}"
  else
    echo -e "  ${DIM}○${RESET} roc-adk ${DIM}→ not installed${RESET}"
  fi

  # Antigravity
  if [ -f "$ROC_DIR/apps/antigravity/antigravity.sh" ]; then
    echo -e "  ${GREEN}●${RESET} roc-antigravity ${DIM}→ available${RESET}"
  else
    echo -e "  ${DIM}○${RESET} roc-antigravity ${DIM}→ not installed${RESET}"
  fi

  # MAAGBA
  if [ -f "$ROC_DIR/apps/maagba/maagba.sh" ]; then
    echo -e "  ${GREEN}●${RESET} roc-maagba ${DIM}→ available${RESET}"
  else
    echo -e "  ${DIM}○${RESET} roc-maagba ${DIM}→ not installed${RESET}"
  fi

  echo ""
}

# ──────────────────────────────────────────────────────────────
#  Auto-init: ensure lsmod loaded silently
# ──────────────────────────────────────────────────────────────
lsmod_ensure 2>/dev/null || true

# ──────────────────────────────────────────────────────────────
#  Solace PubSub+ Helper Functions
# ──────────────────────────────────────────────────────────────
solace_status() {
  curl -s "${GATEWAY:-https://hermes-cloudflare.certveis.workers.dev}/solace/status" 2>/dev/null
}

solace_queues() {
  curl -s "${GATEWAY:-https://hermes-cloudflare.certveis.workers.dev}/solace/queues" 2>/dev/null
}

solace_publish() {
  local topic="${1:?Usage: solace_publish <topic> <message>}"
  local msg="${2:?Usage: solace_publish <topic> <message>}"
  if [ -n "$SOLACE_URL" ] && [ -n "$SOLACE_USER" ] && [ -n "$SOLACE_PASS" ]; then
    curl -s -u "$SOLACE_USER:$SOLACE_PASS" \
      -X POST \
      -H "Content-Type: text/plain" \
      -H "Solace-Delivery-Mode: Direct" \
      -d "$msg" \
      "$SOLACE_URL/Topic/$topic" 2>/dev/null
  else
    echo '{"error":"Solace not configured"}'
  fi
}

solace_publish_json() {
  local topic="${1:?Usage: solace_publish_json <topic> <json>}"
  local json="${2:?Usage: solace_publish_json <topic> <json>}"
  if [ -n "$SOLACE_URL" ] && [ -n "$SOLACE_USER" ] && [ -n "$SOLACE_PASS" ]; then
    curl -s -u "$SOLACE_USER:$SOLACE_PASS" \
      -X POST \
      -H "Content-Type: application/json" \
      -H "Solace-Delivery-Mode: Persistent" \
      -d "$json" \
      "$SOLACE_URL/Topic/$topic" 2>/dev/null
  else
    echo '{"error":"Solace not configured"}'
  fi
}

solace_is_connected() {
  [ -n "$SOLACE_URL" ] && [ -n "$SOLACE_USER" ] && [ -n "$SOLACE_PASS" ]
}

# ──────────────────────────────────────────────────────────────
#  Aiven Helper Functions
# ──────────────────────────────────────────────────────────────
aiven_status() {
  [ -n "$AIVEN_TOKEN" ] && [ -n "$AIVEN_PROJECT" ] || { echo '{"error":"Aiven not configured"}'; return 1; }
  curl -s -H "Authorization: Bearer $AIVEN_TOKEN" \
    "https://api.aiven.io/v1/project/$AIVEN_PROJECT/service/${AIVEN_PG_SERVICE:-pg-roadfx}" 2>/dev/null
}

aiven_pg_uri() {
  if [ -z "$AIVEN_PG_PASS" ]; then
    echo "postgresql://avnadmin:***@${AIVEN_PG_HOST:-pg-roadfx-roadfrx-ai.e.aivencloud.com}:${AIVEN_PG_PORT:-21876}/${AIVEN_PG_DB:-defaultdb}?sslmode=require"
  else
    echo "postgresql://avnadmin:${AIVEN_PG_PASS}@${AIVEN_PG_HOST:-pg-roadfx-roadfrx-ai.e.aivencloud.com}:${AIVEN_PG_PORT:-21876}/${AIVEN_PG_DB:-defaultdb}?sslmode=require"
  fi
}

aiven_is_configured() {
  [ -n "$AIVEN_TOKEN" ] && [ -n "$AIVEN_PROJECT" ]
}
