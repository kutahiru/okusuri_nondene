import UIKit
import Turbo

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var turboNavigator: TurboNavigator!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        // Turbo Navigatorの初期化
        turboNavigator = TurboNavigator()

        // ルートViewControllerを設定
        window?.rootViewController = turboNavigator.rootViewController
        window?.makeKeyAndVisible()

        // アプリ起動時のURL処理（ディープリンクなど）
        if let urlContext = connectionOptions.urlContexts.first {
            handleURL(urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // ディープリンク処理
        guard let url = URLContexts.first?.url else { return }
        handleURL(url)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    // MARK: - URL Handling

    private func handleURL(_ url: URL) {
        // 招待URLなどのディープリンクを処理
        print("Opening URL: \(url)")

        if url.scheme == "okusuri" {
            // カスタムURLスキーム: okusuri://invite/token
            turboNavigator.route(url: url)
        } else if url.host == "okusuri.app" {
            // Universal Links: https://okusuri.app/invite/token
            turboNavigator.route(url: url)
        }
    }
}
