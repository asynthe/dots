local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<leader>wc", ":q<CR>", opts) -- Close Window

-- Directory Navigation
keymap.set("n", "<leader>m", ":NvimTreeFocus<CR>", opts)
keymap.set("n", "<C-a>", ":NvimTreeToggle<CR>", opts)

-- Pane Navigation
keymap.set("n", "<C-h>", "<C-w>h", opts) -- Navigate Left
keymap.set("n", "<C-j>", "<C-w>j", opts) -- Navigate Down
keymap.set("n", "<C-k>", "<C-w>k", opts) -- Navigate Up
keymap.set("n", "<C-l>", "<C-w>l", opts) -- Navigate Right

-- Window Management
keymap.set("n", "<leader>wv", ":vsplit<CR>", opts) -- Split Vertically
keymap.set("n", "<leader>ws", ":split<CR>", opts) -- Split Horizontally
-- keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>", opts)

-- Indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Comments
vim.api.nvim_set_keymap("n", "<C-_>", "gcc",{ noremap = false })
vim.api.nvim_set_keymap("v", "<C-_>", "gcc",{ noremap = false })

-- Buffers
keymap.set("n", "<C-]>", ":bnext<CR>", opts)
keymap.set("n", "<C-[>", ":bprev<CR>", opts)
