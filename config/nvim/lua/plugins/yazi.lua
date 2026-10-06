return {
  {
    "mikavilpas/yazi.nvim",
    cmd = "Yazi",
    keys = {
      { "<leader>e", "<cmd>Yazi<CR>", desc = "Yazi" },
      { "<leader>nd", function() require("core.notes").daily_folder() end, desc = "Daily notes (yazi)" },
    },
    opts = {
      open_for_directories = false,
    },
  },
}
