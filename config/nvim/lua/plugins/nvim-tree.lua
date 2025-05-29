-- TODO Check later
-- https://medium.com/@shaikzahid0713/file-explorer-for-neovim-c324d2c53657
return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("nvim-tree").setup {
            actions = {
                open_file = {
                    quit_on_open = true, -- Automatically close nvim-tree when opening a file
                },
            },
            view = {
                width = 30,
            },
            filters = {
                dotfiles = true,
            },
        }
    end,
}
