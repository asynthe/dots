return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
      { "<leader>.",  function() require("core.notes").picker() end, desc = "fzf: open note" },
      { "<leader>zf", "<cmd>FzfLua files<CR>",                       desc = "fzf: files" },
      { "<leader>zg", "<cmd>FzfLua live_grep<CR>",                   desc = "fzf: live grep" },
      { "<leader>zb", "<cmd>FzfLua buffers<CR>",                     desc = "fzf: buffers" },
    },
    opts = {},
  },
}
