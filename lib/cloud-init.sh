#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════
#  roc-cloud-init · Quick setup script for Cloud VMs
#  Supports: Oracle Cloud, AWS, GCP, Hetzner, any Ubuntu/Debian
#  Usage: curl -fsSL https://raw.githubusercontent.com/ivansslo/roc-containers/main/lib/cloud-init.sh | bash
# ══════════════════════════════════════════════════════════════════

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'

echo -e "${CYAN}${BOLD}"
echo " ╔══════════════════════════════════════════════════════╗"
echo " ║  ☁️  roc-cloud-init · Cloud VM Quick Setup          ║"
echo " ╚══════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_VERSION="${VERSION_ID:-unknown}"
else
    OS_ID="unknown"
fi

echo -e "  OS: ${BOLD}${OS_ID} ${OS_VERSION}${RESET}"
echo -e "  User: ${BOLD}$(whoami)${RESET}"
echo -e "  RAM: ${BOLD}$(free -h | grep Mem | awk '{print $2}')${RESET}"
echo -e "  CPU: ${BOLD}$(nproc) cores${RESET}"
echo ""

# ─── 1. System packages ─────────────────────────────────
echo -e "${YELLOW}[1/6] Installing system packages...${RESET}"
sudo apt-get update -qq 2>/dev/null || true
sudo apt-get install -y -qq \
    git curl wget jq nano vim htop tmux \
    python3 python3-pip python3-venv \
    postgresql-client redis-tools \
    netcat-openbsd dnsutils \
    2>/dev/null || true
echo -e "  ${GREEN}✅ System packages installed${RESET}"

# ─── 2. Clone roc-containers ───────────────────────────
echo -e "\n${YELLOW}[2/6] Cloning roc-containers...${RESET}"
ROC_DIR="$HOME/roc-containers"
if [ ! -d "$ROC_DIR" ]; then
    git clone --depth 1 https://github.com/ivansslo/roc-containers "$ROC_DIR"
else
    git -C "$ROC_DIR" pull --ff-only 2>/dev/null || true
fi
echo -e "  ${GREEN}✅ roc-containers ready at $ROC_DIR${RESET}"

# ─── 3. Python venv + AI packages ──────────────────────
echo -e "\n${YELLOW}[3/6] Setting up Python venv...${RESET}"
mkdir -p "$HOME/.hermes"
if [ ! -x "$HOME/.hermes/python3_venv/bin/python" ]; then
    python3 -m venv "$HOME/.hermes/python3_venv"
    "$HOME/.hermes/python3_venv/bin/python" -m pip install -U pip \
        rich pygments prompt_toolkit requests httpx \
        openai google-generativeai psycopg2-binary \
        >/dev/null 2>&1 || true
    echo -e "  ${GREEN}✅ Python venv ready with AI packages${RESET}"
else
    echo -e "  ${GREEN}✅ Python venv already exists${RESET}"
fi

# ─── 4. Shell aliases ──────────────────────────────────
echo -e "\n${YELLOW}[4/6] Installing shell aliases...${RESET}"
grep -q "roc-containers aliases" ~/.bashrc 2>/dev/null || cat >> ~/.bashrc << 'BASHRC'

# ══════════════════════════════════════════════════════════
# roc-containers aliases
# ══════════════════════════════════════════════════════════
alias roc='cd ~/roc-containers && bash menu.sh'
alias roc-menu='bash ~/roc-containers/menu.sh'
alias roc-ai='bash ~/roc-containers/apps/ai/ai.sh'
alias roc-status='echo "=== Cloud VM Status ===" && echo "Disk: $(df -h / | tail -1 | awk "{print \$3}/\$2 used")" && echo "RAM: $(free -h | grep Mem | awk "{print \$3}/\$2 used")" && echo "CPU: $(nproc) cores" && uptime'

# Quick AI commands
alias ai-chat='bash ~/roc-containers/apps/ai/ai.sh chat'
alias ai-ask='bash ~/roc-containers/apps/ai/ai.sh ask'
alias ai-code='bash ~/roc-containers/apps/ai/ai.sh code'

# Quick DB access (set credentials in ~/.config/hermes/solace.env)
alias aiven-connect='source ~/.config/hermes/solace.env 2>/dev/null && psql "$AIVEN_PG_URI"'

# tmux session
alias roc-session='tmux new-session -d -s roc 2>/dev/null || tmux attach -t roc'
BASHRC
echo -e "  ${GREEN}✅ Aliases installed (restart shell or source ~/.bashrc)${RESET}"

# ─── 5. Optional: Desktop Environment (RDP) ────────────
echo -e "\n${YELLOW}[5/6] Desktop Environment (optional)...${RESET}"
if [ "$1" = "--with-rdp" ] || [ "$1" = "--desktop" ]; then
    echo -e "  ${CYAN}Installing XFCE + xRDP...${RESET}"
    sudo apt-get install -y -qq xfce4 xfce4-terminal dbus-x11 2>/dev/null || true
    sudo apt-get install -y -qq xrdp 2>/dev/null || true

    # Configure xRDP
    sudo sed -i 's/^testuserid/xrdp/' /etc/xrdp/xrdp.ini 2>/dev/null || true
    echo "xfce4-session" > ~/.xsession
    sudo systemctl enable xrdp 2>/dev/null || true
    sudo systemctl restart xrdp 2>/dev/null || true

    # Get IP
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")
    echo -e "  ${GREEN}✅ RDP ready!${RESET}"
    echo -e "  ${CYAN}Connect with RDP client → ${PUBLIC_IP}:3389${RESET}"
    echo -e "  ${CYAN}Username: $(whoami)${RESET}"
else
    echo -e "  ${DIM}Skip RDP. Run with --with-rdp to install desktop${RESET}"
fi

# ─── 6. Firewall & Security ────────────────────────────
echo -e "\n${YELLOW}[6/6] Security basics...${RESET}"
# Allow SSH
sudo ufw allow ssh 2>/dev/null || true
# Allow RDP if installed
if command -v xrdp &>/dev/null; then
    sudo ufw allow 3389/tcp 2>/dev/null || true
fi
sudo ufw --force enable 2>/dev/null || true
echo -e "  ${GREEN}✅ Firewall configured${RESET}"

# ══════════════════════════════════════════════════════════
echo -e "\n${CYAN}${BOLD}══════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD} ✅ Cloud VM setup complete!${RESET}\n"
echo -e " ${BOLD}Quick Start:${RESET}"
echo -e "  ${CYAN}source ~/.bashrc${RESET}          Load aliases"
echo -e "  ${CYAN}roc-menu${RESET}                   Interactive menu"
echo -e "  ${CYAN}roc-ai chat${RESET}                AI Chat"
echo -e "  ${CYAN}roc-status${RESET}                 System status"
echo ""
echo -e " ${BOLD}Install RDP Desktop:${RESET}"
echo -e "  ${CYAN}bash $ROC_DIR/lib/cloud-init.sh --with-rdp${RESET}"
echo ""
echo -e " ${BOLD}Connect from Termux:${RESET}"
echo -e "  ${CYAN}ssh $(whoami)@$(curl -s ifconfig.me 2>/dev/null || echo 'SERVER_IP')${RESET}"
