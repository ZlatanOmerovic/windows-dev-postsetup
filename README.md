# windows-dev-postsetup

Hit-and-run PowerShell bootstrap for a fresh Windows 11 dev machine.

Personal setup of [@ZlatanOmerovic](https://github.com/ZlatanOmerovic). Public so others can fork and customize. Hardcoded for one user — not designed as a generic config framework, but the structure is easy to lift.

## What it does

Single command on a fresh Windows 11 install lays down a complete dev environment:

- **45+ apps via winget** — runtimes (.NET 9/10 SDKs, Python 3.13, Node via nvm, Rust, PHP via choco), IDEs (Visual Studio 2026 Community, JetBrains Toolbox, Sublime Text, VS Code), dev tools (Docker Desktop, Postman, GitHub CLI, lazygit, git-delta, WinSCP, PuTTY suite), terminal stack (WezTerm, Starship, Clink, JetBrainsMono Nerd Font), browsers (Brave, Firefox, Chrome), media (VLC, foobar2000 + encoders, FFmpeg), comm (Discord, Viber), remote (AnyDesk, TeamViewer), utilities (PowerToys, ShareX, Everything, 7-Zip, WinRAR, Sysinternals, WizTree, Obsidian).
- **WSL2 Debian setup** — `apt install` for `zsh fzf bat eza zoxide ripgrep ffmpeg fastfetch wget` etc., switches default shell to zsh, installs Starship, clones `zsh-autosuggestions` + `zsh-syntax-highlighting`, copies SSH keys with proper Linux perms.
- **5-shell prompt parity via Starship** — same tokyo-night prompt with per-shell `[ LABEL ]` chip in: WSL Debian zsh, PowerShell 5.1, PowerShell 7, Git Bash, CMD (via Clink).
- **Per-shell terminal background colors** — using OSC 11 escape sequences from the shell rc, so both **Windows Terminal** and **WezTerm** get matching backgrounds without per-terminal config (Git Bash → dark green, Debian → dark red, PS 5.1 → royal blue, PS 7 → darker navy, CMD → charcoal).
- **SSH agent on Windows** — enables the built-in `ssh-agent` service, fixes ACLs on user keys, loads them into the agent, points `git` at Windows OpenSSH so `git push` uses the loaded keys.
- **Modern CLI symmetry** — `bat`, `eza`, `jq`, `wget`, `fastfetch` work the same way in all 5 shells (Windows + WSL).
- **Git enhancements** — wires `delta` as the global `core.pager` and `interactive.diffFilter` with sensible defaults.
- **WezTerm config** — drops you into WSL Debian by default, leader-key splits/tabs (Ctrl+a, tmux-style), launch menu for picking other shells, JetBrainsMono Nerd Font, Tokyo Night scheme, fixes new-tab cwd via OSC 7 in zsh.
- **Windows Terminal config** — JetBrainsMono Nerd Font globally, custom profile order (Git Bash first, default), per-profile backgrounds, Azure Cloud Shell suppressed.

## Hit-and-run

Open **PowerShell as Administrator** on a fresh Windows 11 box and:

```powershell
irm https://raw.githubusercontent.com/ZlatanOmerovic/windows-dev-postsetup/master/bootstrap.ps1 | iex
```

That's it. Sit back. The script will:

1. Verify it's running elevated and that `winget` exists (built into Win11).
2. Verify WSL2 + Debian are installed (or print a clear "do these first" message and exit).
3. Install everything in the right order, with progress reporting.
4. Generate `MANUAL_STEPS_GENERATED.md` in your home directory and open it in Notepad — covers the few things that can't be automated (JetBrains Toolbox sign-in, NCrunch download, Visual Studio workload selection, `gh auth login`, etc.).

## Prerequisites

The script assumes you've done this much manually first:

1. **Fresh Windows 11** (any edition; tested on Win 11 Pro).
2. **WSL2 + Debian** installed: open admin PowerShell and run `wsl --install -d Debian`, reboot, then launch Debian once to create your user (the script's WSL phase needs this user to exist as a sudoer).
3. **PowerShell as Administrator** for the bootstrap run itself.

The `bootstrap.ps1` will refuse to run if any of these are missing, with clear next-step instructions.

## What you'll need to do *after* the script

Generated as `MANUAL_STEPS_GENERATED.md` at the end. Highlights:

- Drop your SSH keys at `~/.ssh/` (the script's SSH phase auto-skips if they're absent — you re-run that one task afterward).
- Launch JetBrains Toolbox, sign in with your JB account, install Rider + DataGrip from inside it.
- Visit [ncrunch.net/download](https://www.ncrunch.net/download) for the NCrunch installer (it adds VS extension + Rider plugin in one shot — no winget package).
- Open Visual Studio Installer once and pick workloads (.NET desktop, ASP.NET, etc.) — VS only installs the shell + minimal components on first install.
- `gh auth login` — for GitHub CLI.
- Open WezTerm or any new shell to verify the prompt + background colors render correctly.

## Repo layout

```
.
├── bootstrap.ps1             # entry point — orchestrates tasks/ in order
├── packages.txt              # winget package IDs, one per line
├── tasks/
│   ├── 00-preflight.ps1      # admin? winget? Debian? exit gracefully if not
│   ├── 01-chocolatey.ps1     # install Choco (needed for PHP)
│   ├── 02-winget-batch.ps1   # loops through packages.txt
│   ├── 03-php-choco.ps1      # PHP via Choco
│   ├── 04-node-nvm.ps1       # nvm install lts; nvm use lts
│   ├── 05-rust-components.ps1 # rustup default stable + components
│   ├── 06-avalonia.ps1       # dotnet new install Avalonia.Templates
│   ├── 07-ssh-agent.ps1      # ssh-agent service + ACL fix + ssh-add
│   ├── 08-wsl-debian.ps1     # apt + zsh + starship + plugins + SSH copy
│   ├── 09-deploy-configs.ps1 # copy dotfiles into place
│   ├── 10-windows-terminal.ps1 # deploy WT settings.json
│   ├── 11-wezterm.ps1        # deploy .wezterm.lua
│   ├── 12-clink-cmd.ps1      # Clink autorun + cmd_startup.cmd autorun
│   ├── 13-git-delta.ps1      # wire delta into git config globally
│   └── 99-finalize.ps1       # generate + open MANUAL_STEPS_GENERATED.md
├── configs/
│   ├── windows/              # mirrors target paths under %USERPROFILE%
│   ├── windows-terminal/
│   └── debian/               # mirrors target paths under WSL ~/ (Linux side)
├── INVENTORY.md              # source-of-truth: every package, its source, its purpose
├── LESSONS.md                # gotchas + fixes encountered during initial build
├── MANUAL_STEPS.md           # template for the generated post-install checklist
├── LICENSE                   # MIT
└── README.md                 # this file
```

## License

MIT. Fork freely. If you fork and customize, change `ZlatanOmerovic` references in `configs/` and `tasks/07-ssh-agent.ps1` to your own.

## Origin

Built in one extended Claude Code session on 2026-04-26 while doing the actual fresh-install setup. See [LESSONS.md](LESSONS.md) for the gotchas hit along the way (em-dash in CMD AutoRun .cmd files, Git Bash login profile dropping User-scope PATH, OSC 7 cwd tracking for WezTerm new tabs, PowerShell shadowing `wget`/`curl`, nvm-windows needing NVM_HOME env var in shell, etc.).
