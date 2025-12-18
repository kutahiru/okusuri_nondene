import Foundation
import WebKit
import UIKit

/// WebビューからのJavaScriptメッセージを処理するハンドラー
class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var navigator: TurboNavigator?

    init(navigator: TurboNavigator) {
        self.navigator = navigator
    }

    /// WebViewにメッセージハンドラーを登録
    func register(in webView: WKWebView) {
        let userContentController = webView.configuration.userContentController

        // 各種メッセージハンドラーを登録
        userContentController.add(self, name: "pageLoaded")
        userContentController.add(self, name: "setTitle")
        userContentController.add(self, name: "showAlert")
        userContentController.add(self, name: "showConfirm")
        userContentController.add(self, name: "pushNotificationToken")
    }

    /// WebViewからのメッセージを受信
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else {
            print("Invalid message body")
            return
        }

        switch message.name {
        case "pageLoaded":
            handlePageLoaded(body)

        case "setTitle":
            handleSetTitle(body)

        case "showAlert":
            handleShowAlert(body)

        case "showConfirm":
            handleShowConfirm(body, webView: message.webView)

        case "pushNotificationToken":
            handlePushNotificationToken(body)

        default:
            print("Unknown message: \(message.name)")
        }
    }

    // MARK: - Message Handlers

    /// ページロード完了時の処理
    private func handlePageLoaded(_ body: [String: Any]) {
        guard let title = body["title"] as? String,
              let url = body["url"] as? String else {
            return
        }

        print("Page loaded - Title: \(title), URL: \(url)")

        // 必要に応じて、ナビゲーションバーのタイトルを更新
        DispatchQueue.main.async {
            if let topViewController = self.topViewController() {
                topViewController.title = title
            }
        }
    }

    /// タイトル設定
    private func handleSetTitle(_ body: [String: Any]) {
        guard let title = body["title"] as? String else { return }

        DispatchQueue.main.async {
            if let topViewController = self.topViewController() {
                topViewController.title = title
            }
        }
    }

    /// アラート表示
    private func handleShowAlert(_ body: [String: Any]) {
        let title = body["title"] as? String ?? "通知"
        let message = body["message"] as? String ?? ""

        DispatchQueue.main.async {
            guard let topViewController = self.topViewController() else { return }

            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default))

            topViewController.present(alert, animated: true)
        }
    }

    /// 確認ダイアログ表示
    private func handleShowConfirm(_ body: [String: Any], webView: WKWebView?) {
        let title = body["title"] as? String ?? "確認"
        let message = body["message"] as? String ?? ""

        DispatchQueue.main.async {
            guard let topViewController = self.topViewController() else { return }

            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                // JavaScriptにOKが押されたことを通知
                webView?.evaluateJavaScript("window.confirmResult = true;")
            })

            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                // JavaScriptにキャンセルが押されたことを通知
                webView?.evaluateJavaScript("window.confirmResult = false;")
            })

            topViewController.present(alert, animated: true)
        }
    }

    /// プッシュ通知トークンの処理
    private func handlePushNotificationToken(_ body: [String: Any]) {
        guard let token = body["token"] as? String else { return }

        print("Received push notification token from web: \(token)")

        // デバイストークンをサーバーに送信する処理をここに実装
        // 例: APIエンドポイントにPOSTリクエスト
    }

    // MARK: - Utilities

    /// 現在表示中の最前面のViewController を取得
    private func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }

        return getTopViewController(from: rootViewController)
    }

    private func getTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return getTopViewController(from: presented)
        }

        if let navigationController = viewController as? UINavigationController {
            return navigationController.visibleViewController ?? navigationController
        }

        if let tabBarController = viewController as? UITabBarController {
            return tabBarController.selectedViewController ?? tabBarController
        }

        return viewController
    }
}

// MARK: - WebView Extensions

extension WKWebView {
    /// JavaScriptを実行してネイティブのデバイストークンをWebに渡す
    func sendDeviceToken(_ token: String) {
        let script = "window.nativeDeviceToken = '\(token)';"
        evaluateJavaScript(script) { result, error in
            if let error = error {
                print("Failed to send device token to web: \(error)")
            }
        }
    }

    /// ネイティブイベントをWebに通知
    func notifyNativeEvent(_ eventName: String, data: [String: Any] = [:]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }

        let script = "window.dispatchEvent(new CustomEvent('\(eventName)', { detail: \(jsonString) }));"
        evaluateJavaScript(script)
    }
}
