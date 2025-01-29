" Title:        Buffish
" Description:  A buffer chooser in the spirit of dirvish or vinegar
" Last Change:  08 August 2024
" Maintainer:   Steven Moazami <https://github.com/mong8se>

" Plugin structure gleaned from here:
" https://www.linode.com/docs/guides/writing-a-neovim-plugin-with-lua/

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_buffish")
    finish
endif
let g:loaded_buffish = 1

" Defines a package path for Lua. This facilitates importing the
" Lua modules from the plugin's dependency directory.
" let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/buffish/deps"
" exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

" " initialize with lua instead of above string concatenation
lua require('buffish').setup()
