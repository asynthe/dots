return {
  {
    "projekt0n/github-nvim-theme",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        transparent = true,
      },
    },
    config = function(_, opts)
      require("github-theme").setup(opts)
      vim.cmd.colorscheme("github_dark")
      vim.api.nvim_set_hl(0, "RenderMarkdownCode",     { bg = "#161b22" })
      vim.api.nvim_set_hl(0, "RenderMarkdownCodePwsh", { bg = "#0d1f33" })
    end,
  },
}
