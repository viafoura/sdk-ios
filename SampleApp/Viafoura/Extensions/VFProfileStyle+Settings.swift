//
//  VFProfileStyle+Settings.swift
//  Viafoura
//

import Foundation
import ViafouraSDK

extension VFProfileStyle {
    static var fromSettings: VFProfileStyle {
        UserDefaults.standard.bool(forKey: SettingsKeys.useDrawerProfile) ? .drawer : .default
    }
}
