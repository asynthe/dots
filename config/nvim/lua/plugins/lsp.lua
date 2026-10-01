local code_filetypes = {
  "python", "lua", "nix", "sh", "bash", "zsh",
  "rust", "go", "c", "cpp",
  "typescript", "typescriptreact", "javascript", "javascriptreact",
  "json", "jsonc", "yaml", "toml", "sql",
}

local servers = {
  nixd = "nixd",
  bashls = "bash-language-server",
  pyright = "pyright",
  rust_analyzer = "rust-analyzer",
  ts_ls = "typescript-language-server",
  lua_ls = "lua-language-server",
  gopls = "gopls",
  jsonls = "vscode-json-language-server",
  yamlls = "yaml-language-server",
}

return {
  {
    "neovim/nvim-lspconfig",
    ft = code_filetypes,
    config = function()
      local host = require("host")

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      for server, exe in pairs(servers) do
        if host.has(exe) then
          vim.lsp.enable(server)
        end
      end

      vim.diagnostic.config({
        virtual_text = { spacing = 2, prefix = "●" },
        severity_sort = true,
        float = { border = "rounded", source = true },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspKeys", { clear = true }),
        callback = function(ev)
          if vim.bo[ev.buf].filetype == "markdown" then return end
          vim.keymap.set("n", "gd", vim.lsp.buf.definition,
            { buffer = ev.buf, desc = "Goto definition" })
        end,
      })
    end,
  },
}
