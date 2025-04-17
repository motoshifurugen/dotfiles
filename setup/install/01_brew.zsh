#!/bin/zsh

source "${HOME}/dotfiles/setup/util.zsh"

util::info "Brewのセットアップを開始します..."

export HOMEBREW_NO_AUTO_UPDATE=1

# Check if Xcode Command Line Tools are installed
if ! xcode-select -p &> /dev/null; then
    util::info "Xcode Command Line Toolsが見つかりません。インストール中..."
    xcode-select --install
    util::info "インストールが完了するまでお待ちください。その後、このスクリプトを再度実行してください。"
    exit 1
fi

# Check Xcode version if installed but only display warning without asking
if [ -d "/Applications/Xcode.app" ]; then
    xcode_version=$(defaults read /Applications/Xcode.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "0")
    if [ "$(printf '%s\n' "16.0" "$xcode_version" | sort -V | head -n1)" = "16.0" ]; then
        util::info "Xcodeバージョン $xcode_version は互換性があります。"
    else
        util::info "警告: Xcodeバージョン $xcode_version は古いです。App StoreからXcode 16.0以上への更新をお勧めします。"
        util::info "または、特に必要でない場合はXcodeを削除することもできます。"
        util::info "インストールを続行します..."
        # 確認なしで自動的に続行
    fi
fi

# Note about font installation
util::info "Nerd Fontsを直接インストールします（非推奨のcask-fontsタップは使用しません）"

formulas=(
    fzf          # Fuzzy finder
    git          # Version control system
    zsh          # Shell
    yarn         # JavaScript package manager
    sheldon      # Shell plugin manager
    starship     # Customizable prompt
    uv           # Python package manager
    tmux         # Terminal multiplexer
    openssl@3    # OpenSSL (newer version, replacing openssl@1.1)
)

# Install Nerd Fonts
util::info "Nerd Fontsをインストール中..."
casks=(
    font-hack-nerd-font      # Programming font
    font-fira-code-nerd-font # Another programming font
)

brew upgrade || true  # Continue even if upgrade fails

for formula in "${formulas[@]}"; do
    brew install "${formula}" || util::info "${formula}のインストールに失敗しました。続行します..."
done

for cask in "${casks[@]}"; do
    brew install --cask "${cask}" || util::info "${cask}のインストールに失敗しました。続行します..."
done

util::info "Brewのセットアップが完了しました！\n"
