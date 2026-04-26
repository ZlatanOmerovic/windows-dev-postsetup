-- ~/.wezterm.lua — WezTerm config for Windows
-- Default domain: WSL Debian (zsh + Starship + tokyo-night)
-- Generated 2026-04-26

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- =====================================================================
-- Appearance
-- =====================================================================
config.font = wezterm.font_with_fallback {
    'JetBrainsMono Nerd Font',
    'Cascadia Code',
    'Consolas',
}
config.font_size = 11.0
config.line_height = 1.05
config.color_scheme = 'Tokyo Night'
config.window_background_opacity = 0.97
config.window_decorations = 'RESIZE'
config.initial_cols = 140
config.initial_rows = 40
config.scrollback_lines = 10000
config.enable_scroll_bar = true

-- Tab bar
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = true

-- Cursor
config.default_cursor_style = 'SteadyBlock'
config.cursor_blink_rate = 0

-- =====================================================================
-- Shells / domains
-- =====================================================================
-- Default to WSL Debian — this is what opens when you launch WezTerm
config.default_domain = 'WSL:Debian'

-- Fix new-tab cwd: by default, new WSL tabs inherit Windows cwd (e.g. /mnt/c/Users/zlome).
-- Override the auto-generated WSL:Debian domain so it always opens in zlatan's Linux home.
local wsl_domains = wezterm.default_wsl_domains()
for _, dom in ipairs(wsl_domains) do
    if dom.name == 'WSL:Debian' then
        dom.default_cwd = '/home/zlatan'
        dom.username = 'zlatan'
    end
end
config.wsl_domains = wsl_domains

-- Define every shell as a launch menu entry too (so you can pick from menu / Ctrl+Shift+T)
config.launch_menu = {
    {
        label = 'WSL :: Debian (zsh)',
        domain = { DomainName = 'WSL:Debian' },
    },
    {
        label = 'PowerShell',
        args = { 'powershell.exe', '-NoLogo' },
    },
    {
        label = 'PowerShell 7+',
        args = { 'pwsh.exe', '-NoLogo' },
    },
    {
        label = 'Git Bash',
        args = { 'C:\\Program Files\\Git\\bin\\bash.exe', '-i', '-l' },
    },
    {
        label = 'cmd',
        args = { 'cmd.exe' },
    },
}

-- =====================================================================
-- Key bindings — leader-based, tmux-ish
-- =====================================================================
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
    -- Splits
    { key = '|', mods = 'LEADER|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '-', mods = 'LEADER',       action = wezterm.action.SplitVertical   { domain = 'CurrentPaneDomain' } },

    -- Pane navigation (leader + h/j/k/l)
    { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },

    -- Close pane
    { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = true } },

    -- Tabs
    { key = 't', mods = 'LEADER', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
    { key = 'n', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(1) },
    { key = 'p', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(-1) },

    -- Launch menu (pick a shell)
    { key = 'Space', mods = 'LEADER', action = wezterm.action.ShowLauncher },

    -- Copy mode (vim-like scrollback search)
    { key = '[', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },

    -- Quick paste
    { key = ']', mods = 'LEADER', action = wezterm.action.PasteFrom 'Clipboard' },

    -- Reload config
    { key = 'r', mods = 'LEADER', action = wezterm.action.ReloadConfiguration },
}

return config
