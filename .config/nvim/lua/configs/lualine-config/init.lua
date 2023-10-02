require("lualine").setup({
    options = { theme = "onedark" },
    sections = {
        lualine_a = {
            {
                "filename",
                file_status = true, -- Displays file status (readonly status, modified status)
                newfile_status = false, -- Display new file status (new file means no write after created)
                path = 1, -- 0: Just the filename
                -- 1: Relative path
                -- 2: Absolute path
                -- 3: Absolute path, with tilde as the home directory

                shorting_target = 40, -- Shortens path to leave 40 spaces in the window
                -- for other components. (terrible name, any suggestions?)
                symbols = {
                    modified = "[+]", -- Text to show when the file is modified.
                    readonly = "[-]", -- Text to show when the file is non-modifiable or readonly.
                    unnamed = "[No Name]", -- Text to show for unnamed buffers.
                    newfile = "[New]", -- Text to show for new created file before first writting
                },
            },
        },
        lualine_b = {
            -- Display keycode for character under cursor
            -- 02.B: hex, truncate to 2 chars by default
            -- 03.3b: ascii; min and max width of 3 chars
            "%<󰌌 0x%02.B|%03.3b",
        },
    },
})
