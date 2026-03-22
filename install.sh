#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

link() {
    ln -sf "$1" "$2"
    echo "  $2 -> $1"
}

# Template a file: replace OS-specific placeholders and write to destination
template() {
    local src="$1" dst="$2"
    sed \
        -e "s|__OP_SSH_SIGN__|$OP_SSH_SIGN|g" \
        -e "s|__TOFU_PATH__|$TOFU_PATH|g" \
        -e "s|__POWERLINE_CONF__|$POWERLINE_CONF|g" \
        "$src" > "$dst"
    echo "  $dst <- $src (templated)"
}

echo "Installing dotfiles for $OS..."

# OS-specific values
if [[ "$OS" == "Darwin" ]]; then
    OP_SSH_SIGN="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    TOFU_PATH="/opt/homebrew/bin/tofu"
else
    OP_SSH_SIGN="/opt/1Password/op-ssh-sign"
    TOFU_PATH="tofu"
fi

# Find powerline tmux binding
POWERLINE_CONF="$(python3 -c 'import powerline; import os; print(os.path.join(os.path.dirname(powerline.__file__), "bindings/tmux/powerline.conf"))' 2>/dev/null || echo "")"
if [[ -z "$POWERLINE_CONF" ]]; then
    echo "  Warning: powerline not found, tmux powerline source will be empty"
fi

# Create directories
mkdir -p ~/.config/nvim/after/ftplugin
mkdir -p ~/.config/helix
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/jj
mkdir -p ~/.config/nono/profiles

# Shared configs (symlinked directly)
link "$DOTFILES/nvim/init.vim" ~/.config/nvim/init.vim
link "$DOTFILES/nvim/after/ftplugin/rust.lua" ~/.config/nvim/after/ftplugin/rust.lua
link "$DOTFILES/helix/config.toml" ~/.config/helix/config.toml
link "$DOTFILES/ghostty/config" ~/.config/ghostty/config
link "$DOTFILES/zshrc" ~/.zshrc
link "$DOTFILES/vimrc" ~/.vimrc
link "$DOTFILES/nono/profiles/custom-claude-code.json" ~/.config/nono/profiles/custom-claude-code.json

# Templated configs (OS-specific values substituted)
template "$DOTFILES/gitconfig" ~/.gitconfig
template "$DOTFILES/jj/config.toml" ~/.config/jj/config.toml
template "$DOTFILES/helix/languages.toml" ~/.config/helix/languages.toml
template "$DOTFILES/tmux.conf" ~/.tmux.conf

echo "Done!"
