# ⚡ roc-containers

**Container Manager + AI Agent CLI for Termux** — Run Docker images di Termux tanpa root, dengan [udocker](https://github.com/indigo-dc/udocker).

> **v1.4.0** · Created by: ivansslo (2026) · **License: MIT**

---

## 🚀 Quick Install

```bash
pkg install git -y
git clone --depth 1 https://github.com/ivansslo/roc-containers ~/.roc-containers
bash ~/.roc-containers/setup.sh
```

One-liner:
```bash
curl -s https://raw.githubusercontent.com/ivansslo/roc-containers/main/setup.sh | bash
```

---

## 📋 Command List

Setelah install, semua command langsung tersedia:

### ⭐ AI Stack (Primary)
| Command | Fungsi |
|---|---|
| `roc-ai` | ⭐ **RocSpace Monorepo — ivansslo/rocspace** |
| `roc-ai mesh` | 🕸️ AI Agent Mesh — cek koneksi semua agents |
| `roc-ai orchestrator <task>` | 🧠 **Autonomous Orchestrator** — Planner→Researcher→Coder→Reviewer→Tester + Grounding (full model support, AIS-DEV + Gateway first-class) |

### 🤖 AI & Agent
| Command | Fungsi |
|---|---|
| `roc-agent` | AI Agent CLI utama — Hermes v5.12.0 "Oracle" |
| `roc-crewai` | CrewAI multi-agent (Groq/Gemini) |
| `roc-hms` | Hermes Agent (container, root) |
| `roc-antigravity` | Antigravity AI IDE (port 5905) |
| `roc-adk` | ADK Invoice Processing (port 8000) |
| `roc-maagba` | Multi-Agent Architectural Guidance (Bedrock AgentCore) |

### 🐧 OS Containers
| Command | Fungsi |
|---|---|
| `roc-ubuntu` | Ubuntu 22.04 (port 2223) |
| `roc-debian` | Debian 12 (port 2224) |

### 🌐 Network & Services
| Command | Fungsi |
|---|---|
| `roc-tailscale` | Tailscale VPN (container node) |
| `roc-httpd` | HTTP Server (port 3000) |
| `roc-spwr` | Superpowers (coding agent skills) |
| `roc-hermui` | Hermes UI (ivansslo/hermes-ui) |
| `roc-clawdex` | Clawdex Mobile (ivansslo/clawdex-mobile) |

### ⚙️ System
| Command | Fungsi |
|---|---|
| `roc-menu` | Menu interaktif utama |
| `roc-status` | Container manager (ID/Status) |
| `roc-gcp` | Google Cloud tools |
| `roc-sysinfo` | System info (RAM/CPU) |
| `roc-update` | Update roc-containers |
| `roc-uninstall` | Uninstall / clean |
| `roc-udocker` | Reinstall udocker |

---

## 🔑 Setup API Keys

```bash
# Interactive
roc-agent setup

# Atau manual
cat > ~/.hermes_keys << 'EOF'
GROQ_KEY=gsk_xxxxxx
GEMINI_KEY=AIzaSxxxxxx
OR_KEY=sk-or-xxxxxx
OPENAI_KEY=sk-xxxxxx
TOKEN=hk-xxxxxx
EOF
chmod 600 ~/.hermes_keys
```

> ⚠️ **Jangan pernah hardcode keys di source code.** Semua keys di-load dari env.

---

## 🧠 AI Models

### Priority (ai-best)
```
Groq (free/fast) → OpenAI → OpenRouter → Gemini → Gateway → CloudRun → CF AI
```

### OpenAI (Direct) — Default: `gpt-4.1`

| Model | Kategori | Context |
|---|---|---|
| `gpt-5` | 🏆 Flagship | 256K |
| `gpt-5-mini` | ⚡ Efficient | 256K |
| `gpt-4.1` | 🎯 Default | 1M |
| `gpt-4.1-mini` | ⚡ Fast | 1M |
| `gpt-4.1-nano` | 🪶 Lightweight | 1M |
| `gpt-4o` | 📦 Vision/JSON | 128K |
| `gpt-4o-mini` | 📦 Fast | 128K |
| `gpt-4.5-preview` | 🔬 Preview | 256K |
| `o3-pro` | 🧠 Advanced reasoning | 200K |
| `o3` | 🧠 Reasoning | 200K |
| `o3-mini` | 🧠 Reasoning fast | 200K |
| `o4-mini` | 🧠 Compact | 200K |
| `codex-mini` | 💻 Coding/SWE | 192K |

### Google AI Studio (Direct) — Default: `gemini-3.5-flash`

50 models tersedia, termasuk:

| Model | Kategori | Context |
|---|---|---|
| `gemini-3.5-flash` | 🏆 Latest, fast | 1M |
| `gemini-3.1-pro` | 🧠 Advanced, custom tools | 2M |
| `gemini-3.1-flash-lite` | 🪶 Ultra-fast | 1M |
| `gemini-3-pro` | 🎨 Image gen, advanced | 2M |
| `gemini-3-flash` | ⚡ Fast, coding | 1M |
| `gemini-2.5-pro` | 🧠 Reasoning, 2M | 2M |
| `gemini-2.5-flash` | ⚡ Multimodal | 1M |
| `gemini-2.5-flash-lite` | 🪶 Lightweight | 1M |
| `gemini-2.0-flash` | 📦 Stable | 1M |
| `deep-research-max` | 🔬 Deep research | 2M |
| `deep-research` | 🔬 Research | 2M |
| `gemma-4-31b` | 📦 Open-weight | 128K |
| `imagen-4-ultra` | 🎨 Image generation | — |
| `imagen-4-fast` | 🎨 Fast image gen | — |
| `veo-3.1` | 🎬 Video generation | — |

### Groq (Free/Ultra-Fast) — Default: `llama-3.3-70b-versatile`

| Model | Kategori |
|---|---|
| `llama-3.3-70b-versatile` | 🏆 Default |
| `llama-4-scout-17b` | 🆕 Next-gen |
| `qwen3-32b` | 💻 Coding |
| `qwen3.6-27b` | 🆕 Latest |
| `gpt-oss-120b` | 📦 Open-source large |
| `compound` | 🧠 Agentic reasoning |

### OpenRouter — Default: `anthropic/claude-sonnet-4-5`

| Model | Provider |
|---|---|
| `anthropic/claude-sonnet-4-5` | Anthropic |
| `google/gemini-2.5-pro-preview` | Google |
| `deepseek/deepseek-r1` | DeepSeek |
| `qwen/qwen3-235b-a22b` | Alibaba |

---

## 🖥️ Menu Interaktif

```bash
roc-menu
```

```
 ╔══════════════════════════════════════════════════════╗
 ║       roc-containers · Termux Container Manager      ║
 ╚══════════════════════════════════════════════════════╝

 ── ⭐ AI Stack (Primary) ──
 [01] RoadFX AI Stack              → roc-ai
 [02] AI Agent Mesh                → roc-ai mesh

 ── 🤖 AI & Agent ──
 [03] AI Agent CLI                 → roc-agent
 [04] CrewAI Multi-Agent           → roc-crewai
 [05] Hermes Agent (container)     → roc-hms
 [06] Antigravity AI IDE           → port 5905
 [07] ADK Invoice Processing       → port 8000
 [08] MAAGBA (Bedrock AgentCore)   → roc-maagba

 ── 🐧 Operating Systems ──
 [09] Ubuntu 22.04 LTS             → port 2223
 [10] Debian 12 Bookworm           → port 2224

 ── 🌐 Network & Services ──
 [11] Tailscale VPN                → roc-tailscale
 [12] HTTP Server                  → port 3000
 [13] Superpowers (agent skills)   → roc-spwr
 [14] Hermes UI                    → roc-hermui
 [15] Clawdex Mobile               → roc-clawdex

 ── ⚙️ System ──
 [16] Container Manager (Status)
 [17] Google Cloud (GCP)
 [18] System Info (RAM/CPU)
 [19] Update roc-containers
 [20] Uninstall / Clean
 [21] Reinstall udocker
```

---

## ⭐ roc-ai — RoadFX AI Stack + lsmod

**Command utama** — AI service container yang selalu up-to-date + module system.

### lsmod Modes (Agent/Chat/Coding/Error)

| Sub-command | Fungsi |
|---|---|
| `roc-ai agent <task>` | 🤖 Agent Mode — delegasi tugas ke AI agent |
| `roc-ai chat` | 💬 Chat Mode — interactive chat dengan AI |
| `roc-ai code <task>` | 💻 Coding Mode — AI coding assistant |
| `roc-ai error <msg>` | 🐛 Error Handler — analisis & fix error |
| `roc-ai native` | Run lsmod native CLI (lasokamodule) |

### ⭐ Pewaris lsmod (roc-ai Special)

roc-ai adalah **pewaris lsmod** — fitur istimewa yang menyebar ke semua AI & Agent containers:

| Sub-command | Fungsi |
|---|---|
| `roc-ai orchestrate <task>` | 🎼 Orchestrate semua AI agents untuk task kompleks |
| `roc-ai orchestrator <task>` | 🧠 Autonomous Orchestrator (Planner→Researcher→Coder→Reviewer→Tester + Grounding) — full support coding/fast/high-thinking/grounding, auto-import to AI Studio |
| `roc-ai route <task> [ctx]` | 🧭 Route task ke agent yang tepat (auto/crew/hms/adk/code/error) |
| `roc-ai broadcast <msg>` | 📢 Broadcast pesan ke semua AI agents |
| `roc-ai mesh` | 🕸️ Cek status koneksi semua AI Agent containers |

**lsmod Propagation:**
- `lib/lsmod_loader.sh` — shared loader, di-source oleh SEMUA roc-* script
- Setiap AI container mendapat `.lsmod/` dengan init script
- `roc-ai install` → propagate lsmod ke semua container data dirs
- Semua keys dari env, **tidak ada hardcoded secrets**

### Stack Management

| Sub-command | Fungsi |
|---|---|
| `roc-ai install` | Clone stack + lsmod + install dependencies |
| `roc-ai run` | Start AI stack services |
| `roc-ai status` | Cek semua services, modules, & API keys |
| `roc-ai update` | Force update ke versi terbaru |
| `roc-ai docs` | Lihat README |
| `roc-ai list` | List isi repo |
| `roc-ai shell` | Buka shell di repo dir |

### Fitur

- **lsmod Module System**: `ivansslo/lsmod` — Agent, Chat, Coding, Error modes
- **⭐ Pewaris lsmod**: roc-ai mewarisi semua lsmod + orchestration, routing, broadcast, mesh
- **lsmod Propagation**: Menyebar ke semua AI & Agent containers via `lib/lsmod_loader.sh`
- **Google AI Studio**: 50 models langsung via GEMINI_KEY — gemini-3.5-flash, gemini-3.1-pro, deep-research, imagen-4, veo-3.1
- **OpenAI Direct**: 13 models — gpt-5, gpt-4.1, o3-pro, codex-mini (max 16384 tokens)
- **Auto-update**: Cek update otomatis setiap 1 jam saat `roc-ai run`
- **Service status**: `roc-ai status` — repo, modules, Python, Node, Docker, containers, API keys
- **Always current**: `roc-ai update` pull + re-install deps
- **Security**: Hardcoded keys auto-sanitized, invalid key names skipped

---

## 📂 Struktur Direktori

```
~/.roc-containers/
├── setup.sh              # Installer + command linker
├── menu.sh               # Menu interaktif
├── install_udocker.sh    # udocker installer
├── start.sh              # Quick start
├── push.sh               # Git push helper
├── bin/                  # Binary wrappers
├── lib/
│   ├── source.env        # Shared env & udocker helpers
│   ├── lsmod_loader.sh   # lsmod shared loader (all roc-*)
│   ├── cli_command.sh    # CLI submenu
│   ├── google_project.sh # GCP submenu
│   ├── manager.sh        # Container manager
│   ├── sysinfo.sh        # System info
│   ├── uninstall.sh      # Uninstaller
│   └── update.sh         # Updater
├── os/
│   ├── ubuntu/           # Ubuntu container
│   └── debian/           # Debian container
└── apps/
    ├── ai/               # ⭐ RoadFX AI Stack (primary)
    │   ├── ai.sh          # Main AI stack script
    │   ├── lsmod.sh       # lsmod module system (Pewaris)
    │   └── modules/       # lsmod cloned repo (auto)
    ├── roc-agent/        # AI Agent CLI (roc-agentsroute)
    ├── hermes-agent/     # Hermes Agent engine
    ├── crewai/           # CrewAI
    ├── hms/              # Hermes Agent (container)
    ├── antigravity/      # Antigravity AI IDE
    ├── adk-invoice/      # ADK Invoice
    ├── maagba/           # MAAGBA (Bedrock AgentCore)
    ├── tailscale/        # Tailscale VPN
    ├── httpd/            # HTTP Server
    ├── spwr/             # Superpowers
    ├── hermui/           # Hermes UI
    └── clawdex/          # Clawdex Mobile
```

---

## 🗄️ Infrastructure

| Service | Provider | Region | Status |
|---|---|---|---|
| PostgreSQL | Aiven (`pg-roadfx`) | AWS ap-southeast-3 | business-8 |
| Solace PubSub+ | Solace Cloud | Singapore | 5 queues, connected |
| CF Workers Gateway v17.1.1 | Cloudflare | Global | 16 models, 14 domains (unified) |
| Cloud Run (ai-vitality) | Google Cloud | us-west1 | AI + Data |
| AI Studio | Google | Global | 50 models |
| Oracle VM (roc-vm) | OCI | Singapore | 1CPU/16GB, PG+Redis |
| Tailscale VPN | Tailscale | Global | 4 nodes |
| Uptime Kuma | OCI | Singapore | Monitoring |

### Aiven (Managed Database)
- **Project:** `roadfrx-ai`
- **Service:** `pg-roadfx` (PostgreSQL, business-8)
- **Host:** `pg-roadfx-roadfrx-ai.e.aivencloud.com:21876`
- **PgBouncer:** port 21877
- **DB:** `defaultdb` / User: `avnadmin`
- **Commands:** `hermes aiven status|pg-uri|pg-connect|services`

### Solace PubSub+ (Event Mesh)
- **Broker:** `mr-connection-mwc1f9igml1.messaging.solace.cloud`
- **VPN:** `roclace-cluster`
- **Queues:** `hermes/agent/ai-chat`, `hermes/agent/memory`, `hermes/agent/orchestrator`, `hermes/agent/tools`, `hermes/events`
- **Publish:** `solace_publish <topic> <message>`
- **Status:** `solace_status`

---

## 🔧 Related Repos

| Repo | Fungsi |
|---|---|
| [⭐ rocspace](https://github.com/ivansslo/rocspace) | **Monorepo utama** — v17.1.1, Turborepo + TypeScript (gateway, site, shared) |
| [roc-containers](https://github.com/ivansslo/roc-containers) | Container manager (ini) |
| [roc-agentsroute](https://github.com/ivansslo/roc-agentsroute) | Hermes AI Agent CLI v5.12.0 |
| [ai-vitality](https://github.com/ivansslo/ai-vitality) | AI Studio + Cloud Run |
| [lsmod](https://github.com/ivansslo/lsmod) | Module system (Agent/Chat/Coding/Error) |
| [clawdex-mobile](https://github.com/ivansslo/clawdex-mobile) | Clawdex Mobile |
| [hermes-ui](https://github.com/ivansslo/hermes-ui) | Hermes UI |
| [spwr](https://github.com/ivansslo/spwr) | Superpowers |

### RocSpace Monorepo Structure
```
ivansslo/rocspace (Turborepo + esbuild + TypeScript)
├── packages/shared/      — AI_MODELS, DOMAIN_MAP, utilities
├── workers/site/         — Unified router (ALL 14 domains → roc-site)
├── workers/gateway/      — Hermes Gateway v17.1.1 (hermes-cloudflare)
│   └── src/pages/        — Full HTML: chat, dashboard, crew, crawl, logs, zapier
└── scripts/              — Build & deploy tools
```

### Key Endpoints (roadfx.biz.id)
```
ai.roadfx.biz.id        → Gateway (AI, Solace, Crawl, Auth)
gateway.roadfx.biz.id   → Gateway mirror
api.roadfx.biz.id       → Gateway backup
chat.roadfx.biz.id      → Chat-Live
dashboard.roadfx.biz.id → Dashboard
factory.roadfx.biz.id   → CF AI Factory
app.roadfx.biz.id       → Links Hub
auth.roadfx.biz.id      → Clerk Auth
vm.roadfx.biz.id        → Oracle VM (redirect)
r2.roadfx.biz.id        → R2 Explorer
status.roadfx.biz.id    → Status page
webhook.roadfx.biz.id   → Webhook receiver
cloudrun.roadfx.biz.id  → CloudRun proxy
```

---

## 📜 License

MIT License · Created by **ivansslo** · 2026

---

## 🚀 Infrastructure Xloud Vision (Updated 2026-07-16)

**RocSpace as the Unified Infrastructure for All Apps + Autonomous Models**

- **All providers integrated auto**: Gateway (primary) + AIS_DEV (gemini-2.5-flash) + Groq + OpenRouter + Gemini + CF AI
- **Multi-Orchestra**: Full autonomous loop across containers (Planner → Researcher → Coder → Reviewer → Tester + Grounding)
- **Big Scale Autonomous Models**: roc-ai orchestrator + hermes orchestrator + lsmod propagation
- **Auto import**: `roc-agent import` / `hermes import` → clean JSON ready for Google AI Studio / AIS-DEV
- **First-class AIS_DEV**: `PROVIDER=ais` or `roc-ai orchestrator` uses gemini-2.5-flash for fast + high thinking
- All commands use the same `TOKEN` auth flow as roc-site

```bash
roc-ai orchestrator "Create a multi-provider autonomous coding agent mesh"
roc-agent import "My Big Scale Agent"
```


## 🎨 New UI (v1.3.0)

Modern terminal + dashboard UIs added:

```bash
# After setup
open ~/.roc-containers/ui/roc-containers-ui.html
```

Also includes full support for:
- `roc-ai orchestrator`
- Auto import to AIS-DEV / AI Studio

---

## 🆕 Changelog

### v1.4.0 — Repair Release (2026-07-16)

Audit penuh repo — **8 bug fungsional diperbaiki**, 2 repo-mati diberi fallback,
hijyen & keamanan dirapikan:

**CRITICAL fixes:**
- `setup.sh`: 2 baris `${CYAN}…` nyasar (teks mentah dieksekusi shell) — dengan
  `set -e` ini **menggugurkan setup sebelum command System ter-install**
- `DATA_DIR="$(pwd)/../../data-*"` di 7 script (ubuntu, debian, tailscale,
  httpd, crewai, adk-invoice, antigravity) — data container "nyasar" mengikuti
  cwd pemanggil → kini direlokasi dari lokasi script (`SCRIPT_DIR`)
- `apps/hms/hms.sh`: clone ke dir sendiri (selalu gagal) + path engine salah →
  diganti wrapper ke launcher resmi `apps/hermes-agent/hermes-agent.sh`
- `apps/spwr/spwr.sh`: hal serupa → clone dialihkan ke subdir `repo/`
- `lib/manager.sh`: menu `[0] Back` tak pernah keluar (rekursi tak berujung)
- `lib/source.env`: kini mendefinisikan palet warna — sebelumnya ~15 script
  UI tampil monokrom karena variabel warna tak pernah diisi
- `menu.sh`: opsi 03 rusak di luar Termux (`$PREFIX` kosong → `/bin/roc-agent`);
  prompt kini mencakup opsi 22

**Fallback untuk repo mati (404):**
- `roc-hermui` → dashboard bundel roc-agentsroute via `python -m http.server`
- `lsmod` clone gagal → pesan jujur + mode bawaan (agent/chat/code/mesh) tetap jalan

**Bundle & higiene:**
- `apps/roc-agent/hermes` diperbarui v5.7.3 → **v5.12.0 "Oracle"**
  (termasuk `hermes vm`, panel AI Studio + Oracle VM, Firebase built-in)
- Hapus `apps/ai/ai.sh.bak2`; `docs/PARAMETER-AUDIT.md`: 5 nilai rahasia
  asli direduksi (token terpotong, host, username)
- `apps/ai/ai.sh`: cabang `orchestrate|orch|o` duplikat dihapus
  (`orch`/`o` kini alias orchestrator first-class)
- `lib/libnetstub.sh`: path `/` → `$TMPDIR`; `setup.sh`: clone roc-agentsroute
  non-fatal + fallback bundle; Quick Start output dirapikan
- Versi diseragamkan: `VERSION`, `setup.sh`, README, UI HTML (semua 1.4.0)

