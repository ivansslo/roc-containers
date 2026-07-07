# isdocker · Termux Container Manager (2026)

Menjalankan Docker images di **Termux** tanpa root, menggunakan [udocker](https://github.com/indigo-dc/udocker) dan emulasi QEMU untuk Windows.

> **Created by: ivansslo (2026)** · **License: MIT**

---

## 🚀 Fitur Unggulan
- ✅ **Tanpa Root:** Aman dan berjalan di level user Termux.
- ✅ **Container Manager Pro:** Pantau status aktif, IP, port, dan user dari setiap container.
- ✅ **Multi-OS:** Ubuntu, Debian, Alpine, Kali, Windows 11, dan Windows 7.
- ✅ **VNC & RDP:** Akses Desktop Environment (XFCE) atau Windows dengan mudah.
- ✅ **Auto Update:** Selalu dapatkan fitur terbaru dengan script update internal.

---

## 💻 Cara Instalasi & Penggunaan

### 1. Instalasi Cepat
```bash
pkg install git -y
git clone --depth 1 https://github.com/ivansslo/isdocker ~/.isdocker
bash ~/.isdocker/menu.sh
```

### 2. Menu Interaktif
Jalankan menu untuk mengelola semua container:
```bash
bash ~/.isdocker/menu.sh
```

---

## 📊 Detail Sistem & Koneksi

| Opsi | Nama OS / App | Default User | Default Port | Mode |
|---|---|---|---|---|
| **01** | **Ubuntu 22.04** | `root` | `2223` | SSH / VNC |
| **02** | **Debian 12** | `root` | `2224` | SSH / VNC |
| **04** | **Windows 11** | `user` | `8006` | Web / VNC |
| **05** | **Windows 7** | `user` | `8007` | Web / VNC |
| **06** | **Kali NetHunter**| `root` | `2222` | SSH / VNC |
| **26** | **Antigravity (Google AI IDE)** | `root` | `5905` | Web |
| **27** | **Provider GCP (Gemini/Vertex)** | — | — | Config |
| **20** | **Tailscale** | — | — | Tunnel |

> **Antigravity** adalah IDE berbasis AI dari Google (Electron/VSCode).
> Opsi **26** menjalankannya **headless** di container `python:3.12-slim`
> (satu keluarga dengan crewai/hermes) memakai `antigravity serve-web`,
> lalu UI editor dibuka lewat **browser** di `http://localhost:5905`
> — tanpa VNC. Build: `linux-arm` (aarch64) v2.2.1.
>
> Subcommand hermes-style: `setup`, `run` (default), `version`, `shell`.
> Jika muncul URL login OAuth di terminal, buka di browser HP Anda.
>
> **Provider GCP (opsi 27)** menyimpan kredensial Google Cloud / Gemini
> (`GEMINI_API_KEY`, `GCP_PROJECT`, `GCP_LOCATION`, Vertex AI, atau
> service-account JSON) ke `~/.hermes_keys` — dipakai bersama oleh
> Antigravity dan crewai/hermes.

### 🔑 Akses Default:
- **SSH Password:** `ubuntu`, `debian`, `alpine`, `kali`, atau `nethunter`.
- **VNC Password:** `vncpass`.
- **Windows User:** Tanpa password (otomatis login).

---

## 🌐 Networking & Tunnel (Remote Access)
Repositori ini sekarang mendukung **Tailscale Tunnel**. Anda bisa mengakses VNC, RDP, dan SSH container Anda dari mana saja di dunia melalui IP Tailscale Anda.

1. Hubungkan Tailscale melalui Opsi **20** di menu.
2. Gunakan IP yang diberikan oleh Tailscale untuk terhubung ke VNC/SSH (contoh: `ssh root@100.x.y.z -p 2223`).

---

## 🔧 Manajemen Container & ID
Gunakan fitur **Container Manager (Opsi 21)** untuk:
- Melihat **Container ID** yang terinstall.
- Mengecek status Running/Inactive.
- Mendapatkan link akses cepat berdasarkan IP Tailscale atau Localhost.

---

## 📜 Lisensi & Tahun Pembuatan
Seluruh script di repositori ini diperbarui untuk tahun **2026**.
Dilisensikan di bawah **MIT License**. Dibuat oleh **ivansslo**.
