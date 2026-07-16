#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  Created by: ivansslo (2026)
#  License: MIT
#  Repo: https://github.com/ivansslo/roc-containers
# ─────────────────────────────────────────────────────────────────
#  roc-containers · Hermes Agent (hms) — WRAPPER
#
#  Launcher resmi ada di apps/hermes-agent/hermes-agent.sh (engine
#  ter-bundle di apps/hermes-agent/engine — tidak butuh clone).
#  Versi hms.sh lama rusak: mencoba `git clone` ke dir sendiri yang
#  sudah berisi file (selalu gagal) dan mengacu engine di path salah.
#  Wrapper ini menjaga command `roc-hms` & menu [05] tetap jalan.
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../../lib/source.env" 2>/dev/null || true

# Colors
: "${RED:=$'\033[0;31m'}"; : "${GREEN:=$'\033[0;32m'}"; : "${YELLOW:=$'\033[1;33m'}"
: "${CYAN:=$'\033[0;36m'}"; : "${BOLD:=$'\033[1m'}"; : "${DIM:=$'\033[2m'}"; : "${RESET:=$'\033[0m'}"

LAUNCHER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../hermes-agent/hermes-agent.sh"

if [ -f "$LAUNCHER" ]; then
    exec bash "$LAUNCHER" "$@"
fi

# Fallback ekstrem: launcher hilang → coba repo upstream ke subdir terpisah
UPSTREAM="$HOME/.roc-containers/apps/hermes-agent"
if [ ! -f "$UPSTREAM/hermes-agent.sh" ]; then
    echo -e "${YELLOW}[hms] Launcher lokal tidak ditemukan — mencoba clone ivansslo/hermes-agent...${RESET}"
    TMP_CLONE="$HOME/.roc-containers/apps/hms/upstream"
    git clone --depth 1 https://github.com/ivansslo/hermes-agent "$TMP_CLONE" 2>/dev/null || {
        echo -e "${RED}[hms] ✗ Gagal menyiapkan hermes-agent (clone gagal / repo privat).${RESET}"
        echo -e "  ${DIM}Pastikan repo roc-containers utuh: jalankan roc-update${RESET}"
        exit 1
    }
    [ -f "$TMP_CLONE/hermes-agent.sh" ] && exec bash "$TMP_CLONE/hermes-agent.sh" "$@"
fi

echo -e "${RED}[hms] ✗ hermes-agent tidak ditemukan.${RESET}"
exit 1
