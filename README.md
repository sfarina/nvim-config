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
