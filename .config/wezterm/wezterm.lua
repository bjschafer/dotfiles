-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end
-- end prologue

local function hostname_is(h)
    return string.find(wezterm.hostname(), h)
end

config.window_close_confirmation = "NeverPrompt" -- tmux preserves my session, so don't interrupt logoff

config.color_scheme = "Catppuccin Frappe"

local tab_colors = {
    bg = "#303446",
    fg = "#c6d0f5",
    cyan = "#99d1db",
    black = "#292c3c",
    gray = "#414559",
    magenta = "#ca9ee6",
    pink = "#f4b8e4",
    red = "#e78284",
    green = "#a6d189",
    yellow = "#e5c890",
    blue = "#8caaee",
    orange = "#ef9f76",
    black4 = "#626880",
}

function tab_title(tab_info)
    local title = tab_info.tab_title
    -- if the tab title is explicitly set, take that
    if title and #title > 0 then
        return title
    end
    -- Otherwise, use the title from the active pane
    -- in that tab
    return tab_info.active_pane.title
end

local enable_wezterm_tabs = true

if enable_wezterm_tabs then
    config.unix_domains = {
        {
            name = "unix",
        },
    }
    config.default_gui_startup_args = { "connect", "unix" }
    config.enable_scroll_bar = true
    config.enable_tab_bar = true
    config.use_fancy_tab_bar = false -- I think I'd rather have this, but all the cool kids use retro
    config.tab_max_width = 32
    config.tab_bar_at_bottom = true

    config.scrollback_lines = 10000

    config.leader = { key = "a", mods = "CTRL" }
    config.keys = {
        -- pass C-a through
        {
            mods = "LEADER|CTRL",
            key = "a",
            action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
        },
        -- splitting
        {
            mods = "LEADER",
            key = "-",
            action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
        },
        {
            mods = "LEADER|SHIFT",
            key = "|",
            action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
        },
        {
            mods = "LEADER",
            key = "c",
            action = wezterm.action.SpawnTab("CurrentPaneDomain"),
        },
        {
            mods = "LEADER",
            key = "x",
            action = wezterm.action.CloseCurrentPane({ confirm = false }),
        },
        {
            mods = "LEADER",
            key = "z",
            action = wezterm.action.TogglePaneZoomState,
        },
        -- split nav
        {
            key = "LeftArrow",
            mods = "LEADER",
            action = wezterm.action.ActivatePaneDirection("Left"),
        },
        {
            key = "RightArrow",
            mods = "LEADER",
            action = wezterm.action.ActivatePaneDirection("Right"),
        },
        {
            key = "UpArrow",
            mods = "LEADER",
            action = wezterm.action.ActivatePaneDirection("Up"),
        },
        {
            key = "DownArrow",
            mods = "LEADER",
            action = wezterm.action.ActivatePaneDirection("Down"),
        },
        {
            key = "h",
            mods = "LEADER",
            action = wezterm.action.ActivatePaneDirection("Left"),
        },
        {
            key = "l",
            mods = "LEADER",
            action = wezterm.action.ActivatePaneDirection("Right"),
        },
        {
            key = "k",
            mods = "LEADER",
            action = wezterm.action.ActivatePaneDirection("Up"),
        },
        {
            key = "j",
            mods = "LEADER",
            action = wezterm.action.ActivatePaneDirection("Down"),
        },

        {
            key = "[",
            mods = "LEADER",
            action = wezterm.action.ActivateCopyMode,
        },

        {
            key = ",",
            mods = "LEADER",
            action = wezterm.action.PromptInputLine({
                description = "Enter new name for tab",
                -- initial_value not yet merged to stable
                action = wezterm.action_callback(function(window, pane, line)
                    -- line will be `nil` if they hit escape without entering anything
                    -- An empty string if they just hit enter
                    -- Or the actual line of text they wrote
                    if line then
                        window:active_tab():set_title(line)
                    end
                end),
            }),
        },

        -- ssh
        {
            key = "s",
            mods = "LEADER|CTRL",
            action = wezterm.action.PromptInputLine({
                description = "Enter hostname to ssh to",
                action = wezterm.action_callback(function(window, pane, line)
                    -- `line` will be `nil` if they hit escape without entering anything
                    -- an empty string if they just hit enter
                    -- or the actual line of text they wrote
                    if line then
                        local tab, pane, window = window:mux_window():spawn_tab({
                            args = {
                                -- hack for PATH issues
                                -- https://wezterm.org/faq.html?h=path#im-on-macos-and-wezterm-cannot-find-things-in-my-path
                                os.getenv("SHELL"),
                                "-i",
                                "-c",
                                wezterm.shell_join_args({ "ssh", "-A", line }),
                            },
                        })
                        tab:set_title(line)
                        pane:set_title(line)
                    end
                end),
            }),
        },
    }

    -- support C-a, #num for switching tabs
    for i = 1, 8 do
        table.insert(config.keys, {
            key = tostring(i),
            mods = "LEADER",
            action = wezterm.action.ActivateTab(i - 1),
        })
    end

    -- tab bar
    config.tab_bar_style = {
        new_tab = "", -- hide new tab button; we use keybindings
    }

    config.colors = {
        tab_bar = {
            background = tab_colors.bg,
        },
    }

    wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
        local index_color = tab_colors.blue
        if tab.is_active then
            index_color = tab_colors.orange
        end

        local pane = tab.active_pane

        local title = " " .. tab_title(tab)

        title = wezterm.truncate_right(title, max_width - 6)

        if pane.is_zoomed then
            title = title .. " 󰁌 "
        end

        return {
            -- base background colors
            { Background = { Color = tab_colors.bg } },
            { Foreground = { Color = tab_colors.fg } },

            -- colored index
            { Foreground = { Color = index_color } },
            { Text = " " },
            { Background = { Color = index_color } },
            { Foreground = { Color = tab_colors.black } },
            { Text = tostring(tab.tab_index + 1) .. " " },

            -- tab title
            { Background = { Color = tab_colors.gray } },
            { Foreground = { Color = tab_colors.fg } },
            { Text = title },

            -- ending
            { Background = { Color = tab_colors.bg } },
            { Foreground = { Color = tab_colors.gray } },
            { Text = " " },
            { Background = { Color = tab_colors.bg } },
            { Foreground = { Color = tab_colors.fg } },
        }
    end)

    wezterm.on("update-status", function(window, pane)
        window:set_left_status(wezterm.format({
            { Foreground = { Color = tab_colors.magenta } },
            { Text = "" },
            { Background = { Color = tab_colors.magenta } },
            { Foreground = { Color = tab_colors.black } },
            { Text = "󰒋 " },
            { Foreground = { Color = tab_colors.fg } },
            { Background = { Color = tab_colors.gray } },
            { Text = " " .. wezterm.hostname() },
            { Background = { Color = tab_colors.bg } },
            { Foreground = { Color = tab_colors.gray } },
            { Text = "" },
        }))

        local leader = {}

        if window:leader_is_active() then
            leader = {
                { Foreground = { Color = tab_colors.yellow } },
                { Text = "" },
                { Background = { Color = tab_colors.yellow } },
                { Foreground = { Color = tab_colors.black } },
                { Text = "^a" },
                { Foreground = { Color = tab_colors.yellow } },
                { Background = { Color = tab_colors.bg } },
                { Text = "" },
                { Foreground = { Color = tab_colors.fg } },
                { Text = "  " },
            }
        end
        window:set_right_status(wezterm.format(leader))
    end)
else
    config.enable_scroll_bar = false
    config.enable_tab_bar = false
end

config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

config.term = "wezterm"
config.warn_about_missing_glyphs = false

--if wezterm.target_triple == "aarch64-apple-darwin" then
-- macOS-specific config
--else
-- other
--end

if hostname_is("shinkiro") then -- laptop
    config.font_size = 14.0
    config.freetype_load_target = "Light"
elseif hostname_is("swordfish") then -- desktop
    config.font_size = 10.0
elseif hostname_is("K960W7H7V5") then -- work computer
    config.font_size = 13.5 -- 18 if on 4k monitor
    config.window_decorations = "RESIZE" -- remove titlebar, but keep it resizable.
    config.freetype_load_flags = "FORCE_AUTOHINT"
end

local font = wezterm.font_with_fallback({
    "Maple Mono NF",
    "MapleMonoNerdFont",
    "Inconsolata Nerd Font",
    "InconsolataNerdFont",
}, { weight = "Regular", stretch = "Normal", style = "Normal" })
config.font = font

if enable_wezterm_tabs then
    config.window_frame = {
        font = font,
    }
end

-- and finally, return the configuration to wezterm
return config
