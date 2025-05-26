local function enable_transparency()
    vim.api.nvim_set_hl(0, "CursorLineNr", { bg="NONE" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "LineNr", { bg="NONE" })
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" }) -- For inactive windows
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" }) -- Remove background from sign column
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
end

return {
    {
        "folke/tokyonight.nvim",
        config = function()
            vim.cmd.colorscheme "tokyonight"
            enable_transparency()
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        --opts = {
            --theme = "tokyonight",
        --},
        config = function()
            local auto_theme_custom = require("lualine.themes.auto")
            auto_theme_custom.normal.c.bg = "None"

            local custom_codedark = require("lualine.themes.codedark")
            custom_codedark.normal.c.bg = "None"

            require('lualine').setup({
                options = {
                    icons_enabled = true,
                    theme = custom_codedark,
                    component_separators = { left = '', right = ''},
                    section_separators = { left = '', right = ''},
                    --component_separators = { left = '', right = ''},
                    --section_separators = { left = '', right = ''},
                    disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                    },
                    ignore_focus = {},
                    always_divide_middle = true,
                    always_show_tabline = true,
                    globalstatus = false,
                    refresh = {
                        statusline = 100,
                        tabline = 100,
                        winbar = 100,
                    }
                },
                sections = {
                    -- Original
                    --lualine_a = {'mode'},
                    --lualine_b = {'branch', 'diff', 'diagnostics'},
                    --lualine_c = {'filename'},
                    --lualine_x = {'encoding', 'fileformat', 'filetype'},
                    --lualine_y = {'progress'},
                    --lualine_z = {'location'}

                    -- Custom
                    lualine_a = {'mode'},
                    lualine_b = {'branch', 'diff', 'diagnostics'},
                    lualine_c = {'encoding', 'fileformat', 'filetype'},
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {'filename'}
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {'filename'},
                    lualine_x = {'location'},
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {},
                winbar = {},
                inactive_winbar = {},
                extensions = {}
            })
        end,
    }
}
