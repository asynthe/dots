return {
  {
    "echasnovski/mini.align",
    version = false,
    keys = { { "ga", mode = { "n", "v" } }, { "gA", mode = { "n", "v" } } },
    config = function()
      require("mini.align").setup()
    end,
  },
}
