return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local host = require("host")

      local servers = {
        nixd = "nixd",
        bashls = "bash-language-server",
        pyright = "pyright",
        rust_analyzer = "rust-analyzer",
        ts_ls = "typescript-language-server",
        marksman = "marksman",
        lua_ls = "lua-language-server",
        gopls = "gopls",
        jsonls = "vscode-json-language-server",
        yamlls = "yaml-language-server",
      }

      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

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

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(ev)
          local function map(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
          end
          map("gd", "<cmd>FzfLua lsp_definitions<CR>", "Goto definition")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("gI", "<cmd>FzfLua lsp_implementations<CR>", "Goto implementation")
          map("gY", "<cmd>FzfLua lsp_typedefs<CR>", "Goto type definition")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cs", "<cmd>FzfLua lsp_document_symbols<CR>", "Document symbols")
          map("<leader>cS", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", "Workspace symbols")
          map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
          map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
        end,
      })

      vim.diagnostic.config({
        virtual_text = { spacing = 2, prefix = "●" },
        severity_sort = true,
        float = { border = "rounded", source = true },
      })
    end,
  },
}
