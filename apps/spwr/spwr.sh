#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  Created by: ivansslo (2026)
#  License: MIT
#  Repo: https://github.com/ivansslo/roc-containers
# ─────────────────────────────────────────────────────────────────
#  roc-containers · Superpowers (spwr)
#  Coding agent skills & methodology
#
#  FIX v1.4.0: clone ke SUBDIR `repo/` — dulu clone langsung ke
#  dir sendiri (sudah berisi spwr.sh + .git parent) → selalu gagal.
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/source.env" 2>/dev/null || true

# Colors
: "${RED:=$'\033[0;31m'}"; : "${GREEN:=$'\033[0;32m'}"; : "${YELLOW:=$'\033[1;33m'}"
: "${CYAN:=$'\033[0;36m'}"; : "${BOLD:=$'\033[1m'}"; : "${DIM:=$'\033[2m'}"; : "${RESET:=$'\033[0m'}"

SPWR_DIR="$HOME/.roc-containers/apps/spwr"
SPWR_REPO_DIR="$SPWR_DIR/repo"                     # ← fix: subdir terpisah
SPWR_REPO="https://github.com/ivansslo/spwr"

# Clone or update spwr repo
spwr_ensure() {
  if [ ! -d "$SPWR_REPO_DIR/.git" ]; then
    echo -e "${YELLOW}[*] Cloning Superpowers...${RESET}"
    git clone --depth 1 "$SPWR_REPO" "$SPWR_REPO_DIR" 2>/dev/null
    if [ $? -ne 0 ]; then
      echo -e "${RED}[✗] Gagal clone ivansslo/spwr (repo privat / offline).${RESET}"
      return 1
    fi
  else
    echo -e "${DIM}[*] Updating Superpowers...${RESET}"
    git -C "$SPWR_REPO_DIR" pull --ff-only 2>/dev/null || true
  fi
}

# Install dependencies
spwr_install() {
  spwr_ensure || return 1
  if command -v npm &>/dev/null; then
    echo -e "${YELLOW}[*] Installing npm dependencies...${RESET}"
    [ -f "$SPWR_REPO_DIR/package.json" ] && (cd "$SPWR_REPO_DIR" && npm install --silent 2>/dev/null || true)
    echo -e "${GREEN}[✓] Superpowers installed${RESET}"
  else
    echo -e "${YELLOW}[!] npm not found. Install: pkg install nodejs${RESET}"
  fi
}

# Run skills
spwr_run() {
  local skill="${1:-}"
  if [ -z "$skill" ]; then
    echo -e "${CYAN}${BOLD}"
    echo " ╔══════════════════════════════════════════════════════╗"
    echo " ║  Superpowers — Coding Agent Skills                  ║"
    echo " ╚══════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e " ${BOLD}Usage:${RESET}"
    echo -e "  ${CYAN}roc-spwr install${RESET}    Install/update Superpowers"
    echo -e "  ${CYAN}roc-spwr skills${RESET}     List available skills"
    echo -e "  ${CYAN}roc-spwr docs${RESET}       Open documentation"
    echo -e "  ${CYAN}roc-spwr shell${RESET}      Open shell in spwr dir"
    echo ""
    return 0
  fi

  case "$skill" in
    install|setup|i)
      spwr_install
      ;;
    skills|list|ls)
      spwr_ensure || return 1
      echo -e "${BOLD}Available Skills:${RESET}\n"
      if [ -d "$SPWR_REPO_DIR/skills" ]; then
        for s in "$SPWR_REPO_DIR/skills"/*; do
          [ -d "$s" ] && echo -e "  ${GREEN}•${RESET} $(basename "$s")"
        done
      else
        echo -e "  ${DIM}(folder skills tidak ada di repo)${RESET}"
      fi
      ;;
    docs|help|h)
      spwr_ensure || return 1
      if [ -f "$SPWR_REPO_DIR/README.md" ]; then
        head -80 "$SPWR_REPO_DIR/README.md"
      fi
      ;;
    shell|sh)
      spwr_ensure || return 1
      echo -e "${DIM}Spwr dir: $SPWR_REPO_DIR${RESET}"
      cd "$SPWR_REPO_DIR" && exec bash
      ;;
    update|up)
      echo -e "${YELLOW}[*] Updating Superpowers...${RESET}"
      if [ -d "$SPWR_REPO_DIR/.git" ]; then
        git -C "$SPWR_REPO_DIR" pull --ff-only 2>/dev/null || true
      else
        spwr_ensure || return 1
      fi
      echo -e "${GREEN}[✓] Updated${RESET}"
      ;;
    *)
      echo -e "${RED}Unknown command: $skill${RESET}"
      echo -e "Run ${CYAN}roc-spwr${RESET} for usage"
      ;;
  esac
}

spwr_run "$@"
