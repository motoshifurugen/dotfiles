#!/bin/zsh

source "${HOME}/dotfiles/setup/util.zsh"

util::info "GUIアプリケーションのインストールを開始します..."

# Xcodeのチェックと同様に警告だけ表示
if [ -d "/Applications/Xcode.app" ]; then
    xcode_version=$(defaults read /Applications/Xcode.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "0")
    if [ "$(printf '%s\n' "16.0" "$xcode_version" | sort -V | head -n1)" = "16.0" ]; then
        util::info "Xcodeバージョン $xcode_version は互換性があります。"
    else
        util::info "警告: Xcodeバージョン $xcode_version は古いです。App StoreからXcode 16.0以上への更新をお勧めします。"
        util::info "インストールを続行します..."
    fi
fi

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
)

brew upgrade || true

for cask in "${casks[@]}"; do
    # アプリケーション名をcask名から推測（大文字に変換して空白を追加）
    app_name=""
    case "$cask" in
        "google-chrome")
            app_name="Google Chrome"
            ;;
        "visual-studio-code")
            app_name="Visual Studio Code"
            ;;
        "cursor")
            app_name="Cursor"
            ;;
        "docker")
            app_name="Docker"
            ;;
        "slack")
            app_name="Slack"
            ;;
        "zoom")
            app_name="zoom.us"
            ;;
        "notion")
            app_name="Notion"
            ;;
        "alacritty")
            app_name="Alacritty"
            ;;
        "1password")
            app_name="1Password"
            ;;
        "claude")
            app_name="Claude"
            ;;
        "flux")
            app_name="Flux"
            ;;
        *)
            # デフォルトはcask名をそのまま使用
            app_name=$(echo "$cask" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')
            ;;
    esac

    # アプリが既にインストールされているか確認
    if [ -d "/Applications/${app_name}.app" ]; then
        util::info "「${app_name}」は既にインストールされています。スキップします。"
    else
        util::info "「${app_name}」をインストールします..."
        brew install --cask "${cask}" || util::info "「${cask}」のインストールに失敗しました。続行します..."
    fi
done

util::info "GUIアプリケーションのインストールが完了しました！\n"
