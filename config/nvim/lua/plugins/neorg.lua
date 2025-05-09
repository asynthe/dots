return {
    "nvim-neorg/neorg",
    lazy = false,  -- Disable lazy loading
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
        require("neorg").setup({
            load = {
                --["core.latex.renderer"] = {},
                ["core.concealer"] = {}, -- Enables pretty icons
                ["core.clipboard.code-blocks"] = {},
                ["core.defaults"] = {},
                ["core.integrations.image"] = {},
                ["core.keybinds"] = {
                    config = {
                        default_keybinds = true,
                        --default_keybinds = false,
                    },
                },
                ["core.dirman"] = {
                    config = {
                        index = "index.norg",
                        workspaces = {
                            notes = "~/ben/notes/neorg",
                        },
                    },
                },
            },
        })
    end,
}
