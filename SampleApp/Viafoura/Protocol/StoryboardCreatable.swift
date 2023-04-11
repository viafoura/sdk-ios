//
//  ProtocolCreatable.swift
//  Viafoura
//
//  Created by Martin De Simone on 11/04/2023.
//

import UIKit
public protocol StoryboardCreateable where Self: UIViewController {
    static var storyboardName: String { get }
}

extension StoryboardCreateable {
    public static func new() -> Self? {
        let storyboardBundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: Self.storyboardName, bundle: storyboardBundle)
        let storyboardIdentifier = String(describing: self)
        guard let vc = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as? Self else {
            return nil
        }
        return vc
    }
}
