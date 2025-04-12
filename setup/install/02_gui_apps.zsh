#!/bin/zsh

source "${HOME}/dotfiles/setup/util.zsh"

util::info "Starting GUI applications installation..."

casks=(
    google-chrome    # Web browser
    visual-studio-code  # Code editor
    cursor          # AI-powered code editor
    docker          # Container management tool
    slack          # Communication tool
    zoom           # Video conferencing tool
    notion         # Note-taking app
    alacritty      # Terminal emulator
    1password      # Password manager
    claude         # AI assistant
    flux           # Screen color temperature adjuster
    font-hack-nerd-font  # Programming font
)

brew upgrade

for cask in "${casks[@]}"; do
    brew install --cask "${cask}" || true
done

util::info "GUI applications installation completed!"
