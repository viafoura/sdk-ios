//
//  AppDelegate.swift
//  Viafoura
//
//  Created by Martin De Simone on 26/04/2022.
//

import UIKit
import ViafouraSDK
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let storedUUID = UserDefaults.standard.string(forKey: SettingsKeys.siteUUID)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let storedDomain = UserDefaults.standard.string(forKey: SettingsKeys.siteDomain)?.trimmingCharacters(in: .whitespacesAndNewlines)

        let rawSiteUUID = (storedUUID?.isEmpty == false ? storedUUID : nil) ?? SiteDefaults.siteUUID
        let siteDomain = (storedDomain?.isEmpty == false ? storedDomain : nil) ?? SiteDefaults.siteDomain

        guard let parsedSiteUUID = UUID(uuidString: rawSiteUUID.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            assertionFailure("Invalid Viafoura site UUID")
            return true
        }

        ViafouraSDK.initialize(siteUUID: parsedSiteUUID.uuidString.lowercased(), siteDomain: siteDomain)
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        ViafouraSDK.setLoggingEnabled(true)
        applyUIStyling()
        
        return true
    }

    func applyUIStyling(){
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
