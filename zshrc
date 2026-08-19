# Go
export GOPATH="${GOPATH:-$HOME/go}"
[ -d "/usr/local/cuda/bin" ] && export PATH="$PATH:/usr/local/cuda/bin"

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

# 1Password CLI
[ -f "$HOME/.config/op/plugins.sh" ] && source "$HOME/.config/op/plugins.sh"

# Terraform/OpenTofu autocomplete
autoload -U +X bashcompinit && bashcompinit
if command -v tofu &>/dev/null; then
    complete -o nospace -C "$(command -v tofu)" tofu
    complete -o nospace -C "$(command -v tofu)" terraform
fi

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

# Claude Code
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
