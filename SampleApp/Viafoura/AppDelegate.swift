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
        ViafouraSDK.initialize(siteUUID: "00000000-0000-4000-8000-d47205fca416", siteDomain: "demo.viafoura.com")
        
        //ViafouraSDK.initialize(siteUUID: "00000000-0000-4000-8000-82628f44cd3d", siteDomain: "www.clarin.com")
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        ViafouraSDK.setLoggingEnabled(true)
        applyUIStyling()
        return true
    }
    
    func applyUIStyling(){
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.backgroundColor = .white
            appearance.shadowColor = .clear
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

