-- Pull in the wezterm API
local wezterm = require("wezterm")
-- and our helpers
local helpers = require("helpers")
local tab_colors = require("tab_colors")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end
-- end prologue

config.window_close_confirmation = "NeverPrompt"

config.color_scheme = "Catppuccin Frappe"

local enable_wezterm_tabs = true
-- this breaks shell integration; see https://github.com/wezterm/wezterm/issues/2880
local enable_resumable_sessions = false

if enable_wezterm_tabs then
    if enable_resumable_sessions then
        config.unix_domains = {
            {
                name = "unix",
            },
        }
        config.default_gui_startup_args = { "connect", "unix" }
    end
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
        -- split reorg
        {
            key = "<",
            mods = "LEADER|SHIFT",
            action = wezterm.action.RotatePanes("CounterClockwise"),
        },
        {
            key = ">",
            mods = "LEADER|SHIFT",
            action = wezterm.action.RotatePanes("Clockwise"),
        },
        {
            key = "H",
            mods = "LEADER",
            action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
        },
        {
            key = "J",
            mods = "LEADER",
            action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
        },
        {
            key = "K",
            mods = "LEADER",
            action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
        },
        {
            key = "L",
            mods = "LEADER",
            action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
        },

        {
            key = "[",
            mods = "LEADER",
            action = wezterm.action.ActivateCopyMode,
        },
        { key = "UpArrow", mods = "SHIFT", action = wezterm.action.ScrollToPrompt(-1) },
        { key = "DownArrow", mods = "SHIFT", action = wezterm.action.ScrollToPrompt(1) },

        --        {
        --            key = "d",
        --            mods = "LEADER",
        --            action = wezterm.action.DetachDomain("CurrentPaneDomain"),
        --        },

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

    config.mouse_bindings = {
        -- Change the default click behavior so that it populates
        -- the Clipboard rather the PrimarySelection.
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "NONE",
            action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection"),
        },
        {
            event = { Down = { streak = 3, button = "Left" } },
            action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
            mods = "NONE",
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

        local title = " " .. helpers.tab_title(tab)

        title = wezterm.truncate_right(title, helpers.get_tab_title_length(max_width, pane.is_zoomed))

        if pane.is_zoomed then
            title = title .. " " .. wezterm.nerdfonts.md_arrow_expand_all .. " "
        end

        return {
            -- base background colors
            { Background = { Color = tab_colors.bg } },
            { Foreground = { Color = tab_colors.fg } },

            -- colored index
            { Foreground = { Color = index_color } },
            { Text = " " .. wezterm.nerdfonts.ple_left_half_circle_thick },
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
            { Text = wezterm.nerdfonts.ple_right_half_circle_thick .. " " },
            { Background = { Color = tab_colors.bg } },
            { Foreground = { Color = tab_colors.fg } },
        }
    end)

    wezterm.on("update-status", function(window, pane)
        window:set_left_status(
            wezterm.format(
                helpers.format_pill(wezterm.nerdfonts.md_server .. " ", tab_colors.magenta, " " .. wezterm.hostname())
            )
        )

        local leader = {}

        if window:leader_is_active() then
            leader = helpers.format_pill(
                wezterm.nerdfonts.md_apple_keyboard_control .. "a",
                tab_colors.yellow,
                "",
                tab_colors.yellow
            )
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

if helpers.hostname_is("shinkiro") then -- laptop
    config.font_size = 14.0
    config.freetype_load_target = "Light"
elseif helpers.hostname_is("swordfish") then -- desktop
    config.font_size = 10.0
elseif helpers.hostname_is("K960W7H7V5") then -- work computer
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
