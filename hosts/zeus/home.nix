# Zeus runs Ubuntu. Home Manager manages the configuration files. Ghostty,
# Rust, the coding agents, and the cloud CLIs stay with their existing snap,
# apt, Homebrew, and self-updating installers until Zeus moves to NixOS.
{ ... }:

{
  targets.genericLinux = {
    enable = true;
    gpu.enable = false;
  };

  programs.zsh.initContent = ''
    export PATH="$PATH:/usr/local/go/bin"

    # Nix
    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi

    # Homebrew
    [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

    # nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

    # bun
    [ -s "$HOME/.oh-my-zsh/completions/_bun" ] && source "$HOME/.oh-my-zsh/completions/_bun"
    export BUN_INSTALL="$HOME/.bun"

    # Deno
    [ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

    # flyctl
    export FLYCTL_INSTALL="$HOME/.fly"
    [ -d "$FLYCTL_INSTALL/bin" ] && export PATH="$FLYCTL_INSTALL/bin:$PATH"

    # opencode
    [ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

    # Pi and Codex
    for pi_node in "$HOME"/.local/share/pi-node/node-*/bin(N/); do
        export PATH="$pi_node:$PATH"
    done
  '';
}
