local function goto_dir(path)
  return function()
    local dir = vim.fn.expand(path)
    vim.cmd.tcd(dir)
    require("fzf-lua").files({ cwd = dir })
  end
end

local git = require("host").git_root

local function pick_repo()
  local repos = {}
  for _, pat in ipairs({ "/*/.git", "/*/*/.git" }) do
    for _, g in ipairs(vim.fn.glob(git .. pat, true, true)) do
      table.insert(repos, vim.fs.dirname(vim.fs.normalize(g)))
    end
  end
  table.sort(repos)
  if #repos == 0 then
    vim.notify("no repos under " .. git, vim.log.levels.WARN)
    return
  end
  require("fzf-lua").fzf_exec(
    vim.tbl_map(function(r) return (r:gsub("^" .. vim.pesc(git) .. "/", "")) end, repos),
    {
      prompt = "repo> ",
      actions = {
        ["default"] = function(selected)
          if not selected or not selected[1] then return end
          local dir = git .. "/" .. selected[1]
          vim.cmd.tcd(dir)
          require("fzf-lua").files({ cwd = dir })
        end,
      },
    }
  )
end

return {
  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<leader>fp", pick_repo,                 desc = "Pick repo" },
      { "<leader>hd", goto_dir(git .. "/dots"),  desc = "dots" },
      { "<leader>hn", goto_dir(git .. "/notes"), desc = "notes" },
      { "<leader>hb", goto_dir("~/ben"),        desc = "ben" },
      { "<leader>ha", goto_dir("~/archive"),    desc = "archive" },
    },
  },
}
