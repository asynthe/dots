local function enable_transparency()
    vim.api.nvim_set_hl(0, "CursorLineNr", { bg="NONE" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "LineNr", { bg="NONE" })
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" }) -- For inactive windows
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" }) -- Remove background from sign column
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "Folded", { bg = "NONE" })
end

--"folke/tokyonight.nvim",
--config = function()
--vim.cmd.colorscheme "tokyonight"
--enable_transparency()
--end

return {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        vim.cmd.colorscheme "github_dark_default"
        enable_transparency()
    end
}
