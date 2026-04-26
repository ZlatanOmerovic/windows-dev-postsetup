@echo off
REM CMD startup script - runs on every cmd.exe launch via HKCU AutoRun.
REM Sets doskey aliases, then chains to Clink (which loads starship.lua).

doskey ls=eza --group-directories-first $*
doskey ll=eza -lh --group-directories-first --git $*
doskey la=eza -lah --group-directories-first --git $*
doskey lt=eza --tree $*
doskey g=git $*

REM Shell identifier (read by starship.toml's env_var module).
set STARSHIP_SHELL_LABEL=CMD

REM Set terminal background (OSC 11) - dark charcoal. Spawned PowerShell prints the OSC.
powershell.exe -NoProfile -Command "[Console]::Write([char]27 + ']11;#1a1a1a' + [char]7)"

REM Hand off to Clink. Its injection loads starship.lua from %LOCALAPPDATA%\clink\.
call "C:\Program Files (x86)\clink\clink.bat" inject --autorun
