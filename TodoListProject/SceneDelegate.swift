import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()

        let todoListViewController = TodoListViewController()

        let navigationController = UINavigationController(
            rootViewController: todoListViewController
        )
        navigationController.navigationBar.prefersLargeTitles = true

        window?.rootViewController = navigationController
    }
}
