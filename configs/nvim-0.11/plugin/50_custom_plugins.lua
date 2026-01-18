-- ┌────────────────────┐
-- │ Custom Plugins     │
-- └────────────────────┘
--
-- This file contains custom plugins added to MiniMax configuration.
-- These are user-specific plugins not part of the base MiniMax setup.
--
-- Custom plugins defined here:
-- - mason.nvim & mason-lspconfig.nvim - LSP server management
-- - clipboard-image.nvim - Paste images from clipboard
-- - Spell checking setup - Custom spell check commands
-- - opencode.nvim - AI-powered code assistant
--
-- Note: Keymaps for these plugins are defined in 'plugin/20_keymaps.lua'

-- Make concise helpers for installing/adding plugins in two stages
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = _G.Config.now_if_args

-- Mason LSP Management =======================================================

-- Mason is a package manager for LSP servers, formatters, and linters.
-- Mason-lspconfig bridges Mason and nvim-lspconfig for easier setup.
--
-- Commands provided:
-- - :Mason - Open Mason UI for managing packages
-- - :LspInstall <server> - Install a language server
-- - :LspUninstall <server> - Uninstall a language server
--
-- See also:
-- - `:h mason.nvim`
-- - `:h mason-lspconfig.nvim`
-- - https://github.com/mason-org/mason.nvim
now_if_args(function()
  add('mason-org/mason.nvim')
  add('mason-org/mason-lspconfig.nvim')

  -- Setup Mason first
  require('mason').setup()

  -- Setup mason-lspconfig to bridge Mason and nvim-lspconfig
  -- This provides commands like :LspInstall, :LspUninstall
  require('mason-lspconfig').setup({
    -- Automatically install these language servers
    ensure_installed = {
      -- Add language servers you want auto-installed here
      -- 'lua_ls',
      -- 'pyright',
      -- 'ts_ls',
    },
    -- Automatically setup installed servers with default config
    automatic_installation = false,
  })
end)

-- Clipboard Image ============================================================

-- Paste images from clipboard into markdown and other formats
-- Usage: In Insert mode, paste an image from clipboard and it will be saved
-- to the configured directory and a reference will be inserted.
later(function()
  add('dfendr/clipboard-image.nvim')

  local home = os.getenv('HOME')
  require('clipboard-image').setup({
    -- Default configuration for all filetype
    default = {
      img_dir = 'images',
      img_name = function()
        return vim.fn.input('Name > ')
      end,
      affix = '<\n  %s\n>', -- Multi lines affix
    },
    -- Configuration for markdown files
    markdown = {
      img_dir = { home, 'src', 'jarv', 'jarv.org', 'static', 'img' },
      img_dir_txt = '/img',
      img_handler = function(img)
        local script = string.format('%s/src/jarv/jarv.org/bin/convert %s', home, img.path)
        os.execute(script)
      end,
    },
  })
end)

-- Spell Checking =============================================================

-- Custom spell checking commands and configuration
-- Note: MiniMax uses mini.completion which doesn't need cmp-spell plugin
-- This just adds the spell commands and configuration
--
-- Commands:
-- - :Spell - Enable spell checking
-- - :NoSpell - Disable spell checking
-- - :SpellToggle - Toggle spell checking
later(function()
  vim.opt.spell = true
  vim.opt.spelllang = { 'en_us' }

  -- Enable spell
  vim.api.nvim_create_user_command('Spell', function()
    vim.cmd('set spell')
  end, {})

  -- Disable spell
  vim.api.nvim_create_user_command('NoSpell', function()
    vim.cmd('set nospell')
  end, {})

  -- Toggle spell
  vim.api.nvim_create_user_command('SpellToggle', function()
    vim.cmd('set invspell')
  end, {})

  -- Enable spell checking for markdown files by default
  _G.Config.new_autocmd('FileType', 'markdown', function()
    vim.cmd('Spell')
  end, 'Enable spell for markdown')
end)

-- OpenCode ===================================================================

-- AI-powered code assistant for Neovim
-- Provides intelligent code suggestions, explanations, and modifications.
--
-- Keymaps are defined in 'plugin/20_keymaps.lua' under "Custom Keymap Additions"
-- Main keymaps:
-- - <Leader>ca - Ask OpenCode a question
-- - <Leader>ct - Toggle OpenCode panel
-- - <Leader>cx - Execute an OpenCode action
-- - <Leader>cp - Add to OpenCode prompt
-- - <Leader>cu/cd - Scroll up/down in OpenCode
-- - <Leader>cgg/cG - Jump to first/last message
--
-- See also:
-- - `:h opencode` (if available)
-- - https://github.com/NickvanDyke/opencode.nvim
later(function()
  add('NickvanDyke/opencode.nvim')
  add({ source = 'folke/snacks.nvim' })

  -- Setup snacks for input and picker (required by OpenCode)
  require('snacks').setup({ input = {}, picker = {} })

  -- OpenCode configuration
  vim.o.autoread = true
  vim.g.opencode_opts = {
    provider = {
      enabled = 'wezterm',
      wezterm = {
        direction = 'right', -- "left" | "right" | "top" | "bottom"
        top_level = false,   -- false = split current pane, true = split entire window
        percent = 40,        -- Size percentage (40% of available space)
      },
    },
  }
end)
