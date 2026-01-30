vim.opt.rtp:append(".")
vim.opt.rtp:append("~/.local/share/nvim/lazy/plenary.nvim")

vim.cmd.runtime({ "plugin/plenary.vim", bang = true })
