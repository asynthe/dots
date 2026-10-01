return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      win = { border = "rounded" },
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "home" },
        { "<leader>n", group = "notes" },
        { "<leader>u", group = "ui" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "gs", group = "surround" },
      },
    },
  },
}
