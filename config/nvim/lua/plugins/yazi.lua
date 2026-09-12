return {
  {
    "mikavilpas/yazi.nvim",
    keys = {
      { "<leader>,", "<cmd>Yazi<CR>", desc = "Yazi at current file" },
      { "<leader>;", "<cmd>Yazi cwd<CR>", desc = "Yazi at cwd" },
    },
    opts = {
      open_for_directories = false,
    },
  },
}
