-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        'killitar/obscure.nvim',
        { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
        { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = {'nvim-lua/plenary.nvim'} },
        { "nvim-telescope/telescope-file-browser.nvim", dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" } },
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' },
        { 'ThePrimeagen/harpoon', dependencies = {'nvim-lua/plenary.nvim'} },
    },
    -- disable `luarocks` support completely
    rocks = { enabled = false },
    -- automatically check for plugin updates
    checker = { enabled = true },
})

-- Color scheme
vim.cmd("colorscheme obscure")
-- transparent background
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'none' })

-- Setup treesitter
require('nvim-treesitter.configs').setup {
    -- A list of parser names, or "all" (the listed parsers MUST always be installed)
    ensure_installed = { "lua", "python" },
    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- Automatically install missing parsers when entering buffer
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
}

-- Setup telescope
require('telescope').setup {
    pickers = {
        find_files = {theme = "ivy" },
        buffers = {theme = "ivy" },
    },
    extensions = { file_browser = { theme = "ivy" } },
}
require('telescope').load_extension('fzf')
require("telescope").load_extension('file_browser')
require('telescope.themes').get_ivy()
vim.keymap.set('n', '<leader>pf', require('telescope.builtin').find_files, {})
vim.keymap.set('n', '<leader>ff', function()
    require('telescope').extensions.file_browser.file_browser({cwd = vim.fn.expand("%:p:h")})
end)
vim.keymap.set('n', '<leader>bb', require('telescope.builtin').buffers, {})
vim.keymap.set('n', '<leader>ps', function()
    require('telescope.builtin').grep_string({ search = vim.fn.input("Grep > ") });
end)

-- Setup harpoon
vim.keymap.set("n", "<leader>a", require('harpoon.mark').add_file)
vim.keymap.set("n", "<C-e>", require('harpoon.ui').toggle_quick_menu)
vim.keymap.set("n", "<C-j>", function() require('harpoon.ui').nav_file(1) end)
vim.keymap.set("n", "<C-k>", function() require('harpoon.ui').nav_file(2) end)
vim.keymap.set("n", "<C-l>", function() require('harpoon.ui').nav_file(3) end)
vim.keymap.set("n", "<C-;>", function() require('harpoon.ui').nav_file(4) end)
