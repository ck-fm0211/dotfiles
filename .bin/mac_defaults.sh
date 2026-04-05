#!/bin/zsh
set -e

## 時刻を秒まで表示
defaults write com.apple.menuextra.clock ShowSeconds -bool true

## 隠しファイルを表示
defaults write com.apple.finder AppleShowAllFiles -boolean true

## 共有フォルダで.DS_Storeを作成しない
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

## スクリーンショットの保存場所変更
mkdir ~/screenshots
defaults write com.apple.screencapture location ~/screenshots

# Save screenshots as PNGs （スクリーンショット保存形式をPNGにする）
defaults write com.apple.screencapture type -string "png"

# Show bluetooth in the menu bar
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true

## dockを左に
defaults write com.apple.dock orientation -string "left"

## dockを自動表示自動表示
defaults write com.apple.dock autohide -bool true

## Wipe all app icons from the Dock （Dock に標準で入っている全てのアプリを消す、Finder とごみ箱は消えない）
defaults write com.apple.dock persistent-apps -array

# Hot corners （Mission Control のホットコーナーの設定）
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen
# wvous-*-corner
# *:
#  tl -> top left
#  tr -> top right
#  bl -> bottom left
#  br -> bottom right


## Bottom left screen corner → Put display to sleep （左下 → 画面ロック）
defaults write com.apple.dock wvous-bl-corner -int 13
defaults write com.apple.dock wvous-bl-modifier -int 0

## Bottom right screen corner → Put display to sleep （右下 → ディスプレイをスリープ）
defaults write com.apple.dock wvous-br-corner -int 10
defaults write com.apple.dock wvous-br-modifier -int 0

## Top right screen corner → Desktop （右上 → デスクトップを表示）
defaults write com.apple.dock wvous-tr-corner -int 4
defaults write com.apple.dock wvous-tr-modifier -int 0

## Top left screen corner → Desktop （右上 → アプリケーションウィンドウ）
defaults write com.apple.dock wvous-tl-corner -int 3
defaults write com.apple.dock wvous-tl-modifier -int 0

# Allow you to select and copy string in QuickLook （QuickLook で文字の選択、コピーを出来るようにする）
defaults write com.apple.finder QLEnableTextSelection -bool true

# Automatically open a new Finder window when a volume is mounted
# マウントされたディスクがあったら、自動的に新しいウィンドウを開く
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Set `${HOME}` as the default location for new Finder windows
# 新しいウィンドウでデフォルトでホームフォルダを開く
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Show Status bar in Finder （ステータスバーを表示）
defaults write com.apple.finder ShowStatusBar -bool true

# Show Path bar in Finder （パスバーを表示）
defaults write com.apple.finder ShowPathbar -bool true

# Show Tab bar in Finder （タブバーを表示）
defaults write com.apple.finder ShowTabView -bool true

# Show the ~/Library directory （ライブラリディレクトリを表示、デフォルトは非表示）
chflags nohidden ~/Library

# Disable “natural” (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
### (無; icloud 対応アプリでのファイル保存時のデフォルトを icloud にする)
### -> false (icloud をデフォルト保存先としない)

# Display ASCII control characters using caret notation in standard text views
# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true
### (無; ascii 制御文字の表示)
### -> true (表示する)

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
### (無; アップデートのチェック周期)
### -> 1 (毎日)

# スクロール等の速さ（要:再起動）
defaults write NSGlobalDomain com.apple.trackpad.scaling 2
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

## スクロールバーを常時表示する
defaults write -g AppleShowScrollBars -string "Always"

## テキストエディットをプレーンテキストで使う
defaults write com.apple.TextEdit RichText -int 0

## terminalでUTF-8のみを使用する
defaults write com.apple.terminal StringEncodings -array 4

## 全ての拡張子のファイルを表示する
defaults write -g AppleShowAllExtensions -bool true

# 再起動
echo "Please restart the OS."
echo "command: sudo shutdown -r now"
