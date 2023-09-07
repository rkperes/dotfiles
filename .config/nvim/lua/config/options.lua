-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- rust
opts = function(_, opts)
  local cmp = require("cmp")
  opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
    { name = "crates" },
  }))
end

opts = function(_, opts)
  if type(opts.ensure_installed) == "table" then
    vim.list_extend(opts.ensure_installed, { "ron", "rust", "toml" })
  end
end
