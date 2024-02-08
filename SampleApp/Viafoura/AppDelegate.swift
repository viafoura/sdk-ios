//
//  AppDelegate.swift
//  Viafoura
//
//  Created by Martin De Simone on 26/04/2022.
//

import UIKit
import ViafouraSDK
import FirebaseCore
import FirebaseMessaging
import LoginRadiusSDK
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ViafouraSDK.initialize(siteUUID: "00000000-0000-4000-8000-c8cddfd7b365", siteDomain: "viafoura-mobile-demo.vercel.app")
        //ViafouraSDK.initialize(siteUUID: "00000000-0000-4000-8000-0892B54DBF4E", siteDomain: "www.thestar.com")
        //ViafouraSDK.initialize(siteUUID: "00000000-0000-4000-8000-a3692e0c0e77", siteDomain: "test.viafoura.com")
        //ViafouraSDK.initialize(siteUUID: "00000000-0000-4000-8000-0892b54dbf4e", siteDomain: "reactqa5.smgdigitaldev.com")
        
        FirebaseApp.configure()

        Messaging.messaging().delegate = self

        let sdk: LoginRadiusSDK = LoginRadiusSDK.instance()
        sdk.applicationLaunched(options: launchOptions)
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        ViafouraSDK.setLoggingEnabled(true)
        applyUIStyling()

        registerForNotifications(application: application)
        
        return true
    }
    
    func registerForNotifications(application: UIApplication){
        Messaging.messaging().subscribe(toTopic: "vfUsers")
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
    }

    func applyUIStyling(){
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
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

