local opts = { buffer = true, silent = true, noremap = true }

-- ───────────────────────── Configuration ─────────────────────────
-- No numbering
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.cursorline = false
vim.opt_local.colorcolumn = ""
vim.opt_local.signcolumn = "yes:1"
vim.opt_local.numberwidth = 6

-- Conceal level to hide markup and links
vim.opt_local.conceallevel = 3

-- Indentation
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2

-- Folding
vim.opt_local.foldenable = true
vim.opt_local.foldcolumn = "0" -- Fold column, hides indicator
vim.opt_local.foldlevel =  0 -- All folds closed

-- ───────────────────────── Keybinds ─────────────────────────
-- Main keybinds
vim.keymap.set("n", "<Return>", "<Plug>(neorg.esupports.hop.hop-link)", { buffer = true })
vim.keymap.set("n", "<A-a>", "<Plug>(neorg.qol.todo-items.todo.task-cycle)", { buffer = true })

-- Promote / Demote
vim.keymap.set("n", "<A-Left>", "<Plug>(neorg.promo.demote)", { buffer = true })
vim.keymap.set("n", "<A-Right>", "<Plug>(neorg.promo.promote)", { buffer = true })
vim.keymap.set("i", "<A-Left>", "<Plug>(neorg.promo.demote)", { buffer = true })
vim.keymap.set("i", "<A-Right>",  "<Plug>(neorg.promo.promote)", { buffer = true })

-- Create headers and list items with Alt + Enter
vim.keymap.set("n", "<A-Return>", "<Plug>(neorg.itero.next-iteration)", { buffer = true })
vim.keymap.set("i", "<A-Return>", "<Plug>(neorg.itero.next-iteration)", { buffer = true })

-- Tab to fold headings in normal mode
vim.keymap.set("n", "<Tab>", function()
    pcall(function() vim.cmd("normal! za") end)
end, opts)

--vim.keymap.set("i", "<Tab>", function()
--        pcall(function()
--        vim.cmd("stopinsert")
--        vim.cmd("normal! za")
--        vim.cmd("startinsert")
--    end)
--end, opts)

-- Journal (neorg)
vim.keymap.set("n", "<leader>jn", ":Neorg journal today<CR>", { buffer = true, desc = "Note (today)" })
vim.keymap.set("n", "<leader>jq", ":Neorg journal yesterday<CR>", { buffer = true, desc = "Note (yesterday)" })
vim.keymap.set("n", "<leader>jw", ":Neorg journal tomorrow<CR>", { buffer = true, desc = "Note (tomorrow)" })
