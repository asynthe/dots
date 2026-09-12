local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })

map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<CR>", { desc = "Delete buffer, discard changes" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

local function toggle(name, on, off)
  return function()
    local cur = vim.opt_local[name]:get()
    vim.opt_local[name] = cur == on and off or on
    vim.notify(name .. " = " .. tostring(vim.opt_local[name]:get()))
  end
end

map("n", "<leader>uw", toggle("wrap", true, false), { desc = "Toggle wrap" })
map("n", "<leader>un", toggle("number", true, false), { desc = "Toggle line numbers" })
map("n", "<leader>ur", toggle("relativenumber", true, false), { desc = "Toggle relative numbers" })
map("n", "<leader>uc", toggle("conceallevel", 2, 0), { desc = "Toggle conceal" })
map("n", "<leader>ud", function()
  local on = not vim.diagnostic.is_enabled()
  vim.diagnostic.enable(on)
  vim.notify("diagnostics = " .. tostring(on))
end, { desc = "Toggle diagnostics" })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserMarkdownKeys", { clear = true }),
  pattern = "markdown",
  callback = function(ev)
    map("i", "<C-CR>", function()
      local marker = vim.api.nvim_get_current_line():match("^(%s*[-*+] )")
      return marker and ("<CR>" .. marker) or "<CR>"
    end, { buffer = ev.buf, expr = true, desc = "New list item" })
  end,
})
