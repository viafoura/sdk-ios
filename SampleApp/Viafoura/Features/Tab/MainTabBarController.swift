//
//  MainTabBarController.swift
//  Viafoura
//
//  Created by Martin De Simone on 27/04/2022.
//

import Foundation
import UIKit
class MainTabBarController: UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .red
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white

            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = self.tabBar.standardAppearance
        }
    }
}
