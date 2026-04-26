# MANUAL_STEPS

This file is the **template**. The `99-finalize.ps1` task generates a personalized `MANUAL_STEPS_GENERATED.md` in your home directory at the end of the bootstrap run and opens it in Notepad. Use that one — this file is just for reference / fork-time customization.

---

## After bootstrap finishes — things you still need to do by hand

### 1. JetBrains Toolbox + Rider + DataGrip

JetBrains Toolbox was installed by winget but you still need to:

1. Launch **JetBrains Toolbox** from the Start menu.
2. Sign in with your JetBrains account (your subscription license + auto-updates flow through here).
3. From inside Toolbox, install **Rider** and **DataGrip** (and any other JetBrains IDEs you use).

### 2. NCrunch (paid, no winget package)

1. Visit [https://www.ncrunch.net/download](https://www.ncrunch.net/download).
2. Download the latest installer.
3. Run it. The installer offers to add the **Visual Studio extension** AND the **Rider plugin** in the same flow — check both.
4. Activate with your NCrunch license.

### 3. Visual Studio 2026 Community — pick workloads

VS installs only the shell + minimal components on first install. You need to pick workloads:

1. Launch **Visual Studio Installer** (or run `& "C:\Program Files\Microsoft Visual Studio\Installer\setup.exe"`).
2. Pick workloads matching your work. Recommended for this setup:
   - **.NET desktop development** (WPF, WinForms — for the WPF→Avalonia port)
   - **ASP.NET and web development** (if you do web)
   - **Data storage and processing** (SQL Server tooling)
3. Each workload adds GBs — be patient.

### 4. GitHub CLI auth

```powershell
gh auth login
```

Choose: GitHub.com → SSH (uses your loaded `github_ed25519` key) → follow the browser flow.

### 5. SSH keys

If you didn't drop your private SSH keys at `~/.ssh/` before running the bootstrap, the SSH agent task auto-skipped. Drop them now and re-run just that one task:

```powershell
# After dropping keys at ~/.ssh/
.\tasks\07-ssh-agent.ps1
```

### 6. Verify the prompts

Open one tab of each shell to confirm the `[ LABEL ]` chip + per-shell background color render correctly:

- **WezTerm** → leader+space → pick each shell from the launch menu
- **Windows Terminal** → use the dropdown to open Git Bash, Debian, PowerShell 7, Windows PowerShell, CMD

You should see:
- Git Bash → `[ GIT BASH ]` chip + dark green background
- Debian → `[ DEBIAN-WSL2 ]` chip + dark red background
- PowerShell (7) → `[ PS-7 ]` chip + very dark navy background
- Windows PowerShell (5.1) → `[ PS-DEFAULT ]` chip + royal dark blue background
- CMD → `[ CMD ]` chip + charcoal background

### 7. First-time launches that need attention

| App | Why |
|---|---|
| **PowerToys** | Doesn't auto-start by default. Open it once from Start, enable "Run at startup" in settings. |
| **ShareX** | First launch asks if you want it to handle PrintScreen — say yes. |
| **Everything** | First launch indexes the system (~30 sec), then is instant. |
| **Docker Desktop** | First launch asks for EULA acceptance + WSL2 backend wiring (may need a single reboot). |
| **WezTerm** | If you opened a tab before the WSL hooks (`STARSHIP_SHELL_LABEL`, OSC 7, etc.) loaded into your zsh — close all tabs and reopen for a fresh load. |

### 8. WSL Debian — verify zsh + plugins loaded

Open the **Debian** profile in Windows Terminal (or WezTerm). You should see:

- `[ DEBIAN-WSL2 ]` Starship prompt chip
- Tokyo Night colored prompt
- Try `ll` → eza output with git markers
- Try `z some-dir` → zoxide jumps to most-frecent match

If anything's missing, run `source ~/.zshrc` once in the existing tab.

### 9. (Optional but recommended) — Fastfetch greeting on shell open

By default `fastfetch` only runs when you call it. Some prefer it greeting them on every shell open. To enable, add `fastfetch` at the bottom of `~/.zshrc` (Debian) or `~/.bashrc` (Git Bash). Uncomment in PowerShell profiles. Skip this if you find it noisy.

---

## If something broke

See [LESSONS.md](LESSONS.md) for known gotchas and their fixes.
