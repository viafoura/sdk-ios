//
//  CommentsContainerViewModel.swift
//  Viafoura
//
//  Created by Martin De Simone on 28/11/2022.
//

import Foundation
import ViafouraSDK

class CommentsContainerViewModel {
    let story: Story
    var articleMetadata: VFArticleMetadata!
        
    init(story: Story){
        self.story = story
        
        let storedDomain = UserDefaults.standard.string(forKey: SettingsKeys.siteDomain)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let siteDomain = (storedDomain?.isEmpty == false ? storedDomain : nil) ?? SiteDefaults.siteDomain

        let originalUrl = URL(string: story.link)
        var url = originalUrl
        if let originalUrl, var components = URLComponents(url: originalUrl, resolvingAgainstBaseURL: false) {
            components.host = siteDomain
            url = components.url ?? originalUrl
        }
        articleMetadata = VFArticleMetadata(url: url ?? URL(string: "https://\(siteDomain)")!, title: story.title, subtitle: story.description, thumbnailUrl: URL(string: story.pictureUrl)!)
    }
}
