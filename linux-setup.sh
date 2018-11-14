#!/bin/bash

#Script to install common Linux programs automatically
echo "Installing Applications..."

# Dropbox
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
~/.dropbox-dist/dropboxd &

# Apt packages
sudo apt-get update
sudo apt-get -y install vim git python-pip tmux thunderbird fonts-powerline

# Synaptic packages
sudo snap install spotify

# Pip packages
pip install --user powerline-status

# Get dotfiles from fresh
git clone https://github.com/freshshell/fresh ~/.fresh/source/freshshell/fresh
echo y | fresh mccormickt9/dotfiles freshrc --file
fresh update

echo "Setup Complete!"
