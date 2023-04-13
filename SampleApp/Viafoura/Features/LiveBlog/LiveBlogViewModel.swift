//
//  LiveBlogViewModel.swift
//  Viafoura
//
//  Created by Martin De Simone on 28/03/2023.
//

import ViafouraSDK
import Foundation

class LiveBlogViewModel {
    let story: Story
    var articleMetadata: VFArticleMetadata!
        
    init(story: Story){
        self.story = story
        
        articleMetadata = VFArticleMetadata(url: URL(string: story.link)!, title: story.title, subtitle: story.description, thumbnailUrl: URL(string: story.pictureUrl)!)
    }
}
