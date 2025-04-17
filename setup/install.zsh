#!/bin/zsh

source "${HOME}/dotfiles/setup/util.zsh"

util::info "dotfilesのインストールを開始します..."

for script in $(\ls ${HOME}/dotfiles/setup/install); do
  util::confirm "${script}をインストールしますか？"
  if [[ $? = 0 ]]; then
    . ${HOME}/dotfiles/setup/install/${script}
  fi
done

util::info "🎉 インストールが完了し、dotfilesの準備が整いました！\n"
