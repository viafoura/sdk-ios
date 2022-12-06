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

struct SettingsKeys {
    static let showTrendingArticles = "showTrendingArticles"
    static let commentsContainerFullscreen = "commentsContainerFullscreen"
}

public let defaultSettings: [Setting] = [
    Setting(title: "Use comments container on fullscreen", key: SettingsKeys.commentsContainerFullscreen),
    Setting(title: "Show trending articles", key: SettingsKeys.showTrendingArticles)
]
