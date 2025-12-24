return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      -- your explorer configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      filters = {
        dotfiles = false, -- REQUIRED
        custom = function(entry)
          -- hide other dot-directories if desired
          if entry.name:sub(1, 1) == "." and entry.name ~= ".dagger" then
            return true -- hide
          end
        end,
      },
    },
    picker = {
      sources = {
        explorer = {
          -- your explorer picker configuration comes here
          -- or leave it empty to use the default settings
          auto_close = false,
        },
      },
    },
  },
}
