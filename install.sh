#!/bin/bash

install_all() {
    # Install zsh
    echo -e "Installing zsh..."
    sudo apt-get install -y zsh
    chsh -s $(which zsh)
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    rm ~/.zshrc
    ln -s $(pwd)/.zshrc ~/.zshrc
    echo -e "Installing zsh...done\n"

    # Some prerequisites
    echo -e "Installing prerequisites..."
    sudo apt-get install -y ninja-build gettext cmake unzip curl wget
    mkdir -p ~/.config
    echo -e "Installing prerequisites...done\n"

    # Install NerdFont (Ubuntu only)
    echo -e "Installing NerdFont..."
    cd /tmp
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/0xProto.zip
    unzip 0xProto.zip -d ~/.local/share/fonts
    fc-cache -fv

    # Install go
    echo -e "Installing go..."
    wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    export PATH=$PATH:$HOME/go/bin
    echo -e "Installing go...done\n"

    # Install nodejs
    echo -e "Installing nodejs..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    nvm install 18
    echo -e "Installing nodejs...done\n"

    # Install python
    echo -e "Installing python..."
    sudo apt-get install -y python3-pip
    sudo apt-get install -y python3-venv
    echo -e "Installing python...done\n"

    # Install neovim
    cd /tmp
    git clone https://github.com/neovim/neovim
    cd neovim && make CMAKE_BUILD_TYPE=Release
    sudo make install
    ln -s $(pwd)/.config/nvim ~/.config/nvim
    echo -e "Installing neovim...done\n"

    # Install lazygit
    echo -e "Installing lazygit..."
    mkdir /tmp/lazygit
    cd /tmp/lazygit
    git clone https://github.com/jesseduffield/lazygit.git
    cd lazygit
    go install
    echo -e "Installing lazygit...done\n"

    # Lazygit
    echo -e "Copying lazygit config..."
    rm ~/.config/lazygit/config.yml
    ln -s $(pwd)/.config/lazygit/config.yml ~/.config/lazygit
    echo -e "Copying lazygit config...done\n"

    # Install tmux
    echo -e "Installing tmux..."
    sudo apt-get install -y tmux
    echo -e "Installing tmux...done\n"
    # Install tmux plugin manager
    echo -e "Installing tmux plugin manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ln -s $(pwd)/.tmux.conf ~/.tmux.conf
    echo -e "Installing tmux plugin manager...done\n"
    # Run tmux `tmux`
    # Press `prefix` + I (capital I, as in **I**nstall) to fetch the plugins
    echo -e "To install tmux plugins, run tmux and press `prefix` (Ctrl-B) + I"
}


set_symlinks() {
    echo -e "Setting symlinks..."
    rm ~/.zshrc
    ln -s $(pwd)/.zshrc ~/.zshrc
    rm ~/.config/nvim
    ln -s $(pwd)/.config/nvim ~/.config/nvim
    rm ~/.config/lazygit/config.yml
    ln -s $(pwd)/.config/lazygit/config.yml ~/.config/lazygit/config.yml
    rm ~/.tmux.conf
    ln -s $(pwd)/.tmux.conf ~/.tmux.conf
    echo -e "Setting symlinks...done\n"
}

symlinkonly=0

while getopts ":s" opt; do
    case ${opt} in
        s ) symlinkonly=1
            ;;
        \? ) echo -e "Usage: ./install.sh [-s]"
            ;;
    esac
done

if [ $symlinkonly -eq 0 ]; then
    install_all
else
    set_symlinks
fi

