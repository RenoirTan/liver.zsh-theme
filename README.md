# liver.zsh-theme

This is pretty much just [liver](https://github.com/RenoirTan/liver) but for zsh.

## Installation

Make sure that [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) has been installed.

Then, copy the `liver.zsh-theme` file to `~/.oh-my-zsh/themes` and set `ZSH_THEME` to `liver` in `~/.zshrc`.

## Further customisation

You can override some of the icons, colours and outputs to something that you like by setting the corresponding variable in `~/.zshrc` to override the defaults used in my theme. However, because I don't have time to document my code yet, you may have to guess what the variables in `zl_make_configs()` mean.

## Problems

 - Cannot make RPROMPT multiline for some reason. It just does not show RPROMPT if it straddles more than 1 line.

 - When I *cd* into a local git repository, vcs_info output does not show itself in the prompt. It's supposed to between the top line and the bottom line of the prompt.
