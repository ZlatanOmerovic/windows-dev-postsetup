# windows-dev-postsetup

> Hit-and-run PowerShell bootstrap for a fresh Windows 11 dev machine — full cross-shell prompt parity, WSL2 Debian integration, and 46 winget + 1 Chocolatey + 10 apt packages installed in one command.

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform: Windows 11](https://img.shields.io/badge/platform-Windows%2011-0078d6.svg)](https://www.microsoft.com/windows/windows-11)
[![PowerShell 5.1+](https://img.shields.io/badge/PowerShell-5.1%2B-012456.svg)](https://learn.microsoft.com/powershell/)
[![WSL2 Debian](https://img.shields.io/badge/WSL2-Debian-a81d33.svg)](https://www.debian.org/)

Personal setup of [@ZlatanOmerovic](https://github.com/ZlatanOmerovic). **Hardcoded for one user** — not designed as a generic config framework, but the structure is easy to fork and customize.

---

## ⚡ Hit-and-run

> ⚠️ **Run from elevated PowerShell only.** Right-click PowerShell -> "Run as administrator". The bootstrap fails fast at preflight if not elevated.

```powershell
irm https://raw.githubusercontent.com/ZlatanOmerovic/windows-dev-postsetup/master/bootstrap.ps1 | iex
```

That's the whole thing. The bootstrap will:

1. **Inline preflight** — verify it's running elevated, that `winget` exists, and that **WSL2 + Debian are installed**. Bails out with clear instructions if any of these are missing (no wasted bandwidth).
2. **Auto-install `git`** via winget if not present (so the one-liner works on a truly vanilla machine).
3. **Clone the repo** to a tempdir.
4. **Run all `tasks/NN-*.ps1`** in numeric order with progress reporting (`tasks/00-preflight.ps1` re-runs the preflight checks for users invoking from a local clone — harmless re-verification).
5. **Generate `MANUAL_STEPS_GENERATED.md`** in your home dir and open it in Notepad at the end.
6. **Clean up the cloned tempdir.**

---

## 🎯 What you get

| Feature | Details |
|---|---|
| **5-shell prompt parity** | Same Starship `tokyo-night` prompt with per-shell `[ LABEL ]` chip in WSL Debian zsh, PowerShell 5.1, PowerShell 7, Git Bash, CMD (via Clink) |
| **Per-shell terminal background** | Each shell rc emits an OSC 11 escape sequence — both WezTerm and Windows Terminal honor it, so backgrounds set themselves on shell startup. WT *also* gets per-profile `background` in `settings.json` for instant-on color before the rc fires. (Git Bash → dark green, Debian → dark red, PS 5.1 → royal blue, PS 7 → darker navy, CMD → charcoal) |
| **WSL2 Debian** | zsh + Starship + modern CLI toolkit (`fzf`, `bat`, `eza`, `zoxide`, `ripgrep`) + `wget` + `fastfetch` + `ffmpeg`, default shell switched to zsh, plugins cloned, SSH keys copied with proper Linux perms |
| **SSH on Windows** | Built-in `ssh-agent` service enabled + auto-start, ACLs locked on private keys, keys loaded into agent, `git` pointed at Windows OpenSSH |
| **Modern CLI symmetry** | `bat`, `eza`, `jq`, `wget`, `fastfetch` — same UX in all 5 shells |
| **Git enhancements** | `delta` wired as global pager + diff filter |
| **WezTerm** | WSL Debian default, leader-key splits/tabs, OSC 7 cwd hook for new-tab inheritance |
| **Windows Terminal** | JetBrainsMono Nerd Font globally, custom profile order, per-profile backgrounds, Azure Cloud Shell suppressed |

---

## 📦 What gets installed

### Runtimes & language SDKs

| Package | What |
|---|---|
| `Microsoft.DotNet.SDK.9` | .NET 9 SDK (includes runtime) |
| `Microsoft.DotNet.SDK.10` | .NET 10 SDK (includes runtime) |
| `Python.Python.3.13` | Python 3.13 (real installer, not the Store stub) |
| `CoreyButler.NVMforWindows` | nvm-windows; bootstrap then runs `nvm install lts` |
| `Rustlang.Rustup` | Rust toolchain manager; bootstrap adds `rust-analyzer clippy rustfmt` |
| `php` *(via Chocolatey)* | PHP latest |
| Avalonia .NET templates *(via `dotnet new install`)* | `Avalonia.Templates` — Cross-platform XAML UI framework. Installed by `tasks/06-avalonia.ps1` after the .NET SDKs are in. |

### Editors & IDEs

| Package | What |
|---|---|
| `Microsoft.VisualStudio.Community` | Visual Studio Community 2026 |
| `JetBrains.Toolbox` | Manages Rider, DataGrip, etc. (sign in manually post-install) |
| `SublimeHQ.SublimeText.4` | Sublime Text 4 + opinionated `Preferences.sublime-settings` |
| `Microsoft.VisualStudioCode` | VS Code |

### Dev tools

| Package | What |
|---|---|
| `Docker.DockerDesktop` | Docker Desktop, free tier, WSL2 backend |
| `Postman.Postman` | API client |
| `GitHub.cli` | `gh` |
| `Git.Git` | Git for Windows + Git Bash |
| `JesseDuffield.lazygit` | TUI git client |
| `dandavison.delta` | Beautiful syntax-highlighted git diffs |
| `JernejSimoncic.Wget` | GNU wget for Windows |

### SSH / SFTP

| Package | What |
|---|---|
| `WinSCP.WinSCP` | SFTP client |
| `PuTTY.PuTTY` | Full PuTTY suite |

### Shells & terminal stack

| Package | What |
|---|---|
| `Microsoft.PowerShell` | PowerShell 7 (the modern cross-platform PowerShell; PS 5.1 ships with Windows) |
| `wez.wezterm` | WezTerm — GPU-accelerated terminal, Lua config |
| `Starship.Starship` | Cross-shell prompt — used in all 5 shells |
| `DEVCOM.JetBrainsMonoNerdFont` | Font for terminal + Sublime + IDEs |
| `chrisant996.Clink` | CMD readline + Lua scripting (loads `starship.lua` for the CMD prompt) |

### Browsers

| Package | What |
|---|---|
| `Google.Chrome` | Chrome |
| `Mozilla.Firefox` | Firefox |
| `Brave.Brave` | Brave |

### Media

| Package | What |
|---|---|
| `VideoLAN.VLC` | VLC media player |
| `PeterPawlowski.foobar2000` | foobar2000 audio player |
| `PeterPawlowski.foobar2000.EncoderPack` | Free encoder pack |
| `Gyan.FFmpeg` | FFmpeg (Gyan Doshi's Windows build) |

### Communication

| Package | What |
|---|---|
| `Discord.Discord` | Discord |
| `Rakuten.Viber` | Viber |

### Remote access

| Package | What |
|---|---|
| `AnyDesk.AnyDesk` | AnyDesk |
| `TeamViewer.TeamViewer` | TeamViewer (free tier, non-commercial only) |

### Utilities & quality-of-life

| Package | What |
|---|---|
| `Microsoft.PowerToys` | FancyZones + ColorPicker + PowerToys Run + more |
| `ShareX.ShareX` | Best-in-class screenshot tool |
| `voidtools.Everything` | Instant filename search via NTFS MFT |
| `7zip.7zip` | Handles tar/gz/xz/zst that WinRAR can't |
| `RARLab.WinRAR` | WinRAR |
| `Microsoft.Sysinternals.Suite` | Procexp, Procmon, Autoruns — ~80 tools |
| `AntibodySoftware.WizTree` | Disk usage analyzer (TB drive in seconds) |
| `Obsidian.Obsidian` | Markdown notes / knowledge base |
| `Fastfetch-cli.Fastfetch` | Modern neofetch replacement |
| `sharkdp.bat` | `bat` — syntax-highlighted `cat` |
| `eza-community.eza` | `eza` — modern `ls` |
| `jqlang.jq` | `jq` — JSON processor |

### WSL2 Debian (apt)

| Package | What |
|---|---|
| `zsh` | shell (default for WSL user via `chsh`) |
| `fzf` | fuzzy finder (Ctrl-R history) |
| `bat` | (binary `batcat` on Debian — aliased to `bat`) |
| `eza` | modern `ls` |
| `zoxide` | smarter `cd` (`z projectname`) |
| `ripgrep` | `rg` |
| `wget` | downloader |
| `fastfetch` | system info |
| `ffmpeg` | media transcoder |
| `git`, `curl`, `ca-certificates`, `build-essential` | dev essentials |

Plus: **Starship** (curl-piped to `~/.local/bin/`), **zsh-autosuggestions** + **zsh-syntax-highlighting** (cloned to `~/.zsh/`).

See [INVENTORY.md](INVENTORY.md) for the source-of-truth list with notes on each.

---

## ✋ Prerequisites

The bootstrap assumes you've done this much manually first:

| # | Step | Why |
|---|---|---|
| 1 | Fresh **Windows 11** install (Pro or Home; tested on Pro) | The OS itself |
| 2 | Run `wsl --install -d Debian` in admin PowerShell, reboot, launch Debian once to create your user with a password | The bootstrap doesn't try to install WSL itself (reboot mid-script is ugly); WSL phase needs your sudoer user to exist |
| 3 | Open **PowerShell as Administrator** for the bootstrap run | A lot of installs need elevation |

Bootstrap auto-installs `git` if missing — no need to install it ahead of time.

---

## 🛠 Usage

### Standard hit-and-run

```powershell
irm https://raw.githubusercontent.com/ZlatanOmerovic/windows-dev-postsetup/master/bootstrap.ps1 | iex
```

### From a local clone

```powershell
git clone https://github.com/ZlatanOmerovic/windows-dev-postsetup
cd windows-dev-postsetup
.\bootstrap.ps1
```

### Skip specific tasks (by NN prefix)

```powershell
.\bootstrap.ps1 -Skip 02,08          # skip winget batch and WSL setup
```

### Run only specific tasks

```powershell
.\bootstrap.ps1 -Only 07             # ssh-agent only (e.g. after dropping keys)
.\bootstrap.ps1 -Only 02,03          # winget batch + PHP
```

> ⚠️ **Use the leading zero.** Task file prefixes are zero-padded (`02`, not `2`). `-Skip 2,8` would silently skip nothing because `"02" -ne "2"`.

### Unattended WSL setup

The WSL phase needs your Debian sudo password. By default it prompts. To skip the prompt (e.g. for fully-unattended runs), use a `try`/`finally` block so the env var is wiped even if the script fails mid-way:

```powershell
try {
    $env:WSL_SUDO_PASS = "your-sudo-password"
    .\bootstrap.ps1
} finally {
    Remove-Item Env:\WSL_SUDO_PASS -ErrorAction SilentlyContinue
}
```

The password is only used in-memory for the apt commands and never written to disk.

---

## 📋 What you'll do *after* the bootstrap

A personalized checklist is generated as `MANUAL_STEPS_GENERATED.md` at the end. The highlights:

| Step | Why it's manual |
|---|---|
| Drop SSH keys at `~/.ssh/` | The bootstrap auto-skips agent setup if keys are absent — you re-run `bootstrap.ps1 -Only 07` afterward |
| JetBrains Toolbox sign-in → install Rider + DataGrip from inside it | License + auto-update flow through your JB account |
| [NCrunch](https://www.ncrunch.net/download) installer | Commercial paid tool, no winget package |
| Visual Studio Installer → pick workloads (.NET desktop, ASP.NET, etc.) | VS only installs the shell + minimal components |
| `gh auth login` | Interactive browser auth flow |
| Open WezTerm + each WT profile to verify the prompts and per-shell backgrounds render | Visual verification |

---

## 🗂 Repo layout

```
.
├── bootstrap.ps1               # entry point — orchestrates tasks/ in order
├── packages.txt                # winget package IDs, one per line, comments OK
├── tasks/
│   ├── _helpers.ps1            # shared Write-Phase, Refresh-Path, etc.
│   ├── 00-preflight.ps1        # admin? winget? Debian? exit gracefully if not
│   ├── 01-chocolatey.ps1       # install Choco (needed for PHP)
│   ├── 02-winget-batch.ps1     # loops through packages.txt
│   ├── 03-php-choco.ps1        # PHP via Choco
│   ├── 04-node-nvm.ps1         # nvm install lts; nvm use lts
│   ├── 05-rust-components.ps1  # rustup default stable + components
│   ├── 06-avalonia.ps1         # dotnet new install Avalonia.Templates
│   ├── 07-ssh-agent.ps1        # ssh-agent service + ACL fix + ssh-add
│   ├── 08-wsl-debian.ps1       # apt + zsh + starship + plugins + SSH copy
│   ├── 09-deploy-configs.ps1   # copy shell rc/profiles into place
│   ├── 10-windows-terminal.ps1 # deploy WT settings.json
│   ├── 11-wezterm.ps1          # deploy .wezterm.lua
│   ├── 12-clink-cmd.ps1        # Clink autorun + cmd_startup wrapper
│   ├── 13-git-delta.ps1        # wire delta into git config globally
│   └── 99-finalize.ps1         # generate + open MANUAL_STEPS_GENERATED.md
├── configs/
│   ├── windows/                # mirrors target paths under %USERPROFILE%
│   ├── windows-terminal/       # WT settings.json
│   └── debian/                 # mirrors target paths under WSL ~/
├── INVENTORY.md                # source-of-truth: every package, source, target
├── LESSONS.md                  # gotchas + fixes from the original build
├── MANUAL_STEPS.md             # template for the generated post-install checklist
├── LICENSE                     # MIT
└── README.md                   # this file
```

---

## 🐛 Gotchas worth knowing

The build hit ~14 surprises along the way — see [LESSONS.md](LESSONS.md) for the full list with causes and fixes. The greatest hits:

| Surprise | Where it bit |
|---|---|
| CMD parses `.cmd`/`.bat` files in **OEM codepage** — em-dash in a comment makes it print `'M' is not recognized` on every CMD launch | `cmd_startup.cmd` |
| Git Bash login shell **rebuilds PATH** and drops User-scope Windows PATH entries (your winget shim dir!) | `.bashrc` PATH defensive line |
| PowerShell ships built-in aliases `wget` → `Invoke-WebRequest` and `curl` → same — shadows the real binaries | PS profiles unshadow them |
| WezTerm new tabs land in `/mnt/c/...` because zsh doesn't emit OSC 7 by default — WezTerm has no idea where you actually `cd`'d | `.zshrc` adds `_wezterm_osc7` chpwd hook |
| Git Bash's `ssh-add` doesn't talk to Windows ssh-agent service — they're separate agent stacks | Use full path `C:\Windows\System32\OpenSSH\ssh-add.exe` |
| nvm-windows can't find its `settings.txt` immediately after install — needs `NVM_HOME` env var in current shell | task 04 sets it inline |
| Starship's default `scan_timeout=30ms` is too tight for Windows fs / large dirs — prints WARN every prompt | `starship.toml` bumps to 1000ms |
| Visual Studio 2026 installs to `\18\Community\` not `\2026\Community\` (internal vs marketing version) | Just know where `devenv.exe` lives |
| Azure Cloud Shell auto-respawns in WT even after deletion (it's a dynamic profile source) | `disabledProfileSources` in WT settings |

---

## 📝 License

MIT. Fork freely.

If you fork and customize, the hardcoded references you'll need to change to your own are:

| File | What to change |
|---|---|
| `bootstrap.ps1` | The two GitHub URLs in the `.EXAMPLE` block and in the `git clone` line of the `irm \| iex` path |
| `tasks/08-wsl-debian.ps1` | The heredoc that writes `~/.ssh/config` inside WSL — change the `Host github.com`/`Host ssh.dev.azure.com` blocks and the `IdentityFile ~/.ssh/<keyname>` lines to match the SSH key filenames you use |
| `tasks/99-finalize.ps1` | Repo URL in the generated header |
| `configs/windows-terminal/settings.json` | The `defaultProfile` GUID points at Git Bash on this machine — yours may differ; WT auto-regenerates dynamic-source GUIDs deterministically so it should match, but verify |
| `MANUAL_STEPS.md` | NCrunch / JB Toolbox / etc. references are user-agnostic — leave those alone unless your post-install workflow differs |
| `packages.txt` | Prune to your own taste |

`tasks/07-ssh-agent.ps1` does NOT need changes — it dynamically discovers private keys in `~/.ssh/` and uses `$env:USERNAME` for ACL grants.

---

## 🌱 Origin

Built in one extended Claude Code session on **2026-04-26** while doing the actual fresh-install setup. Nothing in this repo is theoretical — every config, every task, every gotcha in [LESSONS.md](LESSONS.md) was hit and fixed live. The repo is the codified output.

The unique value isn't the package list (everyone has dotfiles repos). It's the **5-shell symmetric prompt** with per-shell terminal background colors driven by **OSC 11 from the shell rc** (works in both Windows Terminal and WezTerm with one config), and the **WSL ↔ Windows integration story** captured end-to-end with the gotchas surfaced.
