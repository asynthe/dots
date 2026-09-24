return {
  {
    "echasnovski/mini.align",
    version = false,
    keys = { { "ga", mode = { "n", "v" } }, { "gA", mode = { "n", "v" } } },
    config = function()
      require("mini.align").setup()
    end,
  },
  {
    "echasnovski/mini.ai",
    version = false,
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function()
      local ai = require("mini.ai")
      ai.setup({
        n_lines = 500,
        custom_textobjects = {
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
        },
      })
    end,
  },
  {
    "echasnovski/mini.surround",
    version = false,
    keys = {
      { "sa", mode = { "n", "v" } },
      { "sd" },
      { "sr" },
      { "sf" },
      { "sF" },
      { "sh" },
    },
    config = function()
      require("mini.surround").setup()
    end,
  },
}
