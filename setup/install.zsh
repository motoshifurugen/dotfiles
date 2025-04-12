#!/bin/zsh

source "${HOME}/dotfiles/setup/util.zsh"

util::info "Starting dotfiles installation..."

for script in $(\ls ${HOME}/dotfiles/setup/install); do
  util::confirm "install ${script}?"
  if [[ $? = 0 ]]; then
    . ${HOME}/dotfiles/setup/install/${script}
  fi
done

util::info "🎉 Installation complete! Your dotfiles are now ready for their makeover!"
util::info "✨ Please restart your terminal - the setup wizard is waiting backstage!"
