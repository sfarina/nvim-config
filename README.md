# Neovim Config

copy (or link) the `nvim` folder to `~/.config`

```sh
cp -r nvim ~/.config/
```

This is a public version of my config (that includes other configs and is updated pretty frequently).

## Prerequisites

### Command line tools

The following are highly suggested for the full neovim config to work, but not all required

- lazygit
- fzf
- fd
- ripgrep
- imagemagick

```sh
brew install fd ripgrep fzf lazygit imagemagick
```

### nodejs

This config requires a working node installation with tree-sitter-cli installed

```sh
npm i -g tree-sitter-cli
```

I use [asdf](http://asdf-vm.com) to manage versions among a long list of dependencies:

### Terminal

some features (mostly in editor image rendering) require a modern terminal emulator.

I have been really enjoying [Ghostty](https://ghostty.org)

A config for Ghostty is included.

copy (or link) the `ghostty` folder to `~/.config`

### Fonts

I like to use "0xProto" as my default font. It has support for all manner of weird glyphs required for cute stuff like the status line. Available [here](https://www.nerdfonts.com/font-downloads).

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
- `<leader>pp` open a mini.files file browser
- `<leader>b` search for open buffers
- `<leader>v` is meant as "vim stuff"
  - `<leader>vp` update all packages (`:wq` to save)
  - `<leader>vm` open Mason package manager (manage nvim LSPs and formatters, some will be installed automatically) (exit with esc)
- `<leader>gl` open a lazygit instance in the editor (be very careful with all keys, especially the g key) (exit with q)
- `<leader>e` open an fzf file picker (exit with esc)
- `<leader>f<something>` find other stuff with fzf (the which-key plugin should help)
- LSP stuff
  - `K` show "hover" tooltip. Especially useful for functions.
  - `grd` goto definition (under cursor)
  - `grn` rename symbol (under cursor)
  - `grr` show references in quickfix
  - `[d` go to the previous diagnostic message
  - `]d` go to the next diagnostic message
  - `<leader>lr` open lsp references with Fzf
  - `<leader>xx` open all diagnostics from open buffers in quickfix
  - While writing arguments to a function, press <Ctrl-s> to pop-up the signature and help for that function.
  - `<leader-ls>` show the document symbols with Aerial. Navigate functions with { and }
