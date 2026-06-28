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

vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  pattern = "*.md",
  callback = function() vim.opt.laststatus = 0 end,
})

vim.api.nvim_create_autocmd("BufLeave", {
  group = augroup,
  pattern = "*.md",
  callback = function() vim.opt.laststatus = 3 end,
})

vim.api.nvim_create_autocmd("BufWriteCmd", {
  group = augroup,
  pattern = "*.md",
  callback = function(ev)
    local buf = ev.buf
    local path = vim.fn.expand("%:p")
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local last = #lines
    while last > 1 and lines[last]:match("^%s*$") do
      last = last - 1
    end
    local f = io.open(path, "w")
    if f then
      for i = 1, last do
        f:write(lines[i] .. "\n")
      end
      f:write("\n")
      f:close()
      vim.bo[buf].modified = false
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
    vim.highlight.on_yank({ timeout = 150 })
  end,
})
