# Buffish

A buffer switcher in the spirit of [dirvish](https://github.acom/justinmk/vim-dirvish) or
[vinegar](https://github.com/tpope/vim-vinegar).

Opens a buffer list in the current window, so you can select a buffer to
display in the same window.

As you switch buffers it sets the alternate buffer to the previous
buffer so you can always swap between the last to buffers with `c-^`.

## Usage

Map some key to `:Buffish<CR>` or to `require("buffish").open()`
or type it.

If you want to use shortcuts (see below) also map a key to
`require("buffish.shortcuts").follow()`

### What do I see?

The list of filenames in open buffers.

Why only show the filename? Because it's quicker for visual
identification.

If more than one filename matches, then it will include as much of the
path that is necessary to make them unique. For example, if you have
`this/thing.txt` and `long/path/that/thing.txt` open, it will show
`this/thing.txt` and `that/thing.txt`. The full path is still available
if you switch to visual mode, or yank the line.

It's sorted with the most recently used file at the top (which is the one you're leaving) to
least recently used at the bottom.

It automatically starts with the cursor on the 2nd line (if there is one),
so you can easily switch back and forth between two buffers.

### What do I push?

Mappings in the list:

1. `<CR>` to switch to the buffer
2. `dd` to `bd` that buffer
3. `q` to close without switching
4. `s` to open that buffer in a split either horizontally or vertically,
   depending on how much space you have
5. `a `to assigned a shortcut to this buffer (next key you type will be
   shortcut)
6. `r `to remove the shortcut from that buffer

Also the line contains the full path so you can also `yy` to get the
full path to the file, or use visual mode and yank a portion the normal
way, etc.

#### Shortcuts

Shortcuts are meant to be mnemonic like `m`, `v`, `c` to go to
your model, view, and controller respectively, or positional like `q`,
`w`,`e`, `r`, etc.

Whatever helps you connect your fingers to particular buffers.

Map a key to `require("buffish.shortcuts").follow()`

After you hit the mapped follow key, hit the key for the shortcut that you
assigned.

## Aren't there a million of these already?

Probably

## TODO

TODO: ~~Will it even work on windows?~~ Thanks to https://github.com/IRooc

TODO: Add ~~signs~~ or line number or various things from `:ls` maybe

TODO: Add configuration?

TODO: Tests?
