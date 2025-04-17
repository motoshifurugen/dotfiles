#!/bin/zsh

source "${HOME}/dotfiles/setup/util.zsh"

util::info "VSCodeのセットアップを開始します..."

#----------------------------------------------------------
# Setup code command
#----------------------------------------------------------
# VSCodeとcodeコマンドの設定
VSCODE_APP="/Applications/Visual Studio Code.app"
VSCODE_BIN="$VSCODE_APP/Contents/Resources/app/bin/code"

# VSCodeがインストールされているか確認
if [[ -d "$VSCODE_APP" ]]; then
    util::info "VSCodeが見つかりました。"
    
    # codeコマンドがパスに存在するか確認
    if ! command -v code &> /dev/null; then
        util::info "codeコマンドが見つかりません。自動的にセットアップします..."
        
        # シンボリックリンクを作成
        if [[ -f "$VSCODE_BIN" ]]; then
            # /usr/local/bin ディレクトリが存在するか確認し、必要なら作成
            if [[ ! -d "/usr/local/bin" ]]; then
                sudo mkdir -p /usr/local/bin 2>/dev/null || true
            fi
            
            # シンボリックリンクを作成（sudoが必要な場合と不要な場合の両方を試行）
            sudo ln -sf "$VSCODE_BIN" /usr/local/bin/code 2>/dev/null || \
            ln -sf "$VSCODE_BIN" /usr/local/bin/code 2>/dev/null || \
            util::warning "codeコマンドのシンボリックリンク作成に失敗しました。代替方法を使用します。"
            
            # PATHが/usr/local/binを含んでいるか確認
            if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
                util::warning "/usr/local/bin がPATHに含まれていません。現在のセッションにPATHを追加します。"
                export PATH="/usr/local/bin:$PATH"
            fi
            
            # 確認
            if command -v code &> /dev/null; then
                util::info "codeコマンドが正常にセットアップされました。"
            else
                # 環境変数CODE_COMMANDを設定して代替方法を使用
                export CODE_COMMAND="$VSCODE_BIN"
                util::warning "codeコマンドのセットアップに失敗しました。代替パスを使用します: $CODE_COMMAND"
            fi
        else
            util::warning "VSCodeの実行ファイルが見つかりません: $VSCODE_BIN"
            SKIP_EXTENSIONS=1
        fi
    else
        util::info "codeコマンドは既に利用可能です。"
    fi
else
    util::warning "VSCodeがインストールされていません。拡張機能のインストールをスキップします。"
    SKIP_EXTENSIONS=1
fi

#----------------------------------------------------------
# Install extensions
#----------------------------------------------------------
util::info "extensions.zshからVSCode拡張機能リストを読み込んでいます..."

# パスを.vscodeに統一
VSCODE_DIR="${HOME}/dotfiles/.vscode"
EXTENSIONS_FILE="${VSCODE_DIR}/extensions.zsh"

# 拡張機能リストを読み込む
util::info "拡張機能リストを読み込んでいます..."
extensions=()
if [[ -f "$EXTENSIONS_FILE" ]]; then
    while IFS= read -r line; do
        # コメント行と空行をスキップ
        if [[ -n "$line" && ! "$line" =~ ^# ]]; then
            extension_id=$(echo "$line" | awk '{print $1}')
            if [[ -n "$extension_id" ]]; then
                extensions+=("$extension_id")
            fi
        fi
    done < "$EXTENSIONS_FILE"
fi

# ネットワーク接続確認（スキップフラグが設定されていない場合のみ）
if [[ -z "$SKIP_EXTENSIONS" ]]; then
    util::info "VSCode拡張機能マーケットプレイスへの接続を確認しています..."
    if ! curl -s --connect-timeout 5 https://marketplace.visualstudio.com/_apis/public/gallery &> /dev/null; then
        util::warning "VSCode拡張機能マーケットプレイスへの接続に問題があります。拡張機能のインストールをスキップします。"
        SKIP_EXTENSIONS=1
    fi
fi

# 拡張機能をインストール
if [[ ${#extensions[@]} -gt 0 && -z "$SKIP_EXTENSIONS" ]]; then
    util::info "VSCode拡張機能をインストールしています...\n"
    
    # 使用するコマンドを決定
    EXTENSION_INSTALL_CMD="code"
    EXTENSION_LIST_CMD="code --list-extensions"
    if [[ -n "$CODE_COMMAND" ]]; then
        EXTENSION_INSTALL_CMD="$CODE_COMMAND"
        EXTENSION_LIST_CMD="$CODE_COMMAND --list-extensions"
    fi
    
    # 既にインストールされている拡張機能のリストを取得
    util::info "インストール済みの拡張機能を確認しています..."
    installed_extensions=$($EXTENSION_LIST_CMD 2>/dev/null || "$VSCODE_BIN" --list-extensions 2>/dev/null || echo "")
    
    # カウンター初期化
    success_count=0
    skip_count=0
    fail_count=0
    
    for extension in "${extensions[@]}"; do
        # 大文字小文字を区別せずに検索するため、両方を小文字に変換して比較
        extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
        installed_lower=$(echo "$installed_extensions" | tr '[:upper:]' '[:lower:]')
        
        # 既にインストール済みかチェック
        if echo "$installed_lower" | grep -q "^$extension_lower$"; then
            util::info "⏭️ ${extension} は既にインストールされています。スキップします。"
            ((skip_count++))
            continue
        fi
        
        util::info "拡張機能をインストール中: ${extension}..."
        
        # コマンドを使用してインストール
        if $EXTENSION_INSTALL_CMD --install-extension "${extension}" --force &> /dev/null; then
            util::info "✅ ${extension} のインストールに成功しました。"
            ((success_count++))
        else
            # 代替方法でインストール試行（設定されたコマンドと異なる場合のみ）
            if [[ "$EXTENSION_INSTALL_CMD" != "$VSCODE_BIN" && -f "$VSCODE_BIN" ]]; then
                if "$VSCODE_BIN" --install-extension "${extension}" --force &> /dev/null; then
                    util::info "✅ 代替方法で ${extension} のインストールに成功しました。"
                    ((success_count++))
                else
                    util::warning "❌ ${extension} のインストールに失敗しました。"
                    ((fail_count++))
                fi
            else
                util::warning "❌ ${extension} のインストールに失敗しました。"
                ((fail_count++))
            fi
        fi
        
        # 少し待機してレート制限や接続問題を回避
        sleep 1
    done
    
    # インストール結果のサマリー
    util::info "\n拡張機能のインストール結果:"
    util::info "✅ インストール成功: ${success_count}"
    util::info "⏭️ スキップ（既存）: ${skip_count}"
    util::info "❌ インストール失敗: ${fail_count}"
    util::info "📊 合計: ${#extensions[@]}"
else
    if [[ -n "$SKIP_EXTENSIONS" ]]; then
        util::warning "拡張機能のインストールをスキップしました。"
    else
        util::warning "インストールする拡張機能が見つかりませんでした。"
    fi
fi

# 設定ファイルを更新
util::info "VSCode設定を更新しています..."

# settings.jsonのディレクトリとファイルパスを設定
VSCODE_SETTINGS_DIR="${HOME}/Library/Application Support/Code/User"
SETTINGS_FILE="${VSCODE_SETTINGS_DIR}/settings.json"
SOURCE_SETTINGS="${VSCODE_DIR}/settings.json"

# 設定ディレクトリの確認
if [[ ! -d "$VSCODE_SETTINGS_DIR" ]]; then
    mkdir -p "$VSCODE_SETTINGS_DIR"
    util::info "VSCode設定ディレクトリを作成しました: $VSCODE_SETTINGS_DIR"
fi

# settings.jsonが存在する場合はコピー
if [[ -f "$SOURCE_SETTINGS" ]]; then
    # バックアップ作成（エラーが出ても続行）
    if [[ -f "$SETTINGS_FILE" ]]; then
        cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak" 2>/dev/null || true
        util::info "既存のVSCode設定ファイルをバックアップしました。"
    fi
    
    # 設定ファイルをコピー（エラーが出ても続行）
    cp "$SOURCE_SETTINGS" "$SETTINGS_FILE" 2>/dev/null || true
    chmod 644 "$SETTINGS_FILE" 2>/dev/null || true
    
    util::info "VSCode設定ファイルを更新しました。"
else
    util::warning "元のsettings.jsonファイルが見つかりません。VSCode設定のコピーをスキップしました。"
fi

util::info "VSCodeのセットアップが完了しました！\n"

# シェル統合をシェル設定ファイルに追加（永続化）
if [[ -f "$VSCODE_BIN" ]]; then
    SHELL_RC="${HOME}/.zshrc"
    
    # すでに存在するかを確認
    if ! grep -q "# VSCode command integration" "$SHELL_RC" 2>/dev/null; then
        util::info "シェル設定ファイルにVSCodeコマンド統合を追加します..."
        
        cat >> "$SHELL_RC" << EOF

# VSCode command integration
if [[ -f "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" && ! \$(command -v code) ]]; then
    export PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi
EOF
        
        util::info "VSCodeコマンド統合が.zshrcに追加されました。次回ターミナル起動時から利用可能になります。"
    fi
fi
