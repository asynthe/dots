return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>.",  function() require("core.notes").picker() end, desc = "Open note" },
      { "<leader>nn", "<cmd>Obsidian new<CR>",           desc = "New note" },
      { "<leader>nm", "<cmd>edit ~/git/notes/main.md<CR>",   desc = "Open main.md" },
      { "<leader>nt", "<cmd>Obsidian today<CR>",         desc = "Today's daily note" },
      { "<leader>ny", "<cmd>Obsidian yesterday<CR>",     desc = "Yesterday's daily note" },
      { "<leader>ns", "<cmd>Obsidian search<CR>",        desc = "Search notes" },
      { "<leader>nq", "<cmd>Obsidian quick_switch<CR>",  desc = "Quick switch note" },
      { "<leader>nb", "<cmd>Obsidian backlinks<CR>",     desc = "Backlinks" },
      { "<leader>nl", "<cmd>Obsidian links<CR>",         desc = "Links in note" },
      { "<leader>no", "<cmd>Obsidian toc<CR>",           desc = "Table of contents" },
      { "<leader>nx", "<cmd>Obsidian toggle_checkbox<CR>", desc = "Toggle checkbox" },
      { "<leader>np", "<cmd>Obsidian paste_img<CR>",     desc = "Paste image" },
      { "<leader>nr", "<cmd>Obsidian rename<CR>",        desc = "Rename note" },
    },
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "main",
          path = "~/git/notes",
        },
      },
      picker = { name = "fzf-lua" },
    },
  },
}
