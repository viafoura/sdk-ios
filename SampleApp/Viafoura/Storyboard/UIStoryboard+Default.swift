//
//  UIStoryboard+Default.swift
//  Viafoura
//
//  Created by Martin De Simone on 27/04/2022.
//

import Foundation
import UIKit
extension UIStoryboard{
    static func defaultStoryboard() -> UIStoryboard{
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
}
