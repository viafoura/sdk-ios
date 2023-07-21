//
//  Setting.swift
//  Viafoura
//
//  Created by Martin De Simone on 28/11/2022.
//

import Foundation
public struct Setting {
    let title: String
    let key: String
}

public struct SettingsKeys {
    public static let showTrendingArticles = "showTrendingArticles"
    public static let commentsContainerFullscreen = "commentsContainerFullscreen"
    public static let darkMode = "darkMode"
    public static let showNotificationBellInTopBar = "showNotificationBellInTopBar"
    public static let showPolls = "showPolls"
}

public let defaultSettings: [Setting] = [
    Setting(title: "Use comments container on fullscreen", key: SettingsKeys.commentsContainerFullscreen),
    Setting(title: "Show trending articles", key: SettingsKeys.showTrendingArticles),
    Setting(title: "Dark mode", key: SettingsKeys.darkMode),
    Setting(title: "Show notification bell in top bar", key: SettingsKeys.showNotificationBellInTopBar),
    Setting(title: "Show polls", key: SettingsKeys.showPolls)
]
