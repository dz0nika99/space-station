import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = GameViewController()
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let viewController = window?.rootViewController as? GameViewController {
            viewController.resumeGame()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if let viewController = window?.rootViewController as? GameViewController {
            viewController.pauseGame()
        }
    }
}
