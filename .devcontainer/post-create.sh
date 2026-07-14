# GitHub Codespace Post-Setup Script
# Runs automatically after Codespace is created

#!/bin/bash
set -e

echo "🚀 Setting up roc-containers Codespace..."

# Basic tools
sudo apt-get update -qq
sudo apt-get install -y -qq curl wget jq postgresql-client netcat-openbsd 2>/dev/null || true

# Install GitHub CLI (if not present)
if ! command -v gh &>/dev/null; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null || true
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null 2>/dev/null || true
  sudo apt-get update -qq && sudo apt-get install -y -qq gh 2>/dev/null || true
fi

# Create hermes config directory
mkdir -p ~/.config/hermes

# Setup aliases
cat >> ~/.bashrc << 'BASHRC'

# === roc-containers aliases ===
alias roc='cd /workspaces/roc-containers && bash menu.sh'
alias hermes='/workspaces/roc-containers/apps/roc-agent/hermes'
alias ai-chat='cd /workspaces/roc-containers/apps/ai && bash ai.sh chat'
alias ai-ask='cd /workspaces/roc-containers/apps/ai && bash ai.sh ask'
alias ai-code='cd /workspaces/roc-containers/apps/ai && bash ai.sh code'
alias aiven-uri='source ~/.config/hermes/solace.env 2>/dev/null && echo $AIVEN_PG_URI'
alias solace-pub='source ~/.config/hermes/solace.env 2>/dev/null && bash /workspaces/roc-containers/lib/lsmod_loader.sh solace_publish'
alias roc-status='echo "=== Codespace Status ===" && echo "Disk: $(df -h / | tail -1 | awk "{print \$3}/\$2")" && echo "RAM: $(free -h | grep Mem | awk "{print \$3}/\$2")" && echo "CPU: $(nproc) cores" && uptime'
BASHRC

echo "✅ Codespace setup complete!"
echo "Run 'roc' for interactive menu, 'roc-status' for system info"
