vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

local shell = { buf = nil, win = nil }

local function new_shell_win(buf)
    opts = { split = "below", height = 10, win = 0 }
    return vim.api.nvim_open_win(buf, true, opts)
end

local function focus_shell_window()
    if shell.buf and vim.api.nvim_buf_is_valid(shell.buf) then
        if shell.win and vim.api.nvim_win_is_valid(shell.win) then
            vim.api.nvim_set_current_win(shell.win)
        else
            shell.win = new_shell_win(shell.buf)
        end
    else
        shell.buf = vim.api.nvim_create_buf(false, true)
        shell.win = new_shell_win(shell.buf)
        vim.cmd.term()
    end
end

vim.keymap.set("n", "<Esc>", function() 
    if shell.win == vim.api.nvim_get_current_win() then
        vim.api.nvim_win_hide(shell.win)
    end
end)

vim.keymap.set("n", "<leader>p$", function()
    focus_shell_window()
    vim.cmd('startinsert')
end)

vim.keymap.set("n", "<leader>fR", function()
    local buffer_path = vim.fn.expand("%:p")
    local buffer_dir = vim.fn.expand("%:p:h")
    focus_shell_window()
    local jobid = vim.bo.channel
    local cmd = string.format("mv %s %s/", buffer_path, buffer_dir)
    vim.fn.chansend(jobid, cmd)
    vim.cmd('startinsert')
end)
