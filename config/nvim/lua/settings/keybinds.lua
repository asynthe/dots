-- Need to be set up before Lazy loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load keybinds once the plugins are loaded.
-- Reason to do this is to have a single file with all keybinds.
vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        require("settings.keybinds_lazy")
    end,
})
