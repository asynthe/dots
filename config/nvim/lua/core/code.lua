local M = {}

local notes = { md = true, markdown = true, mdx = true }

local function project_root(path)
  local dir = vim.fs.dirname(path)
  local marker = vim.fs.find({ ".git", "flake.nix", "Cargo.toml", "package.json" },
    { path = dir, upward = true })[1]
  return marker and vim.fs.dirname(marker) or dir
end

local function recent_code()
  local out, seen = {}, {}
  local home = vim.fn.expand("~")
  for _, path in ipairs(vim.v.oldfiles) do
    local ext = (path:match("%.([%w_]+)$") or ""):lower()
    if not seen[path]
      and not notes[ext]
      and not path:match("/%.git/")
      and not path:match("^/tmp/")
      and vim.uv.fs_stat(path)
    then
      seen[path] = true
      table.insert(out, (path:gsub("^" .. vim.pesc(home), "~")))
    end
  end
  return out
end

function M.picker()
  local files = recent_code()
  if #files == 0 then
    vim.notify("no recent code files", vim.log.levels.WARN)
    return
  end
  require("fzf-lua").fzf_exec(files, {
    prompt = "code> ",
    actions = {
      ["default"] = function(sel)
        if not sel or not sel[1] then return end
        M.open(vim.fn.expand(sel[1]))
      end,
    },
  })
end

function M.open(path)
  vim.cmd.tcd(project_root(path))
  vim.cmd.edit(vim.fn.fnameescape(path))
  local ok, api = pcall(require, "nvim-tree.api")
  if not ok then return end
  local win = vim.api.nvim_get_current_win()
  api.tree.find_file({ open = true, focus = false })
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
  end
end

return M
