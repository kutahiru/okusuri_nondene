# おくすり飲んでね - iOS App

Turbo Nativeを使用したiOSネイティブアプリ

## 必要な環境

- macOS
- Xcode 15.0以上
- Swift 5.9以上
- CocoaPods または Swift Package Manager

## セットアップ手順

### 1. Xcodeプロジェクトの作成

1. Xcodeを開く
2. "Create a new Xcode project"を選択
3. "iOS" → "App"を選択
4. プロジェクト設定：
   - Product Name: `OkusuriNondene`
   - Team: あなたの開発チーム
   - Organization Identifier: `com.yourcompany.okusuri`
   - Interface: `Storyboard`
   - Language: `Swift`
5. このディレクトリ（`ios/`）に保存

### 2. Turbo フレームワークの追加

#### Swift Package Managerを使う場合（推奨）

1. Xcodeで File → Add Package Dependencies...
2. 以下のURLを入力: `https://github.com/hotwired/turbo-ios`
3. Dependency Rule: "Up to Next Major Version" 7.0.0
4. "Add Package"をクリック

#### CocoaPodsを使う場合

1. `ios/`ディレクトリに`Podfile`を作成:
```ruby
platform :ios, '14.0'
use_frameworks!

target 'OkusuriNondene' do
  pod 'Turbo', '~> 7.0'
end
```

2. ターミナルで実行:
```bash
cd ios
pod install
```

### 3. 提供されたファイルを追加

このディレクトリ内の以下のSwiftファイルをXcodeプロジェクトに追加してください：

- `AppDelegate.swift`
- `SceneDelegate.swift`
- `TurboNavigator.swift`
- `PathConfiguration.swift`
- `ScriptMessageHandler.swift`

### 4. Info.plistの設定

`Info.plist`に以下を追加：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <!-- 本番環境では、特定のドメインのみ許可するように変更してください -->
</dict>
```

### 5. 設定の変更

`TurboNavigator.swift`内の`baseURL`を開発サーバーのURLに変更：

```swift
private let baseURL = URL(string: "http://localhost:3000")!
// または
private let baseURL = URL(string: "https://your-server.com")!
```

### 6. ビルドして実行

1. シミュレーターまたは実機を選択
2. Cmd + R でビルド・実行

## アプリの構造

```
OkusuriNondene/
├── AppDelegate.swift          # アプリのエントリーポイント
├── SceneDelegate.swift        # シーン管理（iOS 13+）
├── TurboNavigator.swift       # Turbo Nativeのナビゲーション制御
├── PathConfiguration.swift    # Path Configurationの管理
├── ScriptMessageHandler.swift # JavaScriptブリッジ
└── Assets.xcassets/          # 画像・アイコン
```

## 開発のヒント

### ローカル開発サーバーへの接続

1. Railsサーバーを起動: `bin/dev`
2. macのIPアドレスを確認: `ifconfig | grep "inet "`
3. `TurboNavigator.swift`のURLを更新: `http://YOUR_IP:3000`
4. シミュレーターまたは実機でアプリを実行

### デバッグ

- Safari Web Inspector を使用してWebビューをデバッグ可能
- Safari → 開発 → シミュレーター → [あなたのアプリ]

### プッシュ通知の設定

1. Apple Developer Centerでプッシュ通知証明書を作成
2. Xcode → Signing & Capabilities → "+ Capability" → "Push Notifications"
3. `ScriptMessageHandler.swift`でデバイストークンを処理

## トラブルシューティング

### "Could not connect to the server"

- Railsサーバーが起動しているか確認
- URLが正しいか確認（IPアドレス、ポート番号）
- ファイアウォール設定を確認

### ビルドエラー

- Xcodeのバージョンを確認
- Clean Build Folder: Cmd + Shift + K
- パッケージキャッシュをクリア: File → Packages → Reset Package Caches

## 次のステップ

- [ ] アプリアイコンの追加
- [ ] スプラッシュスクリーンの作成
- [ ] プッシュ通知の実装
- [ ] App Store申請の準備
