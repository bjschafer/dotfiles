-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'OneHalfDark'

config.enable_tab_bar = false

config.freetype_load_flags = 'FORCE_AUTOHINT'
local fontname

config.term = "wezterm"
config.warn_about_missing_glyphs = false

if wezterm.target_triple == 'aarch64-apple-darwin' then
    -- macOS-specific config
    fontname = "Inconsolata Nerd Font Mono"
    config.font_size = 12.0
    config.window_decorations = "RESIZE" -- remove titlebar, but keep it resizable.
else
    config.font_size = 9.0
    fontname = "InconsolataNerdFont"
end

config.font = wezterm.font(fontname, {weight="Regular", stretch="Normal", style="Normal"}) -- /usr/share/fonts/OTF/Caskaydia Cove Nerd Font Complete Regular.otf, FontConfig

-- and finally, return the configuration to wezterm
return config

