return {
    "xiyaowong/transparent.nvim",
    lazy = false,
    config = function()
        local transparent = require("transparent")
        transparent.setup({
            extra_groups = {

                "CursorLineNr",
                "EndOfBuffer",
                "LineNr",
                "Normal",
                "NormalFloat",
                "NormalNC",
                "SignColumn",
                "StatusLine",

                "BufferLineFill",  -- barbar.nvim
                "BufferLineTab",   -- barbar tabs
                "BufferLineTabClose",
                "BufferLineBackground",
                "BufferLineSeparator",
                "BufferLineCloseButton",
                "BufferLineIndicatorSelected",
                "StatusLine",      -- lualine
                "StatusLineNC",

                -- Telescope
                "TelescopeNormal",
                "TelescopeBorder",
                "TelescopePromptNormal",
                "TelescopePromptBorder",
                "TelescopePromptTitle",
                "TelescopePreviewTitle",
                "TelescopeResultsTitle",

                -- barbar
                --"BufferCurrent",
                --"BufferVisible",
                --"BufferAlternate",
                --"BufferInactive",
                --"BufferInactiveSign",

                -- Floating windows / Plugin panels
                "NormalFloat",
                "NvimTreeNormal",

                "lualine_a_inactive",
                "lualine_b_inactive",
            },
            exclude_groups = {}, -- Leave empty unless you want to disable transparency for a specific group
        })
        --require("transparent").clear_prefix("Buffer") -- barbar
        --require("transparent").clear_prefix("lualine")
        --require("transparent").clear_prefix("lualine")
    end,
}
