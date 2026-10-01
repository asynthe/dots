return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeOpen" },
    keys = {
      { "<leader>t", "<cmd>NvimTreeToggle<CR>", desc = "File tree" },
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
