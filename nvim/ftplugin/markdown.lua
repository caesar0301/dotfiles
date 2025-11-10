-- Markdown filetype settings

-- Text wrapping (commented out - uncomment if needed)
-- vim.opt.wrap = true
-- vim.opt.textwidth = 80

-- Folding
vim.opt.foldenable = false

-- vim-markdown plugin settings
vim.g.vim_markdown_no_default_key_mappings = 1
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_toc_autofit = 1

-- Automatically inserting bulletpoints can lead to problems when wrapping text
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 0

-- Open in-file link in new tab
vim.g.vim_markdown_edit_url_in = "tab"

-- Format borderless table automatically
vim.g.vim_markdown_borderless_table = 1
