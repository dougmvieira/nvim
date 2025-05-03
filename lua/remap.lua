vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- move block in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- J without moving the cursor
vim.keymap.set("n", "J", "mzJ`z")

-- paste over selection without overriding clipboard
vim.keymap.set("x", "<leader>p", "\"_dP")

-- I don't know what these are for
-- vim.keymap.set("n", "<leader>d", "\"_d")
-- vim.keymap.set("v", "<leader>d", "\"_d")

-- Avoid getting stuck
vim.keymap.set("n", "Q", "<nop>")

-- vim.keymap.set("n", "<leader>f", function()
--     vim.lsp.buf.format()
-- end)

-- Quickfix list
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Find current selection and replace with user input
vim.keymap.set("v", "<leader>r", '"hy:%s/\\v<C-r>h//g<left><left>')
