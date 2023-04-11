//
//  LiveChatViewMode.swift
//  Viafoura
//
//  Created by Martin De Simone on 10/04/2023.
//

import ViafouraSDK
class LiveChatViewModel {
    let containerId: String
    let articleMetadata: VFArticleMetadata
    
    init(containerId: String, articleMetadata: VFArticleMetadata) {
        self.containerId = containerId
        self.articleMetadata = articleMetadata
    }
}
