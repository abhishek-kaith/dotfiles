-- Interface Settings
vim.opt.number = true         -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.cursorline = true     -- Highlight current line
vim.wo.signcolumn = "yes"     -- Always show signcolumn (for Git, LSP, etc.)
vim.opt.wrap = false          -- Don't wrap long lines
vim.opt.scrolloff = 10        -- Minimum lines above/below cursor
vim.opt.colorcolumn = "80"    -- Style Guide Vertical Line to guide lenght of code

-- Visuals & Characters
vim.o.termguicolors = true -- Enable full RGB color support
vim.opt.list = true -- Show invisible characters
vim.opt.listchars = {
  tab = "» ", -- Show tabs as »
  trail = "·", -- Show trailing spaces
  nbsp = "␣", -- Show non-breaking space
}

-- Tabs & Indentation
vim.o.tabstop = 2        -- Tab character = 2 spaces (visually)
vim.o.expandtab = true   -- Pressing <Tab> inserts spaces
vim.o.softtabstop = 2    -- Tab key = 2 spaces
vim.o.shiftwidth = 2     -- Indentation = 2 spaces
vim.o.breakindent = true -- Indent wrapped lines properly

-- Search Behavior
vim.o.hlsearch = true   -- Don't highlight matches by default
vim.o.ignorecase = true -- Ignore case when searching...
vim.o.smartcase = true  -- ...unless capital letters are used

-- Clipboard & Undo
vim.o.clipboard = "unnamedplus" -- Use system clipboard (works with Ctrl+C / Ctrl+V)
vim.o.undofile = true           -- Save undo history to disk
vim.o.swapfile = false          -- Disable swap file

-- Mouse & Splits
vim.o.mouse = "a"         -- Enable mouse in all modes
vim.opt.splitright = true -- Vertical splits open to the right
vim.opt.splitbelow = true -- Horizontal splits open below

-- Command Behavior
vim.opt.inccommand =
"split"                                -- Show live preview of substitutions eg. %s/foo/bar/g open new split at bottom with live preview
vim.o.completeopt = "menuone,noselect" -- Better completion experience

-- Performance Tweaks
vim.o.updatetime = 250 -- Faster CursorHold, LSP updates, etc.
vim.o.timeoutlen = 300 -- Timeout for mapped sequence

-- Plugins
vim.pack.add({
  -- theme
  { src = "https://github.com/vague2k/vague.nvim" },
  -- naviagation
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/cbochs/grapple.nvim" },

  -- lsp
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
  -- autocomplete with snippets
  { src = "https://github.com/Saghen/blink.cmp",                         version = "v1.6.0" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  -- Syntax highlight
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  -- Git
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
})

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

require("fzf-lua").setup({ 'fzf-native' })
require("grapple").setup({
  icons = false
})
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
  ensure_installed = {
    "lua_ls",
    "stylua",
    "ts_ls",
    "tailwindcss",
    "clangd"
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = {
          "vim",
          "require",
        },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

require("luasnip.loaders.from_vscode").lazy_load()
-- Use C f and C b to read docs
require("blink.cmp").setup({
  signature = {
    enabled = true
  },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
    menu = {
      auto_show = true,
      draw = {
        treesitter = { "lsp" },
        columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
      },
    },
  },
})

require 'nvim-treesitter.configs'.setup {
  ensure_installed = {},
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  modules = {},
  highlight = {
    enable = true,
    ---@diagnostic disable-next-line: unused-local
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-space>",
      node_incremental = "<C-space>",
      scope_incremental = false,
      node_decremental = "<bs>",
    },
  },
}

require("gitsigns").setup()
