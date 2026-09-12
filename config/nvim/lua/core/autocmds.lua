local augroup = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.foldenable = false
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "n"
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = "*.md",
  callback = function(ev)
    local buf = ev.buf
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local last = #lines
    while last > 1 and lines[last]:match("^%s*$") do
      last = last - 1
    end
    if last == #lines - 1 then
      return
    end
    local win = vim.fn.bufwinid(buf)
    local cursor = win ~= -1 and vim.api.nvim_win_get_cursor(win) or nil
    vim.api.nvim_buf_set_lines(buf, last, -1, false, { "" })
    if cursor then
      local count = vim.api.nvim_buf_line_count(buf)
      vim.api.nvim_win_set_cursor(win, { math.min(cursor[1], count), cursor[2] })
    end
  end,
})

local pwsh_ns = vim.api.nvim_create_namespace("pwsh_code_bg")
local pwsh_langs = { powershell = true, ps1 = true, pwsh = true }

local function apply_pwsh_bg(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, pwsh_ns, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local in_block = false
  for i, line in ipairs(lines) do
    local lang = line:match("^```%s*(%S+)")
    if not in_block and lang and pwsh_langs[lang:lower()] then
      in_block = true
    elseif in_block and line:match("^```%s*$") then
      in_block = false
    elseif in_block then
      vim.api.nvim_buf_set_extmark(bufnr, pwsh_ns, i - 1, 0, {
        end_row = i,
        hl_group = "RenderMarkdownCodePwsh",
        hl_eol = true,
        priority = 200,
      })
    end
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "TextChanged" }, {
  group = augroup,
  pattern = "*.md",
  callback = function(ev) apply_pwsh_bg(ev.buf) end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    (vim.hl or vim.highlight).on_yank({ timeout = 150 })
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
