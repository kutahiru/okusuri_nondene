import UIKit
import Turbo
import WebKit

class TurboNavigator: NSObject {
    // MARK: - Properties

    // RailsサーバーのURL（環境に応じて変更してください）
    private let baseURL = URL(string: "http://localhost:3000")!

    // Turbo Session
    private lazy var session: Session = {
        let session = Session()
        session.delegate = self
        session.pathConfiguration = pathConfiguration
        return session
    }()

    // Path Configuration
    private lazy var pathConfiguration: PathConfiguration = {
        let configuration = PathConfiguration(sources: [
            .server(baseURL.appendingPathComponent("/turbo_native/configuration"))
        ])
        return configuration
    }()

    // Navigation Controller
    private lazy var navigationController: UINavigationController = {
        let nav = UINavigationController()
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }()

    // Root View Controller
    lazy var rootViewController: UIViewController = {
        return navigationController
    }()

    // Script Message Handler
    private lazy var scriptMessageHandler: ScriptMessageHandler = {
        return ScriptMessageHandler(navigator: self)
    }()

    // Modal Session (モーダル表示用)
    private var modalSession: Session?

    // MARK: - Initialization

    override init() {
        super.init()
        start()
    }

    // MARK: - Navigation

    private func start() {
        // 起動時にログインチェックまたはホーム画面を表示
        route(url: baseURL)
    }

    func route(url: URL) {
        let proposal = VisitProposal(url: url, options: VisitOptions())
        visit(proposal)
    }

    private func visit(_ proposal: VisitProposal, modal: Bool = false) {
        let properties = pathConfiguration.properties(for: proposal.url)

        // プレゼンテーションモードの判定
        if let presentation = properties["presentation"] as? String, presentation == "modal" {
            presentModalSession(proposal: proposal)
        } else {
            session.visit(proposal)
        }
    }

    // MARK: - Modal Handling

    private func presentModalSession(proposal: VisitProposal) {
        let modal = Session()
        modal.delegate = self

        let modalNavigationController = UINavigationController()
        modal.visit(proposal)

        modalSession = modal

        navigationController.present(modalNavigationController, animated: true)
    }

    private func dismissModal() {
        navigationController.dismiss(animated: true) {
            self.modalSession = nil
        }
    }
}

// MARK: - SessionDelegate

extension TurboNavigator: SessionDelegate {
    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        visit(proposal)
    }

    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        print("Visit failed: \(error)")

        // エラー画面を表示
        if let errorViewController = visitable as? VisitableViewController {
            errorViewController.showErrorAlert(error: error)
        }
    }

    func sessionDidLoadWebView(_ session: Session) {
        // WebViewロード時の処理
        configureWebView(session.webView)
    }

    func sessionDidFinishRequest(_ session: Session) {
        print("Request finished")
    }

    // WebView設定
    private func configureWebView(_ webView: WKWebView) {
        // User-Agentの設定
        webView.customUserAgent = "Turbo Native iOS"

        // JavaScript Message Handlerの追加
        scriptMessageHandler.register(in: webView)

        // デバッグ用設定（本番環境では削除）
        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif
    }
}

// MARK: - Error Handling

extension VisitableViewController {
    func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "エラー",
            message: "ページの読み込みに失敗しました。\n\(error.localizedDescription)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "再試行", style: .default) { _ in
            self.reloadVisitable()
        })

        alert.addAction(UIAlertAction(title: "閉じる", style: .cancel))

        present(alert, animated: true)
    }
}
