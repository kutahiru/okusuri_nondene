import UIKit
import Turbo
import WebKit

class TurboNavigator: NSObject {
    // MARK: - Properties

    // RailsサーバーのURL（環境に応じて変更してください）
    private let baseURL = URL(string: "http://localhost:3000")!

    // Navigation Controller
    private lazy var navigationController: UINavigationController = {
        let nav = UINavigationController()
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }()

    // Turbo Session
    private lazy var session: Session = {
        let session = Session(webView: makeWebView())
        session.delegate = self
        return session
    }()

    // Root View Controller
    lazy var rootViewController: UIViewController = {
        return navigationController
    }()

    // Script Message Handler
    private lazy var scriptMessageHandler: ScriptMessageHandler = {
        return ScriptMessageHandler(navigator: self)
    }()

    // MARK: - Initialization

    override init() {
        super.init()
        start()
    }

    // MARK: - WebView Creation

    private func makeWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Turbo Native iOS"

        let webView = WKWebView(frame: .zero, configuration: configuration)

        // デバッグ用設定（本番環境では削除）
        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif

        // JavaScript Message Handlerの追加
        scriptMessageHandler.register(in: webView)

        return webView
    }

    // MARK: - Navigation

    private func start() {
        // 起動時にホーム画面を表示
        visit(url: baseURL)
    }

    func route(url: URL) {
        visit(url: url)
    }

    private func visit(url: URL, action: VisitAction = .advance) {
        let viewController = VisitableViewController(url: url)

        // ナビゲーションのタイプに応じてプッシュまたはリプレース
        if action == .replace {
            navigationController.setViewControllers([viewController], animated: false)
        } else {
            navigationController.pushViewController(viewController, animated: true)
        }

        session.visit(viewController)
    }

    // MARK: - External URL Handling

    private func openExternalURL(_ url: URL) {
        // 外部URL（OAuth等）をSafariで開く
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - SessionDelegate

extension TurboNavigator: SessionDelegate {
    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        // プロパティからプレゼンテーションモードを確認
        let properties = proposal.properties

        if let presentation = properties["presentation"] as? String, presentation == "modal" {
            // モーダル表示
            let viewController = VisitableViewController(url: proposal.url)
            let modalNavigationController = UINavigationController(rootViewController: viewController)

            // 閉じるボタンを追加
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(dismissModal)
            )

            navigationController.present(modalNavigationController, animated: true)
            session.visit(viewController)
        } else {
            // 通常のナビゲーション
            visit(url: proposal.url, action: proposal.options.action)
        }
    }

    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        print("Visit failed: \(error)")

        // エラーアラートを表示
        guard let viewController = visitable as? UIViewController else { return }

        let alert = UIAlertController(
            title: "エラー",
            message: "ページの読み込みに失敗しました。\n\(error.localizedDescription)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "再試行", style: .default) { _ in
            session.reload()
        })

        alert.addAction(UIAlertAction(title: "閉じる", style: .cancel))

        viewController.present(alert, animated: true)
    }

    func sessionWebViewProcessDidTerminate(_ session: Session) {
        // WebViewプロセスが終了した場合、リロード
        session.reload()
    }

    func sessionDidLoadWebView(_ session: Session) {
        // WebViewロード時にカスタムNavigationDelegateを設定
        session.webView.navigationDelegate = self
    }

    // MARK: - Modal Handling

    @objc private func dismissModal() {
        navigationController.dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate (OAuth/フォームPOST対応)

extension TurboNavigator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        print("Navigation: \(navigationAction.navigationType.rawValue) -> \(url)")

        // フォーム送信の場合
        if navigationAction.navigationType == .formSubmitted {
            // 同じホスト（自サーバー）へのPOSTは許可
            if url.host == baseURL.host {
                print("Allowing form POST to same host: \(url)")
                decisionHandler(.allow)
                return
            }
            // 外部ホストへのPOSTは許可（OAuthリダイレクト等）
            else {
                print("Allowing form POST to external host: \(url)")
                decisionHandler(.allow)
                return
            }
        }

        // リンククリック等の通常のナビゲーション
        if navigationAction.navigationType == .linkActivated {
            // 外部URLの場合はSafariで開く
            if url.host != baseURL.host && (url.scheme == "http" || url.scheme == "https") {
                print("Opening external URL in Safari: \(url)")
                openExternalURL(url)
                decisionHandler(.cancel)
                return
            }
        }

        // その他のナビゲーションは許可
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // レスポンスは基本的に許可
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Navigation finished: \(webView.url?.absoluteString ?? "unknown")")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Navigation failed: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Provisional navigation failed: \(error.localizedDescription)")
    }
}
