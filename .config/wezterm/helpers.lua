local tab_colors = require("tab_colors")
local wezterm = require("wezterm")

local module = {}

function module.hostname_is(h)
    return string.find(wezterm.hostname(), h)
end

-- Use like `format_pill("1", tab_colors.orange, "my fun text")`
-- returns a table to be passed to `wezterm.format()`
function module.format_pill(colored_text, start_color, body_text, end_color)
    end_color = end_color or tab_colors.gray
    local fmt = {
        { Foreground = { Color = start_color } },
        { Text = wezterm.nerdfonts.ple_left_half_circle_thick },
        { Background = { Color = start_color } },
        { Foreground = { Color = tab_colors.black } },
        { Text = colored_text },
        { Foreground = { Color = tab_colors.fg } },
        { Background = { Color = tab_colors.gray } },
        { Text = body_text },
        { Background = { Color = tab_colors.bg } },
        { Foreground = { Color = end_color } },
        { Text = wezterm.nerdfonts.ple_right_half_circle_thick },
    }
    return fmt
end

function module.tab_title(tab_info)
    local title = tab_info.tab_title
    -- If the tab title is explicitly set, take that
    if title and #title > 0 then
        return title
    end
    -- Otherwise, use the title from the active pane
    -- in that tab
    return tab_info.active_pane.title
end

function module.get_tab_title_length(max_width, is_zoomed)
    if is_zoomed then
        max_width = max_width - 3
    end

    -- index + space
    max_width = max_width - 2

    -- start and end pills
    max_width = max_width - (2 * 2)

    return max_width
end

return module
