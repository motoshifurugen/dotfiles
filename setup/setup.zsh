#!/bin/zsh

DOTFILES_DIR=${HOME}/dotfiles

source ${DOTFILES_DIR}/setup/util.zsh

#----------------------------------------------------------
# Clone or update dotfiles
#----------------------------------------------------------
if [[ ! -e ${DOTFILES_DIR} ]]; then
  git clone --recursive https://github.com/motoshifurugen/dotfiles.git ${DOTFILES_DIR}
else
  (cd ${DOTFILES_DIR} && git pull)
fi

cd ${DOTFILES_DIR}

#----------------------------------------------------------
# Create symbolic links for dotfiles
#----------------------------------------------------------
for name in *; do
  if [[ ${name} != 'setup' ]] && [[ ${name} != 'config' ]] && [[ ${name} != 'vscode' ]] && [[ ${name} != 'README.md' ]]; then
    if [[ -L ${HOME}/.${name} ]]; then
      unlink ${HOME}/.${name}
    fi
    ln -sfv ${PWD}/${name} ${HOME}/.${name}
  fi
done

if [[ ! -d ${HOME}/.config ]]; then
  mkdir ${HOME}/.config
fi

cd .config

for name in *; do
  if [[ ! $name =~ ^(setup|.config|vscode|README\.md|git)$ ]]; then
    ln -sf ${PWD}/$name ${HOME}/.$name
  fi
done

cd ..

# #----------------------------------------------------------
# # VSCode Settings
# #----------------------------------------------------------
# if [[ ! -d ${HOME}/Library/Application\ Support/Code/User ]]; then
#   mkdir -p ${HOME}/Library/Application\ Support/Code/User
# fi
# ln -sfv ${PWD}/.vscode/settings.json ${HOME}/Library/Application\ Support/Code/User/settings.json

#----------------------------------------------------------
# Initialize Starship
#----------------------------------------------------------
if command -v starship &> /dev/null; then
  # Create or update .zshrc with starship initialization
  if ! grep -q "starship init zsh" ${HOME}/.zshrc &> /dev/null; then
    echo -e "\n# Initialize starship\neval \"\$(starship init zsh)\"" >> ${HOME}/.zshrc
    util::info "Starshipの初期化コードを.zshrcに追加しました。"
  fi
else
  util::warning "Starshipがインストールされていません。先にBrewでインストールしてください。"
fi

#----------------------------------------------------------
# Run installation scripts
#----------------------------------------------------------
FORCE=1
. ${DOTFILES_DIR}/setup/install.zsh

# #----------------------------------------------------------
# # Other
# #----------------------------------------------------------
# cp ${HOME}/dotfiles/.config/alacritty/alacritty.toml ${HOME}/.config/alacritty/alacritty.toml

#----------------------------------------------------------
# last message
#----------------------------------------------------------
util::info "🎉 全ての設定が完了しました！ターミナルを再起動して、新しい環境を楽しんでください！"
