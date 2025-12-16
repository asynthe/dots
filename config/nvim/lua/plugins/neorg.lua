return {
    "nvim-neorg/neorg",
    requires = "nvim-lua/plenary.nvim",
    dependencies = {
        { "pysan3/neorg-templates", dependencies = { "L3MON4D3/LuaSnip" } },
    },
    run = ":Neorg sync-parsers",
    lazy = false,  -- Disable lazy loading
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
        local os_name = vim.loop.os_uname().sysname
        require("neorg").setup({
            load = {
                --["core.latex.renderer"] = {},
                ["core.defaults"] = {},
                ["core.export"] = {},
                ["core.concealer"] = {
                    config = {
                        init_open_folds = "never", -- Don't open folds
                        icon_preset = "basic", -- basic, diamond, varied
                    },
                },
                ["core.esupports.metagen"] = {
                    config = {
                        type = "auto",
                    },
                },
                ["core.clipboard.code-blocks"] = {},
                ["core.integrations.image"] = {},
                ["core.keybinds"] = {
                    config = {
                        default_keybinds = false,
                    },
                },
                ["core.journal"] = {
                    config = {
                        template_name = "template.norg",
                        journal_folder = ".journal",
                        strategy = "flat",
                        use_template = true,
                        workspace = "notes",
                    },
                },
                ["core.dirman"] = {
                    config = {
                        default_workspace = "notes",
                        workspaces = {
                            notes = "/home/meow/media/ben/notes",
                        },
                    },
                },
            },
        })
    end,
}
