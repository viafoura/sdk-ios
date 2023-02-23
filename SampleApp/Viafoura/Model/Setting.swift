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
}

public let defaultSettings: [Setting] = [
    Setting(title: "Use comments container on fullscreen", key: SettingsKeys.commentsContainerFullscreen),
    Setting(title: "Show trending articles", key: SettingsKeys.showTrendingArticles),
    Setting(title: "Dark mode", key: SettingsKeys.darkMode)
]
