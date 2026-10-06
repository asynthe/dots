local function toggle()
  local file = vim.api.nvim_buf_get_name(0)
  local path
  if file ~= "" and vim.bo.buftype == "" then
    path = vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(file)))
  end
  require("nvim-tree.api").tree.toggle({ path = path, find_file = path ~= nil, focus = true })
end

return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeOpen" },
    keys = {
      { "<leader>t", toggle, desc = "File tree" },
    },
    opts = {
      hijack_netrw = false,
      disable_netrw = false,
      view = { width = 32, side = "left" },
      renderer = {
        indent_markers = { enable = true },
        icons = { git_placement = "after" },
      },
      filters = { dotfiles = false, custom = { "^.git$" } },
      git = { enable = true },
      actions = { open_file = { quit_on_open = false, resize_window = false } },
    },
  },
}
