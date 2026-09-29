//
//  SceneDelegate.swift
//  Viafoura
//
//  Created by Martin De Simone on 26/04/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.tintColor = AppStyle.tintColor
        window.rootViewController = MainTabBarController()
        self.window = window
        window.makeKeyAndVisible()
    }
}
