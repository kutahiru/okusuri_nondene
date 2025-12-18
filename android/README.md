# おくすり飲んでね - Android App

Turbo Nativeを使用したAndroidネイティブアプリ

## 必要な環境

- Android Studio Hedgehog (2023.1.1) 以上
- Kotlin 1.9以上
- Gradle 8.0以上
- Android SDK (minSdk: 26, targetSdk: 34)

## セットアップ手順

### 1. Android Studioプロジェクトの作成

1. Android Studioを開く
2. "New Project"を選択
3. "Empty Activity"を選択
4. プロジェクト設定：
   - Name: `OkusuriNondene`
   - Package name: `com.yourcompany.okusuri`
   - Language: `Kotlin`
   - Minimum SDK: `API 26 (Android 8.0)`
5. このディレクトリ（`android/`）に保存

### 2. Turbo Androidライブラリの追加

`app/build.gradle.kts`に以下を追加:

```kotlin
dependencies {
    implementation("dev.hotwired:turbo-android:7.1.0")
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")

    // Web Pushのため
    implementation("com.google.firebase:firebase-messaging:23.4.0")
}
```

`settings.gradle.kts`に以下を追加:

```kotlin
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}
```

### 3. 提供されたファイルを追加

このディレクトリ内の以下のKotlinファイルをAndroid Studioプロジェクトに追加してください：

- `MainActivity.kt`
- `TurboApplication.kt`
- `TurboSessionNavHostFragment.kt`
- `PathConfiguration.kt`
- `WebAppInterface.kt`

### 4. AndroidManifest.xmlの設定

`app/src/main/AndroidManifest.xml`に以下を追加：

```xml
<manifest>
    <application
        android:name=".TurboApplication"
        android:usesCleartextTraffic="true"
        android:networkSecurityConfig="@xml/network_security_config">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>

            <!-- ディープリンク -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />

                <data android:scheme="okusuri" />
                <data android:scheme="https"
                      android:host="okusuri.app" />
            </intent-filter>
        </activity>
    </application>

    <!-- パーミッション -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
</manifest>
```

### 5. ネットワークセキュリティ設定

`app/src/main/res/xml/network_security_config.xml`を作成：

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- 開発環境用（本番では削除） -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
</network-security-config>
```

### 6. 設定の変更

`MainActivity.kt`内の`BASE_URL`を開発サーバーのURLに変更：

```kotlin
private const val BASE_URL = "http://10.0.2.2:3000"  // エミュレーター用
// または
private const val BASE_URL = "http://YOUR_IP:3000"  // 実機用
```

### 7. ビルドして実行

1. エミュレーターまたは実機を選択
2. Run → Run 'app' でビルド・実行

## アプリの構造

```
com.yourcompany.okusuri/
├── MainActivity.kt                   # メインアクティビティ
├── TurboApplication.kt              # アプリケーションクラス
├── TurboSessionNavHostFragment.kt   # Turboセッション管理
├── PathConfiguration.kt             # Path Configuration管理
└── WebAppInterface.kt               # JavaScriptブリッジ
```

## 開発のヒント

### ローカル開発サーバーへの接続

#### エミュレーターの場合
- `10.0.2.2`がホストマシンの`localhost`を指します
- URL: `http://10.0.2.2:3000`

#### 実機の場合
- PCのローカルIPアドレスを使用
- IPアドレス確認（Mac/Linux）: `ifconfig | grep "inet "`
- IPアドレス確認（Windows）: `ipconfig`
- URL: `http://YOUR_IP:3000`

### デバッグ

Chrome DevToolsを使用してWebビューをデバッグ可能：
1. Chrome で `chrome://inspect` を開く
2. デバイスを接続
3. "inspect" をクリック

### Firebase Cloud Messaging (プッシュ通知)

1. Firebase Consoleでプロジェクトを作成
2. `google-services.json`をダウンロードして`app/`に配置
3. `build.gradle.kts`にFirebase設定を追加

## トラブルシューティング

### "Could not connect to the server"

- Railsサーバーが起動しているか確認
- URLが正しいか確認
- ネットワーク接続を確認
- `network_security_config.xml`が正しく設定されているか確認

### ビルドエラー

- Android Studioのバージョンを確認
- Clean Project: Build → Clean Project
- Rebuild Project: Build → Rebuild Project
- Gradle キャッシュをクリア: File → Invalidate Caches / Restart

## 次のステップ

- [ ] アプリアイコンの追加
- [ ] スプラッシュスクリーンの作成
- [ ] Firebase Cloud Messagingの実装
- [ ] Google Play Console申請の準備
