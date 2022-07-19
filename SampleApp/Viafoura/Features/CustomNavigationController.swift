//
//  CustomNavigationController.swift
//  Viafoura
//
//  Created by Martin De Simone on 15/06/2022.
//

import UIKit

class CustomNavigationController : UINavigationController {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if let topVC = viewControllers.last {
            return topVC.preferredStatusBarStyle
        }

        return .default
    }
}
