return {
    "nvim-neorg/neorg",
    lazy = false,  -- Disable lazy loading
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
        local os_name = vim.loop.os_uname().sysname
        require("neorg").setup({
            load = {
                --["core.latex.renderer"] = {},
                ["core.defaults"] = {},
                ["core.concealer"] = {}, -- Enables pretty icons
                ["core.clipboard.code-blocks"] = {},
                ["core.integrations.image"] = {},
                ["core.keybinds"] = {},
                    --config = {
                        --default_keybinds = false,
                    --},
                --},
                ["core.dirman"] = {
                    config = {
                        --index = "index.norg",
                        -- Add if os_name == "Linux" and others here, just for `default_workspace`
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
