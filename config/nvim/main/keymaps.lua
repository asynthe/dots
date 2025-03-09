local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map("n", "<Space>", "", opts)
vim.g.mapleader = " "  -- Set leader key to Space

map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)  -- Open file explorer
