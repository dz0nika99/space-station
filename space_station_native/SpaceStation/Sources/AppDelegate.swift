import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Pause game when app becomes inactive
        if let viewController = window?.rootViewController as? GameViewController {
            viewController.pauseGame()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Resume game when app becomes active
        if let viewController = window?.rootViewController as? GameViewController {
            viewController.resumeGame()
        }
    }
}
