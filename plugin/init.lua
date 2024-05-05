package.loaded['plugin'] = nil
package.loaded['citrus'] = nil
package.loaded['citrus.hello_world'] = nil

vim.api.nvim_set_keymap('n', ',r', '<cmd>luafile ~/proj/citrus/plugin/init.lua<cr>', {})

citrus = require('citrus')
vim.api.nvim_set_keymap('n', ',w', '<cmd>lua citrus.hello_world()<cr>', {})

