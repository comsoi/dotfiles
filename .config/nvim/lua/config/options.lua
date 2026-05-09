-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- vim.opt.clipboard = "unnamedplus"

-- vim.g.clipboard = {
--   name = "OSC 52",
--   copy = {
--     ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
--   },
--   paste = {
--     ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
--   },
-- }

vim.api.nvim_set_keymap("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true, silent = true })
vim.opt.spelllang = "en,cjk"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = false
vim.opt.smarttab = true
vim.opt.smartindent = true

vim.g.autoformat = false
vim.g.suda_smart_edit = 1

vim.g.neovide_opacity = 0.7
vim.g.transparency = 1.0
vim.g.neovide_window_blurred = true

vim.g.vimtex_quickfix_mode = 0
vim.g.vimtex_compiler_latexmk_engines = {
	["_"] = "-xelatex",
}
vim.g.vimtex_compiler_latexmk = {
	options = {
		"-xelatex",
		"-file-line-error",
		"-synctex=1",
		"-interaction=nonstopmode",
	},
}
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_progname = "nvr"

-- wezterm enable kitty kpc
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     vim.defer_fn(function()
--       if vim.fn.getenv("TERM") == "wezterm" then
--         vim.fn.chansend(vim.v.stderr, "\x1b[1 q\x1b[=1;1u\x1b[?u\x1b[>1u\x1b[>c")
--       end
--     end, 100)
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("VimLeave", {
--   callback = function()
--     if vim.fn.getenv("TERM") == "wezterm" then
--       vim.fn.chansend(vim.v.stderr, "\x1b[5 q\x1b>4;m\x1b[<u")
--       -- local target_tty = "/dev/pts/3"
--       -- local file = io.open(target_tty, "w") -- 打开目标终端设备
--       -- if file then
--       --   file:write("Debug message: Exiting Neovim\n")
--       --   file:close()
--       -- end
--     end
--   end,
-- })
