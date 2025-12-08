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

    -- Try to use current_working_dir (set via OSC 7 / shell integration)
    -- This avoids shell-truncated titles
    local pane = tab_info.active_pane
    local cwd_uri = pane.current_working_dir
    if cwd_uri then
        local cwd = cwd_uri.file_path
        if cwd then
            -- Replace home directory with ~
            local home = os.getenv("HOME")
            if home and cwd:sub(1, #home) == home then
                cwd = "~" .. cwd:sub(#home + 1)
            end
            return cwd
        end
    end

    -- Fallback to pane title
    return pane.title
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
