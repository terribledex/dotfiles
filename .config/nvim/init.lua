-- ~/.config/nvim/init.lua
vim.opt.number = true              -- Показывать номера строк
vim.opt.relativenumber = true      -- Относительные номера строк
vim.opt.cursorline = true          -- Подсвечивать текущую строку
vim.opt.wrap = false               -- Не переносить строки
vim.opt.scrolloff = 8              -- Отступ при скроллинге
vim.opt.sidescrolloff = 8          -- Горизонтальный отступ
vim.opt.mouse = 'a'                -- Поддержка мыши
vim.opt.clipboard = 'unnamedplus'  -- Системный буфер обмена
vim.opt.ignorecase = true          -- Игнорировать регистр при поиске
vim.opt.smartcase = true           -- Умный поиск с учетом регистра
vim.opt.hlsearch = true            -- Подсвечивать результаты поиска
vim.opt.incsearch = true           -- Поиск по мере ввода
vim.opt.expandtab = true           -- Использовать пробелы вместо табов
vim.opt.tabstop = 4                -- Размер таба
vim.opt.softtabstop = 4            -- Размер таба при редактировании
vim.opt.shiftwidth = 4             -- Размер отступа
vim.opt.autoindent = true          -- Автоотступы
vim.opt.smartindent = true         -- Умные отступы
vim.opt.termguicolors = true       -- True color поддержка
vim.opt.showmode = false           -- Не показывать режим (будет в statusline)

-- Настройка statusline и winbar
vim.opt.laststatus = 2             -- Всегда показывать statusline
vim.opt.winbar = '%f'              -- Показывать имя файла в winbar

-- Функция для показа режима с цветами
local function get_mode()
  local modes = {
    ['n'] = { 'NORMAL', 'Normal' },
    ['i'] = { 'INSERT', 'Insert' },
    ['v'] = { 'VISUAL', 'Visual' },
    ['V'] = { 'V-LINE', 'Visual' },
    [''] = { 'V-BLOCK', 'Visual' },
    ['c'] = { 'COMMAND', 'Command' },
    ['R'] = { 'REPLACE', 'Replace' },
    ['t'] = { 'TERMINAL', 'Terminal' }
  }
  local mode_info = modes[vim.fn.mode()] or { 'UNKNOWN', 'Normal' }
  return mode_info[1]
end

-- Функция для получения git branch
local function get_git_branch()
  local handle = io.popen('git branch --show-current 2>/dev/null')
  if handle then
    local branch = handle:read("*a"):gsub("\n", "")
    handle:close()
    return branch ~= "" and " " .. branch or ""
  end
  return ""
end

-- Функция для красивого winbar с иконками
local function get_winbar()
  local filename = vim.fn.expand('%:t')
  if filename == '' then
    return ' [No Name]'
  end
  
  local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')
  local icon = ''
  if devicons_ok then
    local file_icon, _ = devicons.get_icon(filename, vim.fn.expand('%:e'), { default = true })
    icon = file_icon and (file_icon .. ' ') or ''
  end
  
  local modified = vim.bo.modified and ' ●' or ''
  return string.format(' %s%s%s', icon, filename, modified)
end

-- Делаем функции доступными глобально
_G.get_mode = get_mode
_G.get_git_branch = get_git_branch
_G.get_winbar = get_winbar

-- Менеджер пакетов (встроенный в Neovim 0.8+)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Плагины
require("lazy").setup({
  -- Цветовая схема Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        integrations = {
          treesitter = true,
          native_lsp = {
            enabled = true,
          },
          which_key = true,
        },
        custom_highlights = function(colors)
          return {
            -- Настройка statusline
            StatusLine = { bg = colors.mantle, fg = colors.text },
            StatusLineNC = { bg = colors.crust, fg = colors.overlay0 },
            
            -- Настройка winbar
            WinBar = { bg = colors.base, fg = colors.text, style = { "bold" } },
            WinBarNC = { bg = colors.mantle, fg = colors.overlay1 },
            
            -- Кастомные highlight группы для statusline
            StatusLineMode = { bg = colors.blue, fg = colors.mantle, style = { "bold" } },
            StatusLineModeInsert = { bg = colors.green, fg = colors.mantle, style = { "bold" } },
            StatusLineModeVisual = { bg = colors.mauve, fg = colors.mantle, style = { "bold" } },
            StatusLineModeCommand = { bg = colors.peach, fg = colors.mantle, style = { "bold" } },
            StatusLineModeReplace = { bg = colors.red, fg = colors.mantle, style = { "bold" } },
            StatusLineGit = { bg = colors.surface0, fg = colors.lavender },
            StatusLineFile = { bg = colors.surface1, fg = colors.text },
            StatusLinePosition = { bg = colors.surface2, fg = colors.subtext1 },
          }
        end,
      })
      vim.cmd.colorscheme "catppuccin"
      
      -- Настройка statusline с цветами после загрузки темы
      vim.opt.statusline = table.concat({
        '%#StatusLineMode# %{v:lua.get_mode()} %*',
        '%#StatusLineGit#%{v:lua.get_git_branch()}%*',
        '%#StatusLineFile# %f %*',
        '%m%r%h%w',
        '%=',
        '%#StatusLinePosition# %l:%c | %p%% | %Y %*'
      }, '')
      
      -- Настройка winbar с обрамлением и иконками
      vim.opt.winbar = '▎%{v:lua.get_winbar()}'
    end,
  },

  -- Иконки для файлов
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup({
        default = true,
      })
    end,
  },

  -- Подсветка синтаксиса
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "python", "go", "bash", "html", "css", 
          "markdown", "yaml", "toml", "dockerfile",
          "lua", "vim", "vimdoc", "javascript", "typescript"
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },

  -- Which-key для контекстного меню
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      timeout = true,
      timeoutlen = 1000,
    },
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "modern",
        delay = 1000,
        expand = 1,
        notify = false,
        win = {
          border = "rounded",
          padding = { 1, 2 },
        },
      })

      -- Дополнительные полезные привязки
      wk.add({
        { "<leader>f", group = "File" },
        { "<leader>ff", "<cmd>find<cr>", desc = "Find file" },
        { "<leader>fr", "<cmd>e!<cr>", desc = "Reload file" },
        { "<leader>fs", "<cmd>w<cr>", desc = "Save file" },
        { "<leader>fq", "<cmd>q<cr>", desc = "Quit" },
        
        { "<leader>w", group = "Window" },
        { "<leader>wh", "<C-w>h", desc = "Go to left window" },
        { "<leader>wj", "<C-w>j", desc = "Go to down window" },
        { "<leader>wk", "<C-w>k", desc = "Go to up window" },
        { "<leader>wl", "<C-w>l", desc = "Go to right window" },
        { "<leader>ws", "<cmd>split<cr>", desc = "Horizontal split" },
        { "<leader>wv", "<cmd>vsplit<cr>", desc = "Vertical split" },
        { "<leader>wq", "<C-w>q", desc = "Close window" },
        
        { "<leader>b", group = "Buffer" },
        { "<leader>bn", "<cmd>bnext<cr>", desc = "Next buffer" },
        { "<leader>bp", "<cmd>bprev<cr>", desc = "Previous buffer" },
        { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete buffer" },
      })
    end,
  },
})

-- Базовые привязки клавиш
vim.g.mapleader = " "              -- Leader клавиша

-- Очистка поиска по Esc
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Перемещение по строкам с переносом
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Быстрое сохранение
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")

-- Быстрый выход
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>")

-- Навигация по окнам
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j") 
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Настройки для разных типов файлов
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "javascript", "typescript" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Автокоманды для улучшения UX
-- Запомнить позицию курсора
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local last_pos = vim.fn.line("'\"")
    if last_pos > 0 and last_pos <= vim.fn.line("$") then
      vim.api.nvim_win_set_cursor(0, {last_pos, 0})
    end
  end,
})

-- Подсветка при копировании
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Динамическое обновление statusline в зависимости от режима
vim.api.nvim_create_autocmd({ "ModeChanged", "BufEnter" }, {
  callback = function()
    local mode = vim.fn.mode()
    local mode_hl = "StatusLineMode"
    
    if mode == "i" then
      mode_hl = "StatusLineModeInsert"
    elseif mode == "v" or mode == "V" or mode == "" then
      mode_hl = "StatusLineModeVisual"
    elseif mode == "c" then
      mode_hl = "StatusLineModeCommand"
    elseif mode == "R" then
      mode_hl = "StatusLineModeReplace"
    end
    
    vim.opt.statusline = table.concat({
      '%#' .. mode_hl .. '# %{v:lua.get_mode()} %*',
      '%#StatusLineGit#%{v:lua.get_git_branch()}%*',
      '%#StatusLineFile# %f %*',
      '%m%r%h%w',
      '%=',
      '%#StatusLinePosition# %l:%c | %p%% | %Y %*'
    }, '')
  end,
})

-- Обновление winbar при изменении буфера
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  callback = function()
    vim.opt_local.winbar = '▎%{v:lua.get_winbar()}'
  end,
})

print("Neovim config loaded successfully!")
