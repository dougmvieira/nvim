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
        'mbbill/undotree',
        {'williamboman/mason.nvim'},
        {'williamboman/mason-lspconfig.nvim'},
        {'neovim/nvim-lspconfig'},
        {'folke/lazydev.nvim'},
        {'hrsh7th/cmp-nvim-lsp'},
        {'hrsh7th/nvim-cmp'},
        { "3rd/image.nvim", build = false },
        { "benlubas/molten-nvim", version = "^1.0.0", dependencies = { "3rd/image.nvim" }, build = ":UpdateRemotePlugins", },
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
---@diagnostic disable-next-line: missing-fields
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

-- Setup LSP
-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end,
})

require('mason').setup({})
---@diagnostic disable-next-line: missing-fields
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  ensure_installed = { "lua_ls", "pyright" },
  }
})
---@diagnostic disable-next-line: missing-fields
require('lazydev').setup({
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
})

---
-- Autocompletion config
---
local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  }),
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
})

-- molten and its dependencies
---@diagnostic disable-next-line: missing-fields
require("image").setup({
  backend = "kitty",
  processor = "magick_cli",
  integrations = {}, -- do whatever you want with image.nvim's integrations
  max_width = 100, -- tweak to preference
  max_height = 12, -- ^
  max_height_window_percentage = math.huge, -- this is necessary for a good experience
  max_width_window_percentage = math.huge,
  window_overlap_clear_enabled = true,
  window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
})
vim.g.molten_image_provider = "image.nvim"
vim.g.molten_output_win_max_height = 20
vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>",
    { silent = true, desc = "Initialize the plugin" })
vim.keymap.set("n", "<leader>e", ":MoltenEvaluateOperator<CR>",
    { silent = true, desc = "run operator selection" })
vim.keymap.set("n", "<leader>rl", ":MoltenEvaluateLine<CR>",
    { silent = true, desc = "evaluate line" })
vim.keymap.set("n", "<leader>rr", ":MoltenReevaluateCell<CR>",
    { silent = true, desc = "re-evaluate cell" })
vim.keymap.set("v", "<leader>r", ":<C-u>MoltenEvaluateVisual<CR>gv",
    { silent = true, desc = "evaluate visual selection" })
