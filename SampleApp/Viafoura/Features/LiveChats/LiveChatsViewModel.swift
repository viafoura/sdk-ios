//
//  LiveChatsViewModel.swift
//  Viafoura
//
//  Created by Martin De Simone on 14/11/2022.
//

import Foundation

enum LiveChatType {
    case portraitOverlay
    case fullscreen
    case portrait
}
struct LiveChat {
    let title: String
    let image: String
    let containerId: String
    let type: LiveChatType
}

class LiveChatsViewModel {
    var liveChats: [LiveChat] = []
    
    init(){
        liveChats.append(LiveChat(title: "Sports", image: "star", containerId: "sports", type: .portraitOverlay))
        liveChats.append(LiveChat(title: "Politics", image: "star", containerId: "politics", type: .portraitOverlay))
        liveChats.append(LiveChat(title: "Fashion", image: "star", containerId: "fashion", type: .portrait))
        liveChats.append(LiveChat(title: "Business", image: "star", containerId: "business", type: .fullscreen))
    }
}
