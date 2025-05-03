# liver.zsh-theme

This is pretty much just [liver](https://github.com/RenoirTan/liver) but for zsh.

## Screenshots

![Example Screenshot with Terminal](https://raw.githubusercontent.com/RenoirTan/liver.zsh-theme/main/screenshots/terminal.png)

## Installation

Make sure that [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) has been installed.

Then, copy the `liver.zsh-theme` file to `~/.oh-my-zsh/themes` and set `ZSH_THEME` to `liver` in `~/.zshrc`.

## Further customisation

You can override some of the icons, colours and outputs to something that you like by setting the corresponding variable in `~/.zshrc` to override the defaults used in my theme. You can check out which variables you can override in the `zl_make_configs` function.

## Problems

 - Cannot make RPROMPT multiline for some reason. It just does not show RPROMPT if it straddles more than 1 line. However, if zsh is spawned in a git repo, vcs_info output gets shown.
