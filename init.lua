--Vim config
vim.opt.number = true          -- show line numbers
vim.opt.relativenumber = true  -- relative line numbers
vim.opt.tabstop = 4            -- tab width
vim.opt.shiftwidth = 4         -- indent width
vim.opt.expandtab = true       -- use spaces instead of tabs
vim.opt.smartindent = true     -- auto-indent new lines
vim.opt.wrap = false           -- no line wrapping
vim.opt.scrolloff = 10         -- keep 10 lines above/below cursor
vim.opt.sidescrolloff = 10
vim.opt.hlsearch = false       -- removes the annoying highlight

vim.opt.termguicolors = true
vim.opt.cursorline = true


-- I still have not found a way to enable Visual block mode with Ctrl v
vim.opt.clipboard = ""         -- Disables system clipboard

vim.g.mapleader = " "  -- space as leader


require("config/colorscheme")
require("config/statusline")
require("config/packageManager")
require("config/lspconfig")
