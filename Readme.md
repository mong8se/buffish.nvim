# Buffish

A buffer switcher in the spirit of [dirvish](https://github.acom/justinmk/vim-dirvish) or
[vinegar](https://github.com/tpope/vim-vinegar).

Opens a buffer list in the current window, so you can select a buffer to
display in the same window.

## Usage

Map some key to `:Buffish<CR>` or type it.

### What do I see?

The list of filenames in open buffers.

Why only show the filename? Because it's quicker for visual
identification.

If more than one filename matches, then it will include as much of the
path that is necessary to make them unique.

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

Also the line contains the full path so you can also `yy` to get the
full path to the file, or use visual mode and yank a portion the normal
way, etc.

### What do I smell?

Whoever smelt it, dealt it. So you tell me.

## Aren't there a million of these already?

Probably

## TODO

TODO: Will it even work on windows?

TODO: Add ~~signs~~ or line number or various things from `:ls` maybe

TODO: Add configuration?

TODO: Tests?

DONE: `conceallevel `and `concealcursor `are not properly getting set back
to the original when switching the window

DONE: only 1 level of disambiguation, maybe needs more?

DONE: make disambiguation easier to understand at a glance
