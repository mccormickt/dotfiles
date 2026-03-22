# Homebrew (early, so brew-installed tools are in PATH for the rest)
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Go
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

# Additional PATH
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "/usr/local/cuda/bin" ] && export PATH="$PATH:/usr/local/cuda/bin"

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="gallifrey"
HYPHEN_INSENSITIVE="true"
plugins=(git aws kubectl direnv)
source $ZSH/oh-my-zsh.sh

# OS-specific
if [[ "$(uname)" != "Darwin" ]]; then
    alias ls='ls -F'
fi

# Common aliases
alias ..='cd ..'
alias c='clear'
alias vim='nvim'
alias python='python3'
alias k='kubectl'
alias terraform='tofu'

# Kubeconfig shortcuts
ktx() {
    kubectl config use-context $1
}
kubens() {
    kubectl config set-context --current --namespace="$1"
}

# AWS Helper Commands
ec2-enumerate() {
    JQ_ARGS='.Reservations[].Instances[] | [if has("Tags") then .Tags[].Value else "No Tags" end, .InstanceId, .KeyName, .PublicDnsName, .PublicIpAddress, .State.Name] | @csv'
    if [[ $1 != "" ]]; then
        aws ec2 describe-instances --region $1 | jq -r "$JQ_ARGS"
    else
        for region in $(aws ec2 describe-regions | jq -r ".Regions[].RegionName"); do
            aws ec2 describe-instances --region $region | jq -r "$JQ_ARGS"
        done;
    fi;
}

get-accounts() {
    aws --profile master organizations list-accounts | jq -r ".Accounts[] | [.Id, .Name, .Email, .Status, .JoinedMethod, .JoinedTimestamp] | @csv" | grep -i "$1"
}

# 1Password SSH agent
if [[ -z "$SSH_TTY" ]] && [[ -e "$HOME/.1password/agent.sock" ]]; then
    export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
fi

# 1Password CLI
[ -f "$HOME/.config/op/plugins.sh" ] && source "$HOME/.config/op/plugins.sh"

# nvm (homebrew puts nvm.sh under its prefix, standard install uses $NVM_DIR)
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
elif [ -s "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/nvm/nvm.sh" ]; then
    \. "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/nvm/nvm.sh"
fi
if [ -s "$NVM_DIR/bash_completion" ]; then
    \. "$NVM_DIR/bash_completion"
elif [ -s "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/nvm/etc/bash_completion.d/nvm" ]; then
    \. "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/nvm/etc/bash_completion.d/nvm"
fi

# pnpm (macOS: ~/Library/pnpm, Linux: ~/.local/share/pnpm)
if [ -d "$HOME/Library/pnpm" ]; then
    export PNPM_HOME="$HOME/Library/pnpm"
elif [ -d "$HOME/.local/share/pnpm" ]; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi
if [ -n "$PNPM_HOME" ]; then
    case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
fi

# bun
if [ -d "$HOME/.bun" ]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    [ -s "$HOME/.oh-my-zsh/completions/_bun" ] && source "$HOME/.oh-my-zsh/completions/_bun"
fi

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Terraform/OpenTofu autocomplete
autoload -U +X bashcompinit && bashcompinit
if command -v tofu &>/dev/null; then
    complete -o nospace -C "$(command -v tofu)" tofu
    complete -o nospace -C "$(command -v tofu)" terraform
fi

# Jujutsu completions
command -v jj &>/dev/null && source <(COMPLETE=zsh jj)

# AgentFS
[ -f "$HOME/.turso/env" ] && . "$HOME/.turso/env"
command -v agentfs &>/dev/null && source <(COMPLETE=zsh agentfs)

# FPGA tools
[ -d "$HOME/intelFPGA_standard" ] && export QSYS_ROOTDIR="$HOME/intelFPGA_standard/24.1std/quartus/sopc_builder/bin"

# Android Studio
if [ -d "$HOME/Android/Sdk" ]; then
    export JAVA_HOME="$HOME/android-studio/jbr"
    export ANDROID_HOME="$HOME/Android/Sdk"
    export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/29.0.14206865"
    export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
fi

# Amp CLI
[ -d "$HOME/.amp/bin" ] && export PATH="$HOME/.amp/bin:$PATH"

# Claude Code
export ENABLE_LSP_TOOL=1
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
sclaude() {
    nono run \
        --profile custom-claude-code \
        --allow-cwd \
        "$@" \
        -- claude \
            --allow-dangerously-skip-permissions
}

[ -f "$HOME/.svix/bin/env" ] && . "$HOME/.svix/bin/env"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
