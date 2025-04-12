#!/bin/zsh

source "${HOME}/dotfiles/setup/util.zsh"

util::info "Starting brew setup..."

export HOMEBREW_NO_AUTO_UPDATE=1

# Add Homebrew font tap
util::info "Adding Homebrew font tap..."
brew tap homebrew/cask-fonts

formulas=(
    fzf          # Fuzzy finder
    git          # Version control system
    zsh          # Shell
    yarn         # JavaScript package manager
    sheldon      # Shell plugin manager
    starship     # Customizable prompt
    uv           # Python package manager
    tmux         # Terminal multiplexer
)

# Install Nerd Fonts
util::info "Installing Nerd Fonts..."
casks=(
    font-hack-nerd-font      # Programming font
    font-fira-code-nerd-font # Another programming font
)

brew upgrade

for formula in "${formulas[@]}"; do
    brew install "${formula}"
done

for cask in "${casks[@]}"; do
    brew install --cask "${cask}"
done

util::info "Homebrew setup completed!"
