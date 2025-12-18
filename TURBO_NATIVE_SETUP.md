# Turbo Native 実装ガイド

このドキュメントは「おくすり飲んでね」アプリのTurbo Native実装について説明します。

## 概要

Turbo Nativeを使用して、既存のRailsアプリケーションをiOS/Androidのネイティブアプリに変換しました。Turbo Nativeは、WebビューをベースにしながらネイティブUIとの統合により、優れたユーザー体験を提供します。

## アーキテクチャ

```
┌─────────────────────────────────────────────────┐
│             Rails Server                         │
│  ┌───────────────────────────────────────────┐  │
│  │  ApplicationController                    │  │
│  │  - TurboNativeHelper (User-Agent判定)    │  │
│  │  - レイアウト自動切替                    │  │
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │  TurboNativeController                    │  │
│  │  - Path Configuration JSON提供           │  │
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │  Layout: turbo_native.html.erb           │  │
│  │  - ヘッダー・フッターなし                │  │
│  │  - Stimulus: turbo-native-controller     │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
                       ↕
          ┌────────────────────────┐
          │  Path Configuration    │
          │       (JSON)           │
          └────────────────────────┘
                       ↕
    ┌────────────┬────────────┬────────────┐
    │  iOS App   │  Android   │   Web      │
    │            │    App     │  Browser   │
    └────────────┴────────────┴────────────┘
```

## 実装内容

### 1. Rails側の実装

#### ファイル構成

```
app/
├── controllers/
│   ├── application_controller.rb (TurboNativeHelper追加)
│   ├── turbo_native_controller.rb (Path Configuration提供)
│   └── concerns/
│       └── turbo_native_helper.rb (User-Agent判定)
├── helpers/
│   └── turbo_native_helper.rb (ビューヘルパー)
├── javascript/
│   └── controllers/
│       └── turbo_native_controller.js (JavaScript Bridge)
└── views/
    └── layouts/
        └── turbo_native.html.erb (ネイティブ専用レイアウト)
```

#### 主な機能

1. **User-Agent判定**: `turbo_native_app?`メソッドでネイティブアプリからのリクエストを判定
2. **レイアウト自動切替**: ネイティブアプリには専用レイアウトを提供
3. **Path Configuration**: URLごとの表示方法（モーダル/通常）を動的に設定
4. **JavaScript Bridge**: Webビューとネイティブコード間の双方向通信

#### Path Configuration

`/turbo_native/configuration` エンドポイントでJSON設定を提供：

- **patterns**: URLパターン（正規表現対応）
- **properties**:
  - `context`: `default` | `modal`
  - `presentation`: `modal` | `external`
  - `pull_to_refresh_enabled`: true | false

### 2. iOS実装

#### ファイル構成

```
ios/
├── README.md (詳細なセットアップ手順)
├── AppDelegate.swift (アプリ起動、プッシュ通知設定)
├── SceneDelegate.swift (シーン管理、ディープリンク処理)
├── TurboNavigator.swift (Turboセッション管理とルーティング)
├── PathConfiguration.swift (Path Configuration解析)
├── ScriptMessageHandler.swift (JavaScript Bridge)
└── Info.plist.example (設定例)
```

#### セットアップ手順

1. Xcodeでプロジェクトを作成
2. Swift Package Managerで`turbo-ios`を追加
3. 提供されたSwiftファイルをプロジェクトに追加
4. `TurboNavigator.swift`のbaseURLを設定
5. ビルド・実行

#### 主な機能

- **Turboセッション管理**: TurboNavigator がナビゲーションを制御
- **JavaScript Bridge**: WKScriptMessageHandler でWebビューと通信
- **プッシュ通知**: APNs統合準備済み
- **ディープリンク**: URL Scheme & Universal Links対応

### 3. Android実装

#### ファイル構成

```
android/
├── README.md (詳細なセットアップ手順)
├── MainActivity.kt (メインアクティビティ)
├── TurboApplication.kt (アプリケーションクラス)
├── TurboSessionNavHostFragment.kt (Turboセッション管理)
├── WebAppInterface.kt (JavaScript Bridge)
├── activity_main.xml (レイアウト)
└── build.gradle.kts.example (依存関係)
```

#### セットアップ手順

1. Android Studioでプロジェクトを作成
2. `build.gradle.kts`に`turbo-android`を追加
3. 提供されたKotlinファイルをプロジェクトに追加
4. `MainActivity.kt`のBASE_URLを設定
5. ビルド・実行

#### 主な機能

- **Turboセッション管理**: TurboSessionNavHostFragment がナビゲーションを制御
- **JavaScript Bridge**: JavascriptInterface でWebビューと通信
- **プッシュ通知**: Firebase Cloud Messaging統合準備済み
- **ディープリンク**: Intent Filter対応

## 開発ワークフロー

### 1. ローカル開発

#### Railsサーバーの起動

```bash
bin/dev
```

#### iOSアプリの実行

1. Xcodeでプロジェクトを開く
2. `TurboNavigator.swift`のbaseURLをローカルIPに設定
   ```swift
   private let baseURL = URL(string: "http://192.168.1.100:3000")!
   ```
3. シミュレーターまたは実機で実行

#### Androidアプリの実行

1. Android Studioでプロジェクトを開く
2. `MainActivity.kt`のBASE_URLを設定
   ```kotlin
   // エミュレーター用
   private const val BASE_URL = "http://10.0.2.2:3000"
   // 実機用
   private const val BASE_URL = "http://192.168.1.100:3000"
   ```
3. エミュレーターまたは実機で実行

### 2. デバッグ

#### iOS

- Safari Web Inspector: Safari → 開発 → シミュレーター → [アプリ名]
- Xcodeのコンソールログ

#### Android

- Chrome DevTools: `chrome://inspect`
- Android Studioの Logcat

### 3. Rails側のデバッグ

```ruby
# コントローラーやビューで使用
if turbo_native_app?
  Rails.logger.info "Turbo Native app detected"
  Rails.logger.info "iOS: #{ios_app?}"
  Rails.logger.info "Android: #{android_app?}"
end
```

## JavaScript Bridge の使い方

### Rails側（JavaScript）→ ネイティブ

```javascript
// iOS
window.webkit.messageHandlers.showAlert.postMessage({
  title: "通知",
  message: "メッセージ"
});

// Android
window.NativeApp.showAlert(JSON.stringify({
  title: "通知",
  message: "メッセージ"
}));

// 共通ヘルパー（Stimulus Controller使用）
this.sendMessage('showAlert', { title: '通知', message: 'メッセージ' });
```

### ネイティブ → Rails側（JavaScript）

```swift
// iOS
webView.evaluateJavaScript("window.nativeDeviceToken = '\(token)';")
```

```kotlin
// Android
webView.evaluateJavascript("window.nativeDeviceToken = '$token';", null)
```

## Path Configuration の拡張

新しい画面やモーダルを追加する場合：

1. `app/controllers/turbo_native_controller.rb` の `configuration` メソッドを編集
2. `rules` 配列に新しいパターンを追加

```ruby
{
  patterns: ["/new_feature/*"],
  properties: {
    context: "modal",
    presentation: "modal"
  }
}
```

## プッシュ通知の実装

### iOS (APNs)

1. Apple Developer Centerで証明書を作成
2. Xcode → Signing & Capabilities → Push Notifications
3. `AppDelegate.swift` でトークンを取得・送信

### Android (FCM)

1. Firebase Consoleでプロジェクトを作成
2. `google-services.json`をダウンロード
3. Firebase Cloud Messagingを統合

### Rails側

LINE Messaging APIに加えて、ネイティブプッシュ通知を実装：

```ruby
# デバイストークンを保存
# app/models/push_notification_device.rb
class PushNotificationDevice < ApplicationRecord
  belongs_to :user
  enum platform: { ios: 0, android: 1 }
end

# 通知送信
# app/services/push_notification_service.rb
class PushNotificationService
  def send_notification(device, title, message)
    case device.platform
    when 'ios'
      send_apns(device.token, title, message)
    when 'android'
      send_fcm(device.token, title, message)
    end
  end
end
```

## テスト

### Rails側

```ruby
# test/controllers/turbo_native_controller_test.rb
test "should return path configuration" do
  get turbo_native_configuration_url, headers: {
    'User-Agent' => 'Turbo Native iOS'
  }
  assert_response :success
  assert_equal 'application/json', response.content_type
end
```

### iOS

```swift
// TurboNavigatorTests.swift
func testTurboNativeUserAgent() {
    let userAgent = session.webView.customUserAgent
    XCTAssertEqual(userAgent, "Turbo Native iOS")
}
```

### Android

```kotlin
// WebAppInterfaceTest.kt
@Test
fun testUserAgent() {
    val userAgent = Turbo.config.userAgent
    assertEquals("Turbo Native Android", userAgent)
}
```

## デプロイ

### Rails

通常のRailsデプロイ手順に従う。Turbo Native用のエンドポイントは自動的に含まれます。

### iOS

1. App Store Connectでアプリを登録
2. Xcodeで Archive
3. TestFlightで配布（ベータテスト）
4. App Storeに申請

### Android

1. Google Play Consoleでアプリを登録
2. Android Studioで署名付きAPK/AABを生成
3. 内部テスト/クローズドテストで配布
4. Google Playに申請

## トラブルシューティング

### "Could not connect to the server"

- Railsサーバーが起動しているか確認
- URLが正しいか確認（IPアドレス、ポート）
- ファイアウォール設定を確認
- iOS: Info.plistの`NSAppTransportSecurity`を確認
- Android: `network_security_config.xml`を確認

### レイアウトが切り替わらない

- User-Agentが正しく設定されているか確認
- `TurboNativeHelper`が`ApplicationController`にincludeされているか確認
- ログで`turbo_native_app?`の値を確認

### JavaScript Bridgeが動作しない

- iOS: `ScriptMessageHandler`が`register(in:)`で登録されているか確認
- Android: `WebAppInterface`が`addJavascriptInterface`で追加されているか確認
- WebビューのJavaScriptが有効になっているか確認

## 次のステップ

- [ ] アプリアイコンとスプラッシュスクリーンの作成
- [ ] プッシュ通知の完全実装
- [ ] オフライン対応（Service Worker）
- [ ] App Store / Google Play申請
- [ ] ユーザーフィードバックの収集と改善

## 参考リンク

- [Turbo Native iOS](https://github.com/hotwired/turbo-ios)
- [Turbo Native Android](https://github.com/hotwired/turbo-android)
- [Turbo Handbook](https://turbo.hotwired.dev/)
- [Hotwire](https://hotwired.dev/)
