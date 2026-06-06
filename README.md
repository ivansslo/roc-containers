# isdocker · Termux Container Manager

Menjalankan Docker images di **Termux** tanpa root dan tanpa QEMU, menggunakan [udocker](https://github.com/indigo-dc/udocker).

> Thanks to [@IntinteDAO](https://github.com/termux/termux-packages/pull/24699) — udocker tersedia resmi di Termux APT Repo.

---

## 📁 Struktur Folder

```
isdocker/
├── menu.sh                  ← Script menu interaktif (MULAI DI SINI)
├── install_udocker.sh       ← Install / update udocker
├── lib/
│   ├── source.env           ← Shared helpers & env vars
│   └── libnetstub.sh        ← Network stub untuk Termux
├── os/
│   ├── nethunter/
│   │   └── nethunter.sh     ← Kali NetHunter (full pentest tools)
│   ├── kali/
│   │   └── kali.sh          ← Kali Linux minimal
│   ├── ubuntu/
│   │   └── ubuntu.sh        ← Ubuntu 22.04 LTS
│   ├── debian/
│   │   └── debian.sh        ← Debian 12 Bookworm
│   └── alpine/
│       └── alpine.sh        ← Alpine Linux
├── apps/
│   ├── adguard/             ← AdGuard Home          (port 8123)
│   ├── home-assistant/      ← Home Assistant         (port 8123)
│   ├── nextcloud/           ← Nextcloud              (port 2080)
│   ├── owncloud/            ← ownCloud               (port 2081)
│   ├── puter/               ← Puter cloud OS         (port 4100)
│   ├── jellyfin/            ← Jellyfin Media Server  (port 8096)
│   ├── calibre-web/         ← Calibre-Web eBooks     (port 8083)
│   ├── s-pdf/               ← Stirling PDF           (port 8080)
│   ├── httpd/               ← Apache HTTPD           (port 2082)
│   ├── jupyter/             ← JupyterLab             (port 8888)
│   ├── redis/               ← Redis                  (port 6379)
│   └── ros/                 ← ROS 2 Jazzy
└── dist/
```

---

## 🚀 Instalasi

Di Termux:
```bash
pkg install git -y
git clone --depth 1 https://github.com/ivansslo/isdocker ~/.isdocker
bash ~/.isdocker/install_udocker.sh
```

---

## 🎛️ Gunakan Menu Interaktif

```bash
bash ~/.isdocker/menu.sh
```

Menu akan menampilkan semua pilihan OS dan Aplikasi. Tekan nomor pilihan, lalu konfirmasi port (atau Enter untuk default).

---

## 🔒 OS / Distribusi Linux

### Kali NetHunter (SSH)
```bash
bash ~/.isdocker/os/nethunter/nethunter.sh
```
- **SSH:** `ssh root@localhost -p 2222` · Password: `nethunter`
- Tools: nmap, metasploit, aircrack-ng, hydra, john, sqlmap, nikto, wifite, hashcat, dll.
- VNC port: `5900`

### Kali Linux (minimal)
```bash
bash ~/.isdocker/os/kali/kali.sh
```
SSH → port `2222`, password: `kali`

### Ubuntu 22.04 LTS
```bash
bash ~/.isdocker/os/ubuntu/ubuntu.sh
```
SSH → port `2223`, password: `ubuntu`

### Debian 12 Bookworm
```bash
bash ~/.isdocker/os/debian/debian.sh
```
SSH → port `2224`, password: `debian`

### Alpine Linux
```bash
bash ~/.isdocker/os/alpine/alpine.sh
```
SSH → port `2225`, password: `alpine`

---

## 📦 Aplikasi

| Aplikasi | Script | Default Port | URL |
|---|---|---|---|
| AdGuard Home | `apps/adguard/adguard.sh` | 8123 | http://localhost:8123 |
| Home Assistant | `apps/home-assistant/home-assistant.sh` | 8123 | http://localhost:8123 |
| Nextcloud | `apps/nextcloud/nextcloud.sh` | 2080 | http://localhost:2080 |
| ownCloud | `apps/owncloud/owncloud.sh` | 2081 | http://localhost:2081 |
| Puter | `apps/puter/puter.sh` | 4100 | http://puter.localhost:4100 |
| Jellyfin | `apps/jellyfin/jellyfin.sh` | 8096 | http://localhost:8096 |
| Calibre-Web | `apps/calibre-web/calibre-web.sh` | 8083 | http://localhost:8083 |
| Stirling PDF | `apps/s-pdf/s-pdf.sh` | 8080 | http://localhost:8080 |
| Apache HTTPD | `apps/httpd/httpd.sh` | 2082 | http://localhost:2082 |
| JupyterLab | `apps/jupyter/jupyter.sh` | 8888 | http://localhost:8888 |
| Redis | `apps/redis/redis.sh` | 6379 | — |
| ROS 2 Jazzy | `apps/ros/ros.sh` | — | — |

> **Calibre-Web default login:** `admin` / `admin123`

---

## ⚙️ Kustomisasi

### Ganti Port
```bash
PORT=9090 bash ~/.isdocker/apps/s-pdf/s-pdf.sh
PORT=3333 bash ~/.isdocker/os/nethunter/nethunter.sh
```

### Jalankan Perintah Kustom
```bash
bash ~/.isdocker/apps/s-pdf/s-pdf.sh 'echo hello; ls /'
```

---

## 🛠️ Tips Udocker

```bash
# List container
udocker ps

# Hapus container
udocker rm "container_name"

# List images
udocker images

# Hapus image
udocker rmi "image_name"

# Update repo
cd ~/.isdocker && git pull
```

---

## 🔗 Link

- [Termux F-Droid](https://f-droid.org/en/packages/com.termux/)
- [udocker GitHub](https://github.com/indigo-dc/udocker)
