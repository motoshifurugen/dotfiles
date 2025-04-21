#!/bin/zsh

source "${HOME}/dotfiles/setup/util.zsh"

util::info "React Native開発環境のセットアップを開始します..."

# Homebrew関連の確認
if ! util::has "brew"; then
  util::error "Homebrewがインストールされていません"
  util::info "先に01_brew.zshスクリプトを実行してください"
  exit 1
fi

# Node.jsのインストール（デフォルトでは最新のLTSバージョン）
util::info "Node.jsをインストール中..."
if ! brew list node &>/dev/null; then
  brew install node
else
  util::info "Node.jsは既にインストールされています"
fi

# Watchmanのインストール（ファイル変更検知用）
util::info "Watchmanをインストール中..."
if ! brew list watchman &>/dev/null; then
  brew install watchman
else
  util::info "Watchmanは既にインストールされています"
fi

# CocoaPodsのインストール（iOSアプリのライブラリ管理用）
util::info "CocoaPodsをインストール中..."
if ! util::has "pod"; then
  brew install cocoapods
else
  util::info "CocoaPodsは既にインストールされています"
fi

# XcodeがインストールされているかチェックとApp Storeへの案内
if [ -d "/Applications/Xcode.app" ]; then
  util::info "Xcodeが見つかりました"
else
  util::warning "Xcodeが見つかりません。App Storeからインストールしてください"
  if [[ ${FORCE} = 1 ]]; then
    util::info "自動モードのため、Xcodeなしで続行します（一部機能が動作しない可能性があります）"
  else
    util::info "Xcodeのインストールが完了したら、スクリプトを再実行してください"
    exit 1
  fi
fi

# Xcodeコマンドラインツールのインストール確認
if ! xcode-select -p &>/dev/null; then
  util::info "Xcodeコマンドラインツールをインストール中..."
  xcode-select --install
else
  util::info "Xcodeコマンドラインツールは既にインストールされています"
fi

# Android Studio関連のインストール
util::info "Android Studioのセットアップ中..."
if ! brew list --cask android-studio &>/dev/null; then
  brew install --cask android-studio
  util::info "Android Studioがインストールされました。初回起動時にSDKをインストールしてください。"
  util::info "または、次のコマンドを使用して必要なSDKを自動インストールすることもできます："
  util::info "  sdkmanager \"platform-tools\" \"platforms;android-33\" \"build-tools;33.0.0\""
  util::info "  sdkmanager \"system-images;android-33;google_apis;x86_64\""
  util::info "  avdmanager create avd -n test_device -k \"system-images;android-33;google_apis;x86_64\""
else
  util::info "Android Studioは既にインストールされています"
  if [[ ${FORCE} = 1 ]]; then
    util::info "自動モードでAndroid Studioをアップデートします..."
    brew upgrade --cask android-studio
  else
    util::confirm "Android Studioをアップデートしますか？"
    if [[ $? = 0 ]]; then
      brew upgrade --cask android-studio
      util::info "Android Studioがアップデートされました"
    fi
  fi
  
  # Android Studioのシンボリックリンクの確認
  ANDROID_STUDIO_APP="/Applications/Android Studio.app"
  DOTFILES_ANDROID_STUDIO="${HOME}/dotfiles/Applications/Android Studio.app"
  
  if [ -d "$ANDROID_STUDIO_APP" ] && [ ! -L "$ANDROID_STUDIO_APP" ]; then
    if [[ ${FORCE} = 1 ]]; then
      util::info "自動モードでAndroid Studioのシンボリックリンクを作成します..."
      # 必要であれば既存のAndroid Studioアプリをdotfilesにコピー
      if [ ! -d "$DOTFILES_ANDROID_STUDIO" ]; then
        mkdir -p "${HOME}/dotfiles/Applications"
        cp -R "$ANDROID_STUDIO_APP" "${HOME}/dotfiles/Applications/"
        util::info "Android Studioを${HOME}/dotfiles/Applicationsにコピーしました"
      fi
      
      # 既存のアプリケーションを移動しシンボリックリンクに置き換え
      mv "$ANDROID_STUDIO_APP" "${ANDROID_STUDIO_APP}.bak"
      ln -sf "$DOTFILES_ANDROID_STUDIO" "$ANDROID_STUDIO_APP"
      util::info "Android Studioのシンボリックリンクを作成しました"
      
      # バックアップを削除するか確認
      rm -rf "${ANDROID_STUDIO_APP}.bak"
    else
      util::confirm "Android Studioのシンボリックリンクをdotfilesに作成しますか？"
      if [[ $? = 0 ]]; then
        # 必要であれば既存のAndroid Studioアプリをdotfilesにコピー
        if [ ! -d "$DOTFILES_ANDROID_STUDIO" ]; then
          mkdir -p "${HOME}/dotfiles/Applications"
          cp -R "$ANDROID_STUDIO_APP" "${HOME}/dotfiles/Applications/"
          util::info "Android Studioを${HOME}/dotfiles/Applicationsにコピーしました"
        fi
        
        # 既存のアプリケーションを移動しシンボリックリンクに置き換え
        mv "$ANDROID_STUDIO_APP" "${ANDROID_STUDIO_APP}.bak"
        ln -sf "$DOTFILES_ANDROID_STUDIO" "$ANDROID_STUDIO_APP"
        util::info "Android Studioのシンボリックリンクを作成しました"
        
        # バックアップを削除するか確認
        util::confirm "元のAndroid Studioのバックアップを削除しますか？"
        if [[ $? = 0 ]]; then
          rm -rf "${ANDROID_STUDIO_APP}.bak"
          util::info "バックアップを削除しました"
        else
          util::info "バックアップは ${ANDROID_STUDIO_APP}.bak として保存されています"
        fi
      fi
    fi
  elif [ -L "$ANDROID_STUDIO_APP" ]; then
    util::info "Android Studioは既にシンボリックリンクとして設定されています"
  fi
fi

# Android SDKの場所を確認
ANDROID_SDK_LOCATIONS=(
  "$HOME/Library/Android/sdk"
  "$HOME/Android/Sdk"
)

ANDROID_SDK_FOUND=false
for location in "${ANDROID_SDK_LOCATIONS[@]}"; do
  if [ -d "$location" ]; then
    ANDROID_SDK_PATH="$location"
    ANDROID_SDK_FOUND=true
    break
  fi
done

if $ANDROID_SDK_FOUND; then
  util::info "Android SDKが見つかりました: $ANDROID_SDK_PATH"
else
  util::warning "Android SDKが見つかりません。Android Studioを起動してSDKをインストールしてください。"
fi

# Java Development Kit (JDK)をインストール
util::info "JDKをインストール中..."
if ! brew list openjdk@17 &>/dev/null; then
  brew install openjdk@17
  
  # シンボリックリンクの作成はスキップする（後で手動で実行するよう案内）
  util::info "OpenJDK 17がインストールされました。シンボリックリンクを作成するには以下を実行してください："
  util::info "  sudo ln -sfn $(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk"
  
  # PATHとコンパイラ設定を.zshrcに追加
  if ! grep -q "openjdk@17/bin" "${HOME}/.zshrc"; then
    cat << 'EOF' >> "${HOME}/.zshrc"

# OpenJDK 17設定
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk@17/include"
EOF
    util::info "OpenJDK 17の環境変数を.zshrcに追加しました"
  fi
else
  util::info "JDKは既にインストールされています"
  
  # すでにインストール済みの場合は、シンボリックリンクの確認だけして作成は試みない
  if [ -L "/Library/Java/JavaVirtualMachines/openjdk-17.jdk" ]; then
    util::info "OpenJDK 17のシンボリックリンクは既に存在します"
  else
    util::info "OpenJDK 17のシンボリックリンクが見つかりません"
    util::info "必要に応じて以下のコマンドを手動で実行してください:"
    util::info "  sudo ln -sfn $(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk"
  fi
fi

# React Native CLIをグローバルにインストール
util::info "React Native CLIをインストール中..."
npm install -g react-native-cli

# 便利な開発ツールをインストール
util::info "React Native開発用の追加ツールをインストール中..."

# Flipperのインストール（React Nativeデバッグツール）
if ! brew list --cask flipper &>/dev/null; then
  if [[ ${FORCE} = 1 ]]; then
    util::info "自動モードでFlipperをインストールします..."
    brew install --cask flipper
  else
    util::confirm "Flipper（React Nativeデバッグツール）をインストールしますか？"
    if [[ $? = 0 ]]; then
      brew install --cask flipper
      util::info "Flipperがインストールされました"
    fi
  fi
fi

# adbコマンドをインストール
if ! util::has "adb"; then
  util::info "ADBをインストール中..."
  brew install android-platform-tools
fi

# iOSシミュレータの確認
if ! xcrun simctl list devices | grep -q "available"; then
  util::info "iOSシミュレータをインストール中..."
  xcode-select --install
else
  util::info "iOSシミュレータは利用可能です"
fi

# Expo CLIのインストール（オプション）
util::info "Expo CLIをインストール中..."
npm install -g expo-cli
util::info "最新のExpo推奨方法：npx create-expo-app@latestを使用してプロジェクトを作成できます"

# .zshrcに必要な環境変数を追加
util::info "環境変数を設定中..."
if ! grep -q "ANDROID_HOME" "${HOME}/.zshrc"; then
  cat << 'EOF' >> "${HOME}/.zshrc"

# React Native環境変数
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
EOF
  util::info "環境変数を.zshrcに追加しました"
fi

util::info "React Native開発環境のセットアップが完了しました！"
util::info "Android Studioを起動し、SDKマネージャーでAndroid SDKをインストールしてください。"
util::info "また、以下のコマンドで新しいReact Nativeプロジェクトを作成できます："
util::info "  # React Native CLI方式（従来型）:"
util::info "  npx react-native init MyApp"
util::info "  cd MyApp"
util::info "  npx react-native run-ios    # iOSシミュレータでアプリを実行"
util::info "  npx react-native run-android  # Androidエミュレータでアプリを実行"
util::info ""
util::info "  # Expo方式（推奨）:"
util::info "  npx create-expo-app@latest MyApp"
util::info "  cd MyApp"
util::info "  npx expo start"
util::info "詳細は公式ドキュメント(https://reactnative.dev/docs/environment-setup)と"
util::info "Expoドキュメント(https://docs.expo.dev/get-started/create-a-new-app/)を参照してください。\n"