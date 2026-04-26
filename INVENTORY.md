# INVENTORY

Source-of-truth for everything `bootstrap.ps1` installs. If you fork, prune this list to match your own `packages.txt`.

## Windows — winget packages

Listed in install order (`packages.txt`). All installed silently with `--accept-source-agreements --accept-package-agreements --silent --disable-interactivity`.

### Runtimes & SDKs

| Package id | What | Notes |
|---|---|---|
| `Microsoft.DotNet.SDK.9` | .NET 9 SDK | Bundles runtime; no separate runtime install needed |
| `Microsoft.DotNet.SDK.10` | .NET 10 SDK | Same |
| `Python.Python.3.13` | Python 3.13 | Real installer (not the Microsoft Store stub `python` alias) |
| `CoreyButler.NVMforWindows` | nvm-windows | Node version manager; sets `NVM_HOME` env var, needs `nvm install lts` to actually get Node |
| `Rustlang.Rustup` | rustup | Toolchain manager; bootstrap runs `rustup default stable` + adds `rust-analyzer clippy rustfmt` |

### Editors & IDEs

| Package id | What |
|---|---|
| `Microsoft.VisualStudio.Community` | Visual Studio Community 2026 (latest) |
| `JetBrains.Toolbox` | JetBrains Toolbox (manages Rider, DataGrip, etc. — sign in manually post-install) |
| `SublimeHQ.SublimeText.4` | Sublime Text 4 |
| `Microsoft.VisualStudioCode` | VS Code |
| `Microsoft.PowerShell` | PowerShell 7+ (installs as MSIX/Store; `pwsh.exe` ends up in `%LOCALAPPDATA%\Microsoft\WindowsApps`) |

### Dev tools

| Package id | What |
|---|---|
| `Docker.DockerDesktop` | Docker Desktop (free tier, WSL2 backend) |
| `Postman.Postman` | Postman API client |
| `GitHub.cli` | `gh` CLI |
| `Git.Git` | Git for Windows + Git Bash |
| `JesseDuffield.lazygit` | TUI git client |
| `dandavison.delta` | git-delta — beautiful diff pager (wired into git globally by task 13) |
| `JernejSimoncic.Wget` | GNU wget for Windows (PS shadows `wget` → `Invoke-WebRequest`; PS profile unshadows it) |

### SSH / SFTP

| Package id | What |
|---|---|
| `WinSCP.WinSCP` | WinSCP SFTP client |
| `PuTTY.PuTTY` | Full PuTTY suite (putty, pscp, psftp, plink, pageant, puttygen) |

### Terminal stack

| Package id | What |
|---|---|
| `wez.wezterm` | WezTerm (GPU-accelerated terminal, Lua config) |
| `Starship.Starship` | Starship prompt (used in all 5 shells) |
| `DEVCOM.JetBrainsMonoNerdFont` | JetBrainsMono Nerd Font (terminal + Sublime font) |
| `chrisant996.Clink` | Clink (CMD readline + lua scripting; loads `starship.lua` for the CMD prompt) |

### Browsers

| Package id | What |
|---|---|
| `Google.Chrome` | Chrome |
| `Mozilla.Firefox` | Firefox |
| `Brave.Brave` | Brave |

### Media

| Package id | What |
|---|---|
| `VideoLAN.VLC` | VLC media player |
| `PeterPawlowski.foobar2000` | foobar2000 audio player |
| `PeterPawlowski.foobar2000.EncoderPack` | foobar2000 free encoder pack (mp3/aac/etc.) |
| `Gyan.FFmpeg` | FFmpeg (Gyan Doshi's Windows build, the de facto standard) |

### Communication

| Package id | What |
|---|---|
| `Discord.Discord` | Discord |
| `Rakuten.Viber` | Viber |

### Remote access

| Package id | What |
|---|---|
| `AnyDesk.AnyDesk` | AnyDesk |
| `TeamViewer.TeamViewer` | TeamViewer (free tier, non-commercial use only) |

### Utilities & quality-of-life

| Package id | What |
|---|---|
| `Microsoft.PowerToys` | FancyZones, ColorPicker, PowerToys Run, etc. |
| `ShareX.ShareX` | Best-in-class screenshot tool (region/scroll/window capture, annotation, OCR) |
| `voidtools.Everything` | Instant filename search via NTFS MFT |
| `7zip.7zip` | 7-Zip (handles `.tar.gz` / `.tar.xz` / `.tar.zst` that WinRAR can't) |
| `RARLab.WinRAR` | WinRAR (shareware, nags after 40 days) |
| `Microsoft.Sysinternals.Suite` | Procexp, Procmon, Autoruns, TCPView, etc. (~80 binaries, dir auto-added to PATH) |
| `AntibodySoftware.WizTree` | Disk-usage analyzer (reads NTFS MFT — TB drive in seconds) |
| `Obsidian.Obsidian` | Markdown notes / knowledge base |
| `Fastfetch-cli.Fastfetch` | Modern neofetch replacement |
| `sharkdp.bat` | `bat` — `cat` clone with syntax highlighting (do NOT alias `cat` to it) |
| `eza-community.eza` | `eza` — modern `ls` replacement (used for `ls/ll/la/lt` aliases) |
| `jqlang.jq` | `jq` — JSON processor |

## Windows — Chocolatey packages

| Package | What |
|---|---|
| `php` | PHP latest (no maintained winget package; Chocolatey is cleanest on Windows) |

## WSL2 Debian — apt packages

Installed via `tasks/08-wsl-debian.ps1` (which calls `setup-debian.sh` with the sudo password injected via env var).

| Package | What |
|---|---|
| `zsh` | shell (chsh to default for the WSL user) |
| `fzf` | fuzzy finder (Ctrl-R history search) |
| `bat` | (binary named `batcat` on Debian — aliased to `bat` in `.zshrc`) |
| `eza` | modern `ls` |
| `zoxide` | smarter `cd` (`z projectname`) |
| `ripgrep` | `rg` — fast grep |
| `curl`, `git`, `ca-certificates`, `build-essential` | build prerequisites for Starship installer + general dev |
| `wget` | downloader |
| `fastfetch` | system info |
| `ffmpeg` | media transcoder |

Plus, installed via curl-pipe (not apt):

- **Starship** — to `~/.local/bin/` (no sudo needed; `.zshrc` adds `~/.local/bin` to PATH)

Plus, cloned via git (not apt):

- **zsh-autosuggestions** → `~/.zsh/zsh-autosuggestions`
- **zsh-syntax-highlighting** → `~/.zsh/zsh-syntax-highlighting`

## Manual / not-via-script

Things that can't be (or aren't worth) automating — generated into `MANUAL_STEPS_GENERATED.md` at the end of the bootstrap run:

| Item | Why |
|---|---|
| **NCrunch** | Commercial paid tool, no winget package. Download from [ncrunch.net](https://www.ncrunch.net/download). Installer adds VS extension AND Rider plugin in one shot. |
| **Visual Studio workloads** | VS installs only the shell + minimal components. Open `C:\Program Files\Microsoft Visual Studio\Installer\setup.exe` and pick: .NET desktop, ASP.NET, etc. |
| **JetBrains Rider + DataGrip** | Install via JetBrains Toolbox after signing in (so license + auto-updates flow through Toolbox). |
| **`gh auth login`** | Interactive browser auth flow. |
| **SSH keys** | User drops their private + public keys at `~/.ssh/` before/after the bootstrap; the SSH agent task auto-skips if keys aren't present and prints how to re-run it later. |
| **WSL2 + Debian install** | `wsl --install -d Debian` requires a reboot. Bootstrap won't do this — verify-and-bail pattern in preflight. |
| **WSL Debian user creation** | First Debian launch prompts for a username + password. Bootstrap reads sudo password from `$env:WSL_SUDO_PASS` or interactively. |

## Configuration files deployed

All sourced from `configs/` in this repo. Deployment is per-task — see each `tasks/NN-*.ps1` for its own copy logic.

| Source in repo | Deployed to | Deployed by |
|---|---|---|
| `configs/windows/.wezterm.lua` | `~\.wezterm.lua` | `tasks/11-wezterm.ps1` |
| `configs/windows/.config/starship.toml` | `~\.config\starship.toml` | `tasks/09-deploy-configs.ps1` |
| `configs/windows/.bashrc` | `~\.bashrc` | `tasks/09-deploy-configs.ps1` |
| `configs/windows/.bash_profile` | `~\.bash_profile` | `tasks/09-deploy-configs.ps1` |
| `configs/windows/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1` | `~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` | `tasks/09-deploy-configs.ps1` |
| `configs/windows/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` | `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` | `tasks/09-deploy-configs.ps1` |
| `configs/windows/AppData/Local/cmd_startup.cmd` | `%LOCALAPPDATA%\cmd_startup.cmd` | `tasks/12-clink-cmd.ps1` |
| `configs/windows/AppData/Local/clink/starship.lua` | `%LOCALAPPDATA%\clink\starship.lua` | `tasks/12-clink-cmd.ps1` |
| `configs/windows/AppData/Roaming/Sublime Text/Packages/User/Preferences.sublime-settings` | `%APPDATA%\Sublime Text\Packages\User\Preferences.sublime-settings` | `tasks/09-deploy-configs.ps1` |
| `configs/windows-terminal/settings.json` | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json` | `tasks/10-windows-terminal.ps1` |
| `configs/debian/.zshrc` | `~/.zshrc` (in WSL) | `tasks/08-wsl-debian.ps1` |
| `configs/debian/.config/starship.toml` | `~/.config/starship.toml` (in WSL) | `tasks/08-wsl-debian.ps1` |

## System changes (registry / services)

| Change | Made by |
|---|---|
| Set `ssh-agent` service `StartupType=Automatic` and start it | `tasks/07-ssh-agent.ps1` |
| ACLs locked down on `~/.ssh/*` (owner-only read) | `tasks/07-ssh-agent.ps1` |
| `git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"` | `tasks/07-ssh-agent.ps1` |
| HKCU `Command Processor\AutoRun` = `~\AppData\Local\cmd_startup.cmd` | `tasks/12-clink-cmd.ps1` |
| Clink autorun installed (CMD will auto-load Clink) | `tasks/12-clink-cmd.ps1` |
| `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` for both PowerShell 5.1 and pwsh 7 | `tasks/09-deploy-configs.ps1` |
| `git config --global core.pager "delta"` + delta options | `tasks/13-git-delta.ps1` |
