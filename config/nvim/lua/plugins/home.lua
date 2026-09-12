-- Navigation for the $HOME layout in ~/git/dots/docs/HOME_STRUCTURE.md.
-- <leader>h<letter> mirrors the yazi `g<letter>` jumps, same letters.
-- (`<leader>g` is gitsigns; h is for home.)

local function goto_dir(path)
  return function()
    local dir = vim.fn.expand(path)
    vim.cmd.tcd(dir)
    require("fzf-lua").files({ cwd = dir })
  end
end

-- Every repo is ~/git/<name> (audioland nests one level), so a flat scan two
-- deep is the whole surface. Picks the repo, tcds into it, opens the file
-- picker there — the tab keeps its own cwd, so two repos can be open at once.
local function pick_repo()
  local repos = vim.fn.systemlist(
    [[find ~/git -mindepth 1 -maxdepth 2 -name .git -printf '%h\n' | sort]]
  )
  if vim.v.shell_error ~= 0 or #repos == 0 then
    vim.notify("no repos under ~/git", vim.log.levels.WARN)
    return
  end
  local home = vim.fn.expand("~")
  require("fzf-lua").fzf_exec(
    vim.tbl_map(function(r) return (r:gsub("^" .. vim.pesc(home) .. "/git/", "")) end, repos),
    {
      prompt = "repo> ",
      actions = {
        ["default"] = function(selected)
          if not selected or not selected[1] then return end
          local dir = home .. "/git/" .. selected[1]
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
      { "<leader>fp", pick_repo,                     desc = "Pick repo (~/git)" },
      { "<leader>hh", goto_dir("~/git"),             desc = "git — all repos" },
      { "<leader>hd", goto_dir("~/git/dots"),        desc = "dots — laptop nixos" },
      { "<leader>hf", goto_dir("~/git/flakes"),      desc = "flakes — sarten" },
      { "<leader>hn", goto_dir("~/git/notes"),       desc = "notes" },
      { "<leader>hb", goto_dir("~/ben"),             desc = "ben — personal" },
      { "<leader>ha", goto_dir("~/archive"),         desc = "archive" },
      { "<leader>hc", goto_dir("~/.config"),         desc = "config" },
    },
  },
}
