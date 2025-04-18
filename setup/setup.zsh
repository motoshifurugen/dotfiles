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
    # 適切なディレクトリにシンボリックリンクを作成
    if [[ ! -d ${HOME}/.config/${name%/*} ]]; then
      mkdir -p ${HOME}/.config/${name%/*}
    fi
    ln -sf ${PWD}/$name ${HOME}/.config/$name
  fi
done

cd ..

#----------------------------------------------------------
# Run installation scripts
#----------------------------------------------------------
FORCE=1
. ${DOTFILES_DIR}/setup/install.zsh

#----------------------------------------------------------
# last message
#----------------------------------------------------------
util::info "🎉 全ての設定が完了しました！ターミナルを再起動して、新しい環境を楽しんでください！"
