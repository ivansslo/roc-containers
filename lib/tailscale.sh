#!/data/data/com.termux/files/usr/bin/bash
# ─────────────────────────────────────────────────────────────────
#  Created by: ivansslo (2026)
#  License: MIT
#  Repo: https://github.com/ivansslo/isdocker
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/source.env"

STATE_DIR="$HOME/.tailscale_state"
mkdir -p "$STATE_DIR"

check_package() {
    if ! command -v tailscale &>/dev/null; then
        echo -e "${YELLOW}[*] Tailscale not found. Installing via pkg...${RESET}"
        pkg update -y && pkg install tailscale -y
        echo -e "${GREEN}[✓] Tailscale installed successfully.${RESET}"
    fi
}

start_daemon() {
    if ! pgrep tailscaled >/dev/null; then
        echo -e "${YELLOW}[*] Starting tailscaled in userspace mode...${RESET}"
        # Termux requires --tun=userspace-networking because we don't have /dev/net/tun access
        tailscaled --tun=userspace-networking --statedir="$STATE_DIR" &>/dev/null &
        sleep 5
        if pgrep tailscaled >/dev/null; then
            echo -e "${GREEN}[✓] Daemon started.${RESET}"
        else
            echo -e "${RED}[!] Failed to start daemon. Check Termux permissions.${RESET}"
            return 1
        fi
    fi
    return 0
}

tailscale_menu() {
    clear
    echo -e "${BLUE}${BOLD}  ╔══════════════════════════════════════════════════════╗"
    echo "  ║          isdocker · Tailscale for Termux             ║"
    echo -e "  ╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""

    # Check status
    local ts_ip=$(tailscale ip -4 2>/dev/null)
    if [ -n "$ts_ip" ]; then
        echo -e "  Status: ${GREEN}Connected${RESET} | IP: ${BOLD}$ts_ip${RESET}"
    else
        echo -e "  Status: ${RED}Disconnected / Offline${RESET}"
    fi
    echo ""

    echo -e "  ${CYAN}[1] Login with Auth Key (Token)"
    echo -e "  [2] Login via Web (Standard)"
    echo -e "  [3] Show Network Status"
    echo -e "  [4] Disconnect / Logout"
    echo -e "  [5] Restart Tailscale Daemon"
    echo -e "  [6] Uninstall Tailscale"
    echo -e "  [0] Back to Main Menu${RESET}"
    echo ""
    echo -en "  Select: "
    read -r choice

    case "$choice" in
        1)
            echo -en "\n  Enter Tailscale Auth Key: "
            read -r ts_key
            if [ -n "$ts_key" ]; then
                echo -e "  ${YELLOW}[*] Authenticating...${RESET}"
                tailscale up --authkey="$ts_key" --hostname="isdocker-termux" --accept-dns=false
            else
                echo -e "  ${RED}[!] Auth key is required.${RESET}"
            fi
            ;;
        2)
            echo -e "  ${YELLOW}[*] Follow the link to login:${RESET}"
            tailscale up --hostname="isdocker-termux" --accept-dns=false
            ;;
        3)
            echo -e "\n${GREEN}── Network List ──${RESET}"
            tailscale status
            ;;
        4)
            tailscale logout
            echo -e "\n${YELLOW}[*] Logged out.${RESET}"
            ;;
        5)
            echo -e "${YELLOW}[*] Restarting daemon...${RESET}"
            pkill tailscaled
            sleep 2
            start_daemon
            ;;
        6)
            echo -en "${RED}  Are you sure you want to uninstall Tailscale? [y/N]: ${RESET}"
            read -r confirm
            if [[ "${confirm,,}" == "y" ]]; then
                pkill tailscaled
                pkg uninstall tailscale -y
                rm -rf "$STATE_DIR"
                echo -e "${GREEN}[✓] Tailscale removed.${RESET}"
                sleep 2
                return
            fi
            ;;
        0) return ;;
        *) echo "Invalid option." ;;
    esac
    echo -e "\n${DIM}Press Enter to continue...${RESET}"
    read -r
    tailscale_menu
}

# Main Execution
check_package
start_daemon && tailscale_menu
