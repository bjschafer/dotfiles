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

config.enable_scroll_bar = false
config.enable_tab_bar = false

config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

local fontname

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
elseif hostname_is("V7GR7Q194P") then -- work computer
    config.font_size = 13.5 -- 18 if on 4k monitor
    config.window_decorations = "RESIZE" -- remove titlebar, but keep it resizable.
    config.freetype_load_flags = "FORCE_AUTOHINT"
end

config.font = wezterm.font_with_fallback({
    "Maple Mono NF",
    "MapleMonoNerdFont",
    "Inconsolata Nerd Font",
    "InconsolataNerdFont",
}, { weight = "Regular", stretch = "Normal", style = "Normal" })

-- and finally, return the configuration to wezterm
return config
