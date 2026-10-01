local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "[q", "<cmd>cprevious<CR>", { desc = "Previous quickfix" })
map("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })

map("n", "[e", "<cmd>move -2<CR>==", { desc = "Move line up" })
map("n", "]e", "<cmd>move +1<CR>==", { desc = "Move line down" })
map("x", "[e", ":move '<-2<CR>gv=gv", { desc = "Move selection up" })
map("x", "]e", ":move '>+1<CR>gv=gv", { desc = "Move selection down" })

map("x", "<", "<gv")
map("x", ">", ">gv")

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
map("n", "<leader>.", function() require("core.notes").picker() end, { desc = "Open note" })
map("n", "<leader>c", function() require("core.code").picker() end, { desc = "Recent code" })

local function toggle(name, on, off)
  return function()
    local cur = vim.opt_local[name]:get()
    vim.opt_local[name] = cur == on and off or on
    vim.notify(name .. " = " .. tostring(vim.opt_local[name]:get()))
  end
end

map("n", "<leader>uw", toggle("wrap", true, false), { desc = "Wrap" })
map("n", "<leader>uc", toggle("conceallevel", 2, 0), { desc = "Conceal" })

map("n", "<leader>un", function()
  local num, rel = vim.wo.number, vim.wo.relativenumber
  if not num and not rel then
    vim.wo.number = true
  elseif num and not rel then
    vim.wo.relativenumber = true
  else
    vim.wo.number, vim.wo.relativenumber = false, false
  end
end, { desc = "Cycle line numbers" })

map("n", "<leader>ud", function()
  local on = not vim.diagnostic.is_enabled()
  vim.diagnostic.enable(on)
  vim.notify("diagnostics = " .. tostring(on))
end, { desc = "Diagnostics" })
