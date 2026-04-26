-- starship.lua — Initialize Starship prompt for CMD via Clink
-- Loaded automatically by Clink when CMD starts (autorun must be installed).
-- Source: https://starship.rs/#cmd
load(io.popen('starship init cmd'):read("*a"))()
