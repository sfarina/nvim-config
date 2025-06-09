# Neovim Config

copy (or link) the `nvim` folder to `~/.config`
```shell
cp -r nvim ~/.config/
```
This is a public version of my private config (that includes other configs and is updated pretty frequently).

## Prerequisites

### Command line tools
The following are highly suggested for the full neovim config to work, but not all required
- lazygit
- fzf
- fd
- ripgrep
- imagemagick

```shell
brew install fd ripgrep fzf lazygit imagemagick
```
### nodejs
Some tools (like mason being able to automatically configure LSPs) will require a working npm.

I use [asdf](http://asdf-vm.com) to manage versions among a long list of dependencies:

### Terminal
some features (mostly in editor image rendering) require a modern terminal emulator.

I have been really enjoying [KiTTY](https://sw.kovidgoyal.net/kitty/)

A config for kitty is included.

### Fonts
I like to use "Sauce Code Pro" as my default font. It has support for all manner of weird glyphs required for cute stuff like the status line. Available [here](https://www.nerdfonts.com/font-downloads).


## Neovim Config
- lua/plugins:
  - defines all the external plugins, their settings, and key bindings.
  - Loosely grouped into categories.
  - Any plugin can be disabled by setting `enabled = false`
- lua/config
  - `global.lua`: basically `init.vim`
  - `keymap.lua`: defines any custom key mappings not set in `plugins.lua`
  - `lastplace.lua`: saves the last place you edited when re-opening a file
  - `lazy.lua`: a package manager for neovim

## Useful keymaps to start with

- `<leader>` is the spacebar. Most custom actions start with that.
- `<leader><leader>` open a neo-tree file browser in a sidebar float (exit with q)
- `<leader>b` neo-tree for open buffers
- `<leader>t` open a snacks terminal in the editor
- `<leader>v` is meant as "vim stuff"
  - `<leader>vl` open Lazy package manager (manage nvim plugins) (exit with esc)
  - `<leader>vm` open Mason package manager (manage nvim LSPs and formatters, some will be installed automatically) (exit with esc)
  - `<leader>vh` show message/notification history. (exit with q)
    - With Noice, warnings and errors and other messages disappear quickly without intervention (which is usually great) but sometimes we want to be able to see them.
- `<leader>gl` open a lazygit instance in the editor (be very careful with all keys, especially the g key) (exit with q)
- `<leader>e` open an fzf file picker (exit with esc)
- `<leader>f<something>` find other stuff with fzf (the which-key plugin should help)
- LSP stuff
  - `K` show "hover" tooltip. Especially useful for functions.
  - `grd` goto definition (under cursor)
  - `grn` rename symbol (under cursor)
  - `grr` show references in quickfix
  - `[d` go to the previous diagnostic message (i.e. pyright error)
  - `]d` go to the next diagnostic message (i.e. pyright error)
  - `<leader>cl` open enhanced lsp references with Trouble (select a file and press enter to start editing that line. Press <Ctrl-h> or (Ctrl-jkl) to move between splits with vim motions (exit with q)
  - `<leader>xx` open all diagnostics from open buffers with Trouble
  - While writing arguments to a function, press <Ctrl-s) to pop-up the signature and help for that function.
  - <leader-a> open a minimal display showing the high level document symbols with Aerial. Navigate functions with { and }

- `<leader>s` manage "Snacks"
  - `z` zen mode
  - `i` toggle indentation guides
