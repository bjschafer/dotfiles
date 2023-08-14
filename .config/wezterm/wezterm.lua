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

config.font = wezterm.font("InconsolataNerdFont", {weight="Regular", stretch="Normal", style="Normal"}) -- /usr/share/fonts/OTF/Caskaydia Cove Nerd Font Complete Regular.otf, FontConfig
config.font_size = 10.0

config.term = "wezterm"
config.warn_about_missing_glyphs = false

-- and finally, return the configuration to wezterm
return config

