return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        unison = {
          cmd = vim.lsp.rpc.connect("127.0.0.1", 5757),
        },
      },
    },
  },
  {
    "unisonweb/unison",
    branch = "trunk",
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/editor-support/vim")
      require("lazy.core.loader").packadd(plugin.dir .. "/editor-support/vim")
    end,
    init = function(plugin)
      require("lazy.core.loader").ftdetect(plugin.dir .. "/editor-support/vim")
    end,
  },
}
