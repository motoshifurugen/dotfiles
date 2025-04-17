#!/bin/zsh
# 設定を再読み込みするスクリプト
source ~/.zshrc
# starshipを直接初期化
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi
echo "設定を再読み込みしました"
