return {
    "nvim-neorg/neorg",
    requires = "nvim-lua/plenary.nvim",
    run = ":Neorg sync-parsers",
    lazy = false,  -- Disable lazy loading
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
        local os_name = vim.loop.os_uname().sysname
        require("neorg").setup({
            load = {
                --["core.latex.renderer"] = {},
                ["core.defaults"] = {},
                ["core.concealer"] = {
                    config = {
                        init_open_folds = "never", -- Don't open folds
                        icon_preset = "basic", -- basic, diamond, varied
                    },
                },
                ["core.clipboard.code-blocks"] = {},
                ["core.integrations.image"] = {},
                ["core.keybinds"] = {
                    config = {
                        default_keybinds = false,
                    },
                },
                ["core.dirman"] = {
                    config = {
                        default_workspace = "notes",
                        workspaces = {
                            notes = "~/notes",
                        },
                    },
                },
            },
        })
    end,
}
