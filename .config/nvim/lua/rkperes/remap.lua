vim.g.mapleader = " "
--vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- makes <leader>p as p without overwriting buffer
vim.keymap.set("x", "<leader>p", [["_dP]])

-- copy/paste clipboard
--vim.keymap.set({"n", "v"}, "<leader>p", [["+p]])
--vim.keymap.set({"n", "v"}, "<leader>P", [["+P]])
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set({"n", "v"}, "<leader>Y", [["+Y]])

-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tms<CR>")

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

