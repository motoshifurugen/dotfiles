#!/bin/zsh

source "${HOME}/dotfiles/setup/util.zsh"

util::info "Starshipのセットアップを開始します..."

# Starshipがインストールされているか確認
if command -v starship &> /dev/null; then
    # 環境変数の設定
    if ! grep -q "STARSHIP_CONFIG" ~/.zshrc; then
        echo 'export STARSHIP_CONFIG="$HOME/.config/starship.toml"' >> ~/.zshrc
    fi

    # 初期化コードの追加
    if ! grep -q "starship init zsh" ~/.zshrc; then
        echo -e "\n# Initialize starship\neval \"\$(starship init zsh)\"" >> ~/.zshrc
        util::info "Starshipの初期化コードを.zshrcに追加しました。"
    fi

    # 設定ディレクトリが存在することを確認
    if [ ! -d "${HOME}/.config" ]; then
        mkdir -p "${HOME}/.config"
        util::info "~/.configディレクトリを作成しました。"
    fi

    # 既存の設定ファイル/ディレクトリを適切に処理
    if [ -e "${HOME}/.config/starship.toml" ]; then
        # ファイルタイプをチェック
        if [ -d "${HOME}/.config/starship.toml" ]; then
            util::warning "~/.config/starship.tomlはディレクトリです。削除して再設定します。"
            rm -rf "${HOME}/.config/starship.toml"
        elif [ -L "${HOME}/.config/starship.toml" ]; then
            util::info "既存のシンボリックリンクを更新します。"
            rm "${HOME}/.config/starship.toml"
        else
            util::info "既存の設定ファイルをバックアップします。"
            mv "${HOME}/.config/starship.toml" "${HOME}/.config/starship.toml.bak"
        fi
    fi

    # 新しい設定ファイルのリンクを作成
    if [ -f "${HOME}/dotfiles/.config/starship.toml" ]; then
        ln -sf "${HOME}/dotfiles/.config/starship.toml" "${HOME}/.config/starship.toml"
        util::info "starship.tomlのシンボリックリンクを作成しました。"
    else
        util::error "ソース設定ファイル ${HOME}/dotfiles/.config/starship.toml が見つかりません。"
        exit 1
    fi

    util::info "設定が完了しました。変更を反映するには新しいターミナルを開くか、'source ~/.zshrc'を実行してください。"
else
    util::warning "Starshipがインストールされていません。先にBrewでインストールしてください。"
fi

util::info "Starshipのセットアップが完了しました！\n"
