local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

map("n", "<leader>fs", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>fk", "<cmd>bd!<CR>", { desc = "Close file without saving" })
map("n", "<leader>fn", "<cmd>ObsidianNew<CR>", { desc = "New obsidian note" })

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<C-]>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<C-[>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

map("n", "<Tab>", "<cmd>Neotree toggle<CR>", { desc = "Toggle file tree" })

map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    map("n", "<leader>n", "<cmd>Obsidian new<CR>", { buffer = ev.buf, desc = "New note" })

    -- Ctrl+Enter: continue list with same marker on new line
    map("i", "<C-CR>", function()
      local line = vim.api.nvim_get_current_line()
      local marker = line:match("^(%s*[-*+] )")
      if marker then
        return "<CR>" .. marker
      end
      return "<CR>"
    end, { buffer = ev.buf, expr = true, desc = "New list item" })

    -- Ctrl+Right: indent list item by 2 spaces
    map({ "i", "n" }, "<C-Right>", function()
      local line = vim.api.nvim_get_current_line()
      if line:match("^%s*[-*+] ") then
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_set_current_line("  " .. line)
        vim.api.nvim_win_set_cursor(0, { row, col + 2 })
      end
    end, { buffer = ev.buf, desc = "Indent list item" })

    -- Ctrl+Left: dedent list item by 2 spaces
    map({ "i", "n" }, "<C-Left>", function()
      local line = vim.api.nvim_get_current_line()
      local dedented = line:match("^  (.*)")
      if dedented and dedented:match("^%s*[-*+] ") then
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_set_current_line(dedented)
        vim.api.nvim_win_set_cursor(0, { row, math.max(0, col - 2) })
      end
    end, { buffer = ev.buf, desc = "Dedent list item" })
  end,
})
