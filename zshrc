# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="gallifrey"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
#COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load?
plugins=(git python aws kubectl)
source $ZSH/oh-my-zsh.sh


# User configuration

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='vim'
# fi

alias ..='cd ..'
alias c='clear'
alias ls='ls -F'
#alias python3='/usr/local/brew/bin/python3'
alias python='python3'
alias k='/usr/local/brew/bin/kubectl'
alias vim='/usr/local/brew/bin/vim'
export EDITOR='/usr/local/brew/bin/vim'
export GOBIN="$HOME/go/bin"
export PATH="/usr/local/brew/bin:$PATH:$GOBIN:${KREW_ROOT:-$HOME/.krew}/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Terraform autocomplete
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/brew/bin/terraform terraform

# Python netskope CA fix
CERT_PATH=$(python3 -m certifi)
export SSL_CERT_FILE=${CERT_PATH}
export REQUESTS_CA_BUNDLE=${CERT_PATH}

# Kubeconfig shortcuts
ktx() {
    kubectl config use-context $1
}

# AWS Helper Commands

# Function to enumerate ec2 instances in a given `region` or all regions if none specified
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

# Function to list all accounts in organization, with optional search keyword
get-accounts() {
    aws --profile master organizations list-accounts | jq -r ".Accounts[] | [.Id, .Name, .Email, .Status, .JoinedMethod, .JoinedTimestamp] | @csv" | grep -i "$1"
}

