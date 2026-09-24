return {
  {
    "tris203/precognition.nvim",
    cmd = "Precognition",
    opts = {
      startVisible = false,
      showBlankVirtLine = false,
    },
    keys = {
      { "<leader>up", "<cmd>Precognition toggle<CR>", desc = "Toggle motion hints" },
      { "<leader>uP", "<cmd>Precognition peek<CR>", desc = "Peek motion hints" },
    },
  },
}
