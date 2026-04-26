# LESSONS

Gotchas hit while building this setup the first time. Captured here so neither I nor anyone forking this repo has to rediscover them. Each entry: **the surprise**, **the cause**, **the fix**.

---

## 1. CMD parses `.cmd` / `.bat` files in OEM codepage, not UTF-8

**The surprise:** CMD startup prints `'M' is not recognized as an internal or external command` (or similar single-letter mystery commands) at the start of every session, despite the `.cmd` AutoRun script looking syntactically perfect in any UTF-8 editor.

**The cause:** Default Windows CMD codepage is OEM (often 437 or 1252 depending on locale). Modern editors save UTF-8 without BOM by default. The bytes for an em dash `—` (U+2014) in UTF-8 are `e2 80 94`; CMD reads those three bytes as three separate cp1252/OEM characters, and one of them happens to land at the start of what CMD thinks is a "command" line. Result: CMD tries to execute `M` as a command and fails.

**The fix:** Use **ASCII-only** characters in `.cmd` / `.bat` file content. Plain `-` not `—`, straight quotes not curly, no emoji. If you absolutely need non-ASCII in a `.cmd` file, save it as UTF-8 *with BOM* AND add `chcp 65001 >nul` at the top.

**Where this hit us:** `cmd_startup.cmd` in this repo. Originally had `REM CMD startup — runs on every cmd.exe launch`. Replaced em dash with `-`. Problem disappeared.

---

## 2. Git Bash login shell rebuilds PATH, drops User-scope Windows PATH entries

**The surprise:** In Git Bash, commands like `eza`, `bat`, `jq`, `starship` aren't found, even though they're definitely installed and on the Windows PATH (you can run them in PowerShell or CMD just fine).

**The cause:** Git Bash launches as a login shell (`bash --login -i`) by default. `/etc/profile` reconstructs PATH using MSYS path conversion logic. In some configurations, only **Machine-scope** (HKLM) Windows PATH entries make it through — **User-scope** (HKCU) additions like `%LOCALAPPDATA%\Microsoft\WinGet\Links` get silently dropped during the conversion.

This bites particularly hard with **winget**, which installs most packages to user scope and drops shims into `~/AppData/Local/Microsoft/WinGet/Links` — a User-scope PATH entry.

**The fix:** Defensively re-add the missing dirs in `~/.bashrc`:

```bash
export PATH="$PATH:$HOME/AppData/Local/Microsoft/WinGet/Links:/c/Program Files/starship/bin"
```

**Where this hit us:** First fresh Git Bash session after winget installs. None of `eza/bat/jq/starship` were callable until the PATH workaround was added. See [`configs/windows/.bashrc`](configs/windows/.bashrc).

---

## 3. PowerShell ships with built-in `wget` and `curl` aliases that shadow real binaries

**The surprise:** After `winget install JernejSimoncic.Wget`, typing `wget --version` in PowerShell errors with `The remote name could not be resolved: '--version'`. Same for `curl`.

**The cause:** PowerShell ships with `Set-Alias wget Invoke-WebRequest` and `Set-Alias curl Invoke-WebRequest` baked in. Those aliases take precedence over PATH lookup, so even with the real `wget.exe` on PATH, the alias intercepts.

**The fix:** Remove the aliases at the top of your PowerShell profile:

```powershell
Remove-Item Alias:wget -Force -ErrorAction SilentlyContinue
Remove-Item Alias:curl -Force -ErrorAction SilentlyContinue
```

**Where this hit us:** Both PS 5.1 and PS 7 profiles. See [`configs/windows/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1`](configs/windows/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1).

---

## 4. WezTerm new tabs land in `/mnt/c/...` instead of current Linux cwd

**The surprise:** WezTerm's first WSL tab opens at `/home/zlatan` (correct, set via `default_cwd` in domain config). Press `+` to open a new tab — and it lands at `/mnt/c/Users/zlome` (the translated Windows cwd), not where you actually `cd`'d to in the previous tab.

**The cause:** WezTerm's `SpawnTab CurrentPaneDomain` action (the default `+` action) tries to inherit the current pane's cwd. WezTerm tracks the per-pane cwd via the **OSC 7** escape sequence (`ESC ] 7 ; file://hostname/path BEL`), which the shell must emit. **zsh doesn't emit OSC 7 by default.** Without OSC 7, WezTerm has no idea where the shell is, and falls back to the inherited Windows cwd (translated to `/mnt/c/...`).

**The fix:** Add an OSC 7 emission hook to `~/.zshrc`:

```zsh
_wezterm_osc7() {
    printf '\e]7;file://%s%s\e\\' "${HOSTNAME}" "${PWD}"
}
typeset -ag chpwd_functions
chpwd_functions+=(_wezterm_osc7)
_wezterm_osc7
```

This fires once on shell start and again on every `cd`. WezTerm now knows the real cwd and the `+` button works correctly.

**Where this hit us:** Initial WezTerm experience. Now in [`configs/debian/.zshrc`](configs/debian/.zshrc) at the bottom.

---

## 5. ssh-add from Git Bash doesn't talk to Windows ssh-agent service

**The surprise:** Enabled the Windows `ssh-agent` service, ran `ssh-add ~/.ssh/github_ed25519`, got: `Could not open a connection to your authentication agent.`

**The cause:** Multiple `ssh-add.exe` binaries on PATH. Git Bash ships its own at `C:\Program Files\Git\usr\bin\ssh-add.exe`, which is a separate MSYS-built binary that talks to a separate (non-running) MSYS ssh-agent. The Windows native OpenSSH `ssh-add.exe` lives at `C:\Windows\System32\OpenSSH\ssh-add.exe` and talks to the Windows `ssh-agent` service. Whichever PATH entry comes first wins — and Git for Windows puts itself ahead of System32.

**The fix:** Always use the explicit Windows OpenSSH path when interacting with the agent:

```powershell
& "C:\Windows\System32\OpenSSH\ssh-add.exe" "$env:USERPROFILE\.ssh\github_ed25519"
```

And tell Git to use Windows OpenSSH for actual git ops:

```powershell
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"
```

**Where this hit us:** Initial SSH agent setup. Now in [`tasks/07-ssh-agent.ps1`](tasks/07-ssh-agent.ps1).

---

## 6. nvm-windows can't find its `settings.txt` even when it's right there

**The surprise:** After `winget install CoreyButler.NVMforWindows`, running `nvm install lts` errors with `ERROR open \settings.txt: The system cannot find the file specified.` even though `settings.txt` is sitting in `%LOCALAPPDATA%\nvm\` exactly where it should be.

**The cause:** nvm-windows looks for `settings.txt` relative to where the binary is invoked from, OR via the `NVM_HOME` env var — but the env var isn't loaded into the current shell session immediately after winget install. So nvm tries to find `settings.txt` in the current directory (`\settings.txt` literal).

**The fix:** Set the env vars in the current PS session before invoking nvm:

```powershell
$env:NVM_HOME = "$env:LOCALAPPDATA\nvm"
$env:NVM_SYMLINK = "C:\nvm4w\nodejs"
$env:Path = "$env:NVM_HOME;$env:NVM_SYMLINK;" + $env:Path
nvm install lts
nvm use <version>
```

A new shell after install would pick these up automatically; the bootstrap script needs them inline because everything happens in one session.

**Where this hit us:** First Node install. Now handled in [`tasks/04-node-nvm.ps1`](tasks/04-node-nvm.ps1).

---

## 7. PowerShell ExecutionPolicy is `Restricted` by default — profile won't load

**The surprise:** Wrote a PowerShell profile, opened a fresh PS window, profile didn't load. Got `cannot be loaded because running scripts is disabled on this system`.

**The cause:** Windows ships with `Restricted` execution policy. No `.ps1` files (including your profile) can run.

**The fix:** Set ExecutionPolicy to `RemoteSigned` for `CurrentUser`:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

`RemoteSigned` means: local scripts run, downloaded scripts must be signed. Standard recommended setting. Both PS 5.1 and pwsh 7 have separate ExecutionPolicy stacks — you have to set it for both.

**Where this hit us:** First PS profile load. Now in [`tasks/09-deploy-configs.ps1`](tasks/09-deploy-configs.ps1).

---

## 8. Starship `scan_timeout` defaults are too aggressive for Windows / WSL filesystems

**The surprise:** Starship prints `[WARN] - (starship::context): Scanning current directory timed out.` in every shell, every time. Annoying.

**The cause:** Starship's default `scan_timeout` is 30ms. That's enough on a tight Linux filesystem, but Windows fs scans (especially `/mnt/c/` from WSL, network drives, large dirs with many files) routinely take longer.

**The fix:** Bump `scan_timeout` and `command_timeout` at the top of `starship.toml`:

```toml
scan_timeout = 1000
command_timeout = 1000
```

1000ms is plenty for almost any case. Higher = no warnings, slightly slower prompt under worst case.

**Where this hit us:** All 5 shells, every prompt. Fixed in both `configs/windows/.config/starship.toml` and `configs/debian/.config/starship.toml`.

---

## 9. Visual Studio 2026's path uses internal version `18`, not the marketing year

**The surprise:** `winget install Microsoft.VisualStudio.Community` finishes successfully. Look at `C:\Program Files\Microsoft Visual Studio\2026\Community\` — empty. Look at `\18\Community\` — full install. Confusing.

**The cause:** VS uses internal major version numbers in install paths. VS 2022 = `\17\`, VS 2026 = `\18\`. The "year" is purely marketing.

**The fix:** No fix needed — just know where to look. `devenv.exe` is at `C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\devenv.exe`. The VS Installer is at `C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe`. Path layout is otherwise the same as VS 2022.

---

## 10. WSL `chsh` succeeds but `wsl -d Debian -- bash -c '...'` still uses bash

**The surprise:** Ran `sudo chsh -s $(which zsh) zlatan` in Debian, verified `getent passwd zlatan` shows `/usr/bin/zsh` as the shell. Then ran `wsl -d Debian -- bash -c 'echo $0'` from PowerShell to test something — output is `bash`, not `zsh`.

**The cause:** This is correct behavior, not a bug. `wsl -d Debian -- bash -c '...'` explicitly invokes `bash` as the entry. The user's default shell is consulted only when wsl is invoked **without** a command (i.e. `wsl -d Debian` alone). The `chsh` only affects `wsl -d Debian` (no command) and explicit `wsl -d Debian -- zsh` invocations.

But there's a related real bug: when chsh changes the default shell to zsh, `wsl -d Debian -- bash -c '...'` may still error out with weird zsh-style parse errors if the script contains zsh-incompatible syntax. Actually using `/bin/bash` explicitly avoids confusion.

**The fix:** Always use full path `/bin/bash` (not bare `bash`) when invoking from PowerShell to be unambiguous:

```powershell
wsl -d Debian -- /bin/bash /mnt/c/path/to/script.sh
```

---

## 11. Azure Cloud Shell keeps reappearing in Windows Terminal even after deletion

**The surprise:** Edit `settings.json`, remove the Azure Cloud Shell entry, save. Open WT — Azure Cloud Shell is back.

**The cause:** Azure Cloud Shell is a **dynamic profile** generated by Windows Terminal's `Windows.Terminal.Azure` source on every WT launch. Just deleting the entry from the `list` array doesn't help — the source regenerates it.

**The fix:** Disable the source entirely with the top-level `disabledProfileSources` setting:

```json
{
    "disabledProfileSources": ["Windows.Terminal.Azure"],
    ...
}
```

Then optionally also remove the entry from the list (it'd be ignored anyway).

**Where this hit us:** Personal preference change to remove Azure Cloud Shell from the WT dropdown. Now in [`configs/windows-terminal/settings.json`](configs/windows-terminal/settings.json).

---

## 12. JetBrainsMono Nerd Font on every WT profile in one place

**The surprise:** Don't want to set the font on every profile entry individually.

**The fix:** Set it in `profiles.defaults`. WT applies it to ALL profiles, including dynamic auto-generated ones (e.g. the "Developer Command Prompt for VS 18" that VS 2026 auto-adds):

```json
"profiles": {
    "defaults": {
        "font": { "face": "JetBrainsMono Nerd Font", "size": 11 }
    },
    "list": [...]
}
```

---

## 13. CMD doesn't have `printf` — emitting OSC escape sequences needs a workaround

**The surprise:** Wanted to set the terminal background color (OSC 11 escape sequence) at CMD startup, the same way `.bashrc` and `.zshrc` do via `printf '\e]11;#001a00\007'`. CMD has no `printf`. The `echo` command can't emit raw escape bytes either.

**The fix:** Spawn a one-liner PowerShell from CMD just to print the escape sequence:

```cmd
powershell.exe -NoProfile -Command "[Console]::Write([char]27 + ']11;#1a1a1a' + [char]7)"
```

Adds ~100ms to CMD startup but is portable, doesn't require storing literal escape bytes in the .cmd file, and works on every Windows install. See [`configs/windows/AppData/Local/cmd_startup.cmd`](configs/windows/AppData/Local/cmd_startup.cmd).

---

## 14. Clink autorun + custom CMD AutoRun = need a wrapper script

**The surprise:** Already had Clink injecting via the registry's `HKCU\Software\Microsoft\Command Processor\AutoRun` value. Wanted to ALSO run doskey aliases (`ls=eza`, `ll=eza -lh ...` etc.) at CMD startup. Two AutoRun handlers can't coexist directly.

**The fix:** One custom AutoRun script that does both — sets doskey aliases first, then `call`s the Clink injector:

```cmd
@echo off
doskey ls=eza --group-directories-first $*
doskey ll=eza -lh --group-directories-first --git $*
... etc
call "C:\Program Files (x86)\clink\clink.bat" inject --autorun
```

Then point AutoRun at this wrapper. Both aliases AND Clink (with its `starship.lua`) load on every CMD launch. See [`configs/windows/AppData/Local/cmd_startup.cmd`](configs/windows/AppData/Local/cmd_startup.cmd).
