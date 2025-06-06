-- Need to be set up before Lazy loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disabling netrw for Nvim-Tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true -- Optionally enable 24-bit colour

-- Load keybinds once the plugins are loaded.
-- Reason to do this is to have a single file with all keybinds.
vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        require("settings.keybinds_lazy")
    end,
})
