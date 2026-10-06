local markdown_maps = {
  { "<leader>ny", "<cmd>Obsidian yesterday<CR>",       "Yesterday's note" },
  { "<leader>ns", "<cmd>Obsidian search<CR>",          "Search notes" },
  { "<leader>nq", "<cmd>Obsidian quick_switch<CR>",    "Quick switch" },
  { "<leader>nb", "<cmd>Obsidian backlinks<CR>",       "Backlinks" },
  { "<leader>nl", "<cmd>Obsidian links<CR>",           "Links in note" },
  { "<leader>no", "<cmd>Obsidian toc<CR>",             "Table of contents" },
  { "<leader>nx", "<cmd>Obsidian toggle_checkbox<CR>", "Toggle checkbox" },
  { "<leader>np", "<cmd>Obsidian paste_img<CR>",       "Paste image" },
  { "<leader>nr", "<cmd>Obsidian rename<CR>",          "Rename note" },
}

local function attach(buf)
  for _, m in ipairs(markdown_maps) do
    vim.keymap.set("n", m[1], m[2], { buffer = buf, desc = m[3] })
  end
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>nn", "<cmd>Obsidian new<CR>",   desc = "New note" },
      { "<leader>nt", "<cmd>Obsidian today<CR>", desc = "Today's note" },
    },
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "main",
          path = require("host").git_root .. "/notes",
        },
      },
      picker = { name = "fzf-lua" },
      ui = { enable = false },
      daily_notes = {
        folder = "daily",
        date_format = "YYYYMMDD_[notes]",
      },
    },
    config = function(_, opts)
      require("obsidian").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserObsidianKeys", { clear = true }),
        pattern = "markdown",
        callback = function(ev) attach(ev.buf) end,
      })
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == "markdown" then attach(buf) end
      end
    end,
  },
}
