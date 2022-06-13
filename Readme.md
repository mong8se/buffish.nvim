# Buffish

A buffer switcher in the spirit of dirvish or vinegar.

## Usage

Map some key to `:Buffish<CR>`

### What I push?

Only three keys mapped:

1. <CR>` to switch to the buffer
2. `dd` to `bd` that buffer
3. `q` to close without switching

Well the line contains the full path so you can also `yy` to get the
full path to the file

### How's it sorted?

Most recently used file at the top (which is the one you're leaving) to
least recently used at the bottom.

It automatically starts with the cursor on the 2nd line (if there is one),
so you can easily switch back and forth between two buffers.

TODO: `conceallevel `and `concealcursor `are not properly getting set back
to the original when switching the window

TODO: Add signs or line number or various things from `:ls` maybe

TODO: Add configuration?

TODO: Tests?
