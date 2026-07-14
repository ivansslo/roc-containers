# 🌐 Remote Development Setup Guide

Alternatif gratis & aman untuk RDP/remote server development.

---

## 1. GitHub Codespaces ⭐ RECOMMENDED

**Gratis:** 120 core-hours/bulan (untuk akun GitHub personal)  
**RAM:** 4GB - 32GB (pilih saat create)  
**Storage:** 32GB persistent  
**Akses:** Browser + VS Code + Terminal full

### Cara Setup:
1. Buka https://github.com/codespaces
2. Klik **"New codespace"**
3. Pilih repo `ivansslo/roc-containers`
4. Pilih branch `main`
5. Pilih machine type (2-core gratis, 4-core/8-core lebih cepat tapi makan quota)
6. Tunggu ~2 menit, langsung ada terminal!

### Devcontainer sudah dikonfigurasi:
- ✅ ShellCheck + ShellFormat
- ✅ PostgreSQL client
- ✅ GitHub CLI (`gh`)
- ✅ Custom aliases (`roc`, `hermes`, `ai-chat`, dll.)
- ✅ Port forwarding (8080, 3000, 5432)

### Akses dari HP (Termux):
```bash
# Install GitHub CLI di Termux
pkg install gh

# Login
gh auth login

# SSH ke Codespace
gh codespace list
gh codespace ssh -c <codespace-name>

# Atau port-forward
gh codespace port-forward -c <codespace-name> 8080:8080
```

---

## 2. Google Cloud Shell

**Gratis:** Selamanya  
**RAM:** 8GB  
**Storage:** 5GB persistent (home directory)  
**Akses:** Browser terminal + Web Preview

### Cara Setup:
1. Buka https://shell.cloud.google.com
2. Login dengan Google account
3. Langsung ada terminal!

### Setup roc-containers:
```bash
git clone https://github.com/ivansslo/roc-containers.git
cd roc-containers
chmod +x setup.sh && bash setup.sh --cloud-shell
```

### Kelebihan:
- ✅ gcloud CLI pre-installed
- ✅ 8GB RAM (lebih besar dari Codespaces free)
- ✅ Web preview (buka port 8080 dari browser)
- ✅ Tidak ada quota jam

### Kekurangan:
- ❌ Session disconnect setiap 5 jam idle
- ❌ Tidak bisa custom image
- ❌ Kadang lambat saat peak

---

## 3. Oracle Cloud Free Tier 🖥️

**Gratis:** Selamanya (Always Free)  
**VM:** 2x ARM Ampere A1 (24GB RAM total) atau 2x x86 (1GB RAM)  
**Storage:** 200GB block volume  
**OS:** Ubuntu, Oracle Linux, dll.

### Cara Setup:
1. Buka https://cloud.oracle.com/free
2. Daftar dengan kartu kredit (tidak akan ditarik)
3. Create Compute Instance → VM.Standard.A1.Flex (ARM)
4. Set 4 OCPU + 24GB RAM (max free)
5. Pilih Ubuntu 22.04
6. Download SSH key, connect via SSH

### Setelah dapat VM:
```bash
# SSH ke server
ssh -i ~/ssh-key ubuntu@<public-ip>

# Setup
sudo apt update && sudo apt install -y curl wget jq git
git clone https://github.com/ivansslo/roc-containers.git
cd roc-containers && bash setup.sh

# Optional: Install desktop environment (RDP)
sudo apt install -y xfce4 xfce4-goodies xrdp
sudo systemctl enable xrdp
sudo systemctl start xrdp
# Connect via RDP client → <public-ip>:3389
```

### ⚠️ Catatan:
- Registrasi bisa lama (manual review, kadang ditolak)
- ARM VM lebih powerful tapi beberapa software tidak kompatibel
- Selalu gunakan Always Free resources saja

---

## 4. Gitpod

**Gratis:** 50 jam/bulan  
**RAM:** 8GB  
**Storage:** 30GB workspace

### Cara Setup:
1. Buka https://gitpod.io
2. Login dengan GitHub
3. Buka `https://gitpod.io/#https://github.com/ivansslo/roc-containers`
4. Otomatis baca `.devcontainer/` config

---

## 5. Aiven PostgreSQL Remote Access

Kamu sudah punya 2 PostgreSQL server di Aiven. Bisa diakses dari manapun:

```bash
# Primary (Jakarta)
source ~/.config/hermes/solace.env && psql "$AIVEN_PG_URI"

# Secondary (Africa)
source ~/.config/hermes/solace.env && psql "$AIVEN_PG2_URI"
```

---

## 📊 Perbandingan

| Provider | RAM | Jam Gratis | Desktop GUI | SSH | Terminal |
|----------|-----|-----------|-------------|-----|----------|
| GitHub Codespaces | 4-32GB | 120 jam/bln | ❌ | ✅ | ✅ |
| Google Cloud Shell | 8GB | Unlimited | ❌ | ✅ | ✅ |
| Oracle Cloud Free | 24GB ARM | Unlimited | ✅ (xfce+xrdp) | ✅ | ✅ |
| Gitpod | 8GB | 50 jam/bln | ❌ | ✅ | ✅ |
| MyHostingLive | ??? | ??? | ⚠️ SCAM | ⚠️ | ⚠️ |

---

## 🚀 Rekomendasi

1. **Hari ini:** Pakai **GitHub Codespaces** — paling cepat, langsung jalan
2. **Jangka panjang:** Daftar **Oracle Cloud Free Tier** — dapat VM ARM 24GB RAM selamanya + bisa RDP
3. **Quick task:** **Google Cloud Shell** — tanpa setup, langsung terminal

---

## 📱 Termux Quick Access

Untuk akses dari HP, install ini di Termux:

```bash
# GitHub CLI
pkg install gh && gh auth login

# Quick connect ke Codespace
gh codespace ssh -c $(gh codespace list -q '.[0].name')

# Quick connect ke Oracle VM
pkg install openssh
ssh -i ~/.ssh/id_rsa ubuntu@<oracle-ip>

# Quick database query
pip install pgcli
source ~/.config/hermes/solace.env && pgcli "$AIVEN_PG_URI"
```
