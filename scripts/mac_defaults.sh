#!/bin/bash
# mac_defaults.sh - macOS システム設定を一括適用
#
# 設定適用後は OS の再起動が必要です:
#   sudo shutdown -r now
#
# 参考:
#   https://macos-defaults.com/
#   https://github.com/mathiasbynens/dotfiles/blob/main/.macos

set -euo pipefail

log()     { printf '\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
success() { printf '  \033[1;32m✓\033[0m %s\n' "$*"; }
warn()    { printf '  \033[1;33m!\033[0m %s\n' "$*" >&2; }

# ============================================================
# Dock
# ============================================================
log "Dock を設定しています..."

# Dock を左側に配置
defaults write com.apple.dock orientation -string "left"
# Dock を自動的に隠す
defaults write com.apple.dock autohide -bool true
# Dock 自動表示の遅延をゼロに（即座に表示）
defaults write com.apple.dock autohide-delay -float 0
# Dock の表示アニメーション速度を上げる
defaults write com.apple.dock autohide-time-modifier -float 0.3
# Dock アイコンサイズ
defaults write com.apple.dock tilesize -int 36
# 拡大効果を有効化
defaults write com.apple.dock magnification -bool true
# 拡大時の最大サイズ
defaults write com.apple.dock largesize -int 60
# 最近使ったアプリを Dock に表示しない
defaults write com.apple.dock show-recents -bool false
# Dock に標準で入っているすべてのアプリを削除（Finder とゴミ箱は消えない）
defaults write com.apple.dock persistent-apps -array
# ウィンドウを Dock に格納する際のエフェクト（scale が速い）
defaults write com.apple.dock mineffect -string "scale"
# ウィンドウタイトルバーのダブルクリックでウィンドウを最大化
defaults write com.apple.dock dblclickbehavior -string "maximize"
# Spring loading を有効化（Dock アイコンへのドラッグ後に展開）
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
# アプリアイコンのバウンスを減らす
defaults write com.apple.dock launchanim -bool false

success "Dock"

# ============================================================
# ホットコーナー
# ============================================================
log "ホットコーナーを設定しています..."
# 値: 0=なし 2=MC 3=アプリウィンドウ 4=デスクトップ 5=SS開始 10=スリープ 13=ロック
defaults write com.apple.dock wvous-tl-corner   -int 3  # 左上: アプリウィンドウ
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner   -int 4  # 右上: デスクトップ
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner   -int 13 # 左下: 画面ロック
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner   -int 10 # 右下: ディスプレイスリープ
defaults write com.apple.dock wvous-br-modifier -int 0
success "ホットコーナー"

# ============================================================
# Mission Control
# ============================================================
log "Mission Control を設定しています..."
# 最近使用した状況に基づいて Space を自動的に並び替えない
defaults write com.apple.dock mru-spaces -bool false
# Mission Control アニメーションを高速化
defaults write com.apple.dock expose-animation-duration -float 0.1
# アプリケーションウィンドウをグループ化する
defaults write com.apple.dock expose-group-by-app -bool true
success "Mission Control"

# ============================================================
# Finder
# ============================================================
log "Finder を設定しています..."
defaults write com.apple.finder AppleShowAllFiles              -bool true   # 隠しファイルを表示
defaults write NSGlobalDomain AppleShowAllExtensions           -bool true   # 全拡張子を表示
defaults write com.apple.finder ShowStatusBar                  -bool true   # ステータスバーを表示
defaults write com.apple.finder ShowPathbar                    -bool true   # パスバーを表示
defaults write com.apple.finder ShowTabView                    -bool true   # タブバーを表示
defaults write com.apple.finder FXPreferredViewStyle           -string "clmv" # カラム表示
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false  # 拡張子変更警告を無効
defaults write com.apple.finder _FXSortFoldersFirst            -bool true   # フォルダを先頭に
defaults write com.apple.finder FXDefaultSearchScope           -string "SCcf" # 検索=現在フォルダ
defaults write com.apple.finder NewWindowTarget                -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath            -string "file://${HOME}/"
defaults write com.apple.finder _FXShowPosixPathInTitle        -bool true   # タイトルにフルパス
defaults write com.apple.finder QLEnableTextSelection          -bool true   # QuickLook でテキスト選択
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false # デスクトップに外部HD非表示
defaults write com.apple.finder ShowRemovableMediaOnDesktop    -bool false  # デスクトップにリムーバブル非表示
defaults write com.apple.finder ShowMountedServersOnDesktop    -bool false  # デスクトップにサーバー非表示
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk  -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true # NW共有に.DS_Store非作成
defaults write com.apple.desktopservices DSDontWriteUSBStores  -bool true   # USBに.DS_Store非作成
chflags nohidden ~/Library
sudo chflags nohidden /Volumes 2>/dev/null || warn "/Volumes の属性変更には sudo が必要です"
success "Finder"

# ============================================================
# スクリーンショット
# ============================================================
log "スクリーンショットを設定しています..."
SCREENSHOT_DIR="$HOME/screenshots"
mkdir -p "$SCREENSHOT_DIR"
defaults write com.apple.screencapture location    "$SCREENSHOT_DIR"
defaults write com.apple.screencapture type        -string "png"
defaults write com.apple.screencapture disable-shadow -bool true  # シャドウを無効化
defaults write com.apple.screencapture include-date   -bool true  # 日時をファイル名に含める
success "スクリーンショット"

# ============================================================
# キーボード
# ============================================================
log "キーボードを設定しています..."
defaults write NSGlobalDomain KeyRepeat                         -int 1     # キーリピート最速
defaults write NSGlobalDomain InitialKeyRepeat                  -int 10    # リピート開始を早く
defaults write NSGlobalDomain com.apple.keyboard.fnState        -bool true # Fn を標準FKとして使用
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled  -bool false # スマートクォート無効
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled   -bool false # スマートダッシュ無効
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false # 自動スペル修正無効
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled     -bool false # 自動大文字変換無効
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false # ピリオド自動入力無効
defaults write NSGlobalDomain ApplePressAndHoldEnabled             -bool false # ホールドでキーリピート
success "キーボード"

# ============================================================
# トラックパッド
# ============================================================
log "トラックパッドを設定しています..."
defaults write NSGlobalDomain com.apple.trackpad.scaling         -int 2    # スクロール速度
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true # タップでクリック
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior        -int 1
defaults write NSGlobalDomain com.apple.swipescrolldirection     -bool false # 反転スクロール無効
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true # 3本指ドラッグ
success "トラックパッド"

# ============================================================
# メニューバー
# ============================================================
log "メニューバーを設定しています..."
defaults write com.apple.menuextra.clock ShowSeconds   -bool true
defaults write com.apple.menuextra.clock DateFormat    -string "EEE M/d H:mm:ss"
defaults -currentHost write com.apple.controlcenter.plist Bluetooth -int 18 # Bluetooth を表示
success "メニューバー"

# ============================================================
# スクロールバー・UI
# ============================================================
defaults write -g AppleShowScrollBars -string "Always"     # スクロールバーを常時表示
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true # 制御文字を表示
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false # iCloud に保存しない

# ============================================================
# 省エネ・スリープ
# ============================================================
log "省エネ設定を行っています..."
sudo pmset -c displaysleep 15 2>/dev/null || warn "pmset -c に sudo が必要です"
sudo pmset -c sleep 0         2>/dev/null || true  # 電源接続時: システムスリープなし
sudo pmset -b displaysleep 5  2>/dev/null || true  # バッテリー時: 5分でスリープ
success "省エネ"

# ============================================================
# セキュリティ
# ============================================================
log "セキュリティを設定しています..."
defaults write com.apple.screensaver askForPassword      -int 1 # SS後すぐにパスワード要求
defaults write com.apple.screensaver askForPasswordDelay -int 0 # 即座に
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on 2>/dev/null || \
  warn "ファイアウォール有効化には sudo が必要です"
sudo spctl --master-enable 2>/dev/null || warn "Gatekeeper 有効化には sudo が必要です"
success "セキュリティ"

# ============================================================
# ソフトウェアアップデート
# ============================================================
defaults write com.apple.SoftwareUpdate ScheduleFrequency  -int 1    # 毎日チェック
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -bool true # セキュリティ更新を自動適用

# ============================================================
# Activity Monitor
# ============================================================
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true  # メインウィンドウを自動表示
defaults write com.apple.ActivityMonitor IconType       -int 5      # Dock アイコンに CPU グラフ
defaults write com.apple.ActivityMonitor ShowCategory   -int 0      # すべてのプロセスを表示

# ============================================================
# TextEdit
# ============================================================
defaults write com.apple.TextEdit RichText              -int 0  # プレーンテキストデフォルト
defaults write com.apple.TextEdit PlainTextEncoding     -int 4  # UTF-8 で開く
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4 # UTF-8 で保存

# ============================================================
# その他
# ============================================================
defaults write com.apple.terminal StringEncodings -array 4  # ターミナルは UTF-8 のみ
defaults write com.apple.CrashReporter DialogType -string "none" # クラッシュダイアログ無効
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true # TM の提案を無効
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true 2>/dev/null || true

# ============================================================
# 設定反映（Dock/Finder の再起動）
# ============================================================
log "Dock・Finder を再起動して設定を反映しています..."
killall Dock   2>/dev/null || true
killall Finder 2>/dev/null || true

# ============================================================
# 完了メッセージ
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
success "macOS 設定をすべて適用しました"
echo ""
echo "  以下の設定は再起動後に有効になります:"
echo "    - キーボードのキーリピート速度"
echo "    - 一部のトラックパッド設定"
echo ""
echo "  再起動コマンド:"
echo "    sudo shutdown -r now"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
