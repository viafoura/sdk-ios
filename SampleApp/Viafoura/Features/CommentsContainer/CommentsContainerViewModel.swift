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
        
        articleMetadata = VFArticleMetadata(url: URL(string: story.link)!, title: story.title, subtitle: story.description, thumbnailUrl: URL(string: story.pictureUrl)!)
    }
}
