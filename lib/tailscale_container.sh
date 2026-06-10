#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  Created by: ivansslo (2026)
#  License: MIT
#  Repo: https://github.com/ivansslo/isdocker
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/source.env"

install_in_ubuntu_debian() {
    local name="$1"
    echo -e "${YELLOW}[*] Installing Tailscale in $name (Ubuntu/Debian)...${RESET}"
    udocker run "$name" bash -c "
        apt-get update && apt-get install -y curl gpg
        curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
        curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list
        apt-get update && apt-get install -y tailscale
    "
}

install_in_alpine() {
    local name="$1"
    echo -e "${YELLOW}[*] Installing Tailscale in $name (Alpine)...${RESET}"
    udocker run "$name" sh -c "apk update && apk add tailscale"
}

start_in_container() {
    local name="$1"
    echo -e "${YELLOW}[*] Starting Tailscale inside $name...${RESET}"
    echo -e "${DIM}    Note: This will start tailscaled in userspace mode inside the container.${RESET}"
    
    # We use a non-blocking way to start the daemon if possible or just guide the user
    echo -en "\n  Enter Tailscale Auth Key (optional): "
    read -r key
    
    if [ -n "$key" ]; then
        udocker run "$name" bash -c "
            mkdir -p /var/lib/tailscale
            tailscaled --tun=userspace-networking & 
            sleep 2
            tailscale up --authkey=$key --hostname=isdocker-$name
        "
    else
        echo -e "${CYAN}[!] To start Tailscale inside, run these commands after entering the container:${RESET}"
        echo -e "    1. tailscaled --tun=userspace-networking &"
        echo -e "    2. tailscale up"
    fi
}

main_menu() {
    clear
    echo -e "${BLUE}${BOLD}  ╔══════════════════════════════════════════════════════╗"
    echo "  ║         isdocker · Tailscale in Container            ║"
    echo -e "  ╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    containers=$(udocker ps | tail -n +2)
    if [ -z "$containers" ]; then
        echo -e "  ${RED}[!] No containers found to install into.${RESET}"
        sleep 2; return
    fi

    echo -e "  ${YELLOW}Select a container to install Tailscale into:${RESET}"
    udocker ps
    echo ""
    echo -en "  Enter Container Name: "
    read -r target
    
    if [ -z "$target" ]; then return; fi

    echo -e "\n  ${CYAN}[1] Install Tailscale (Ubuntu/Debian/Kali)"
    echo -e "  [2] Install Tailscale (Alpine)"
    echo -e "  [3] Run/Setup Tailscale in Container"
    echo -e "  [0] Back${RESET}"
    echo ""
    echo -en "  Select action: "
    read -r act

    case "$act" in
        1) install_in_ubuntu_debian "$target" ;;
        2) install_in_alpine "$target" ;;
        3) start_in_container "$target" ;;
        0) return ;;
    esac
    echo -e "\n  ${DIM}Press Enter to continue...${RESET}"
    read -r
    main_menu
}

main_menu
