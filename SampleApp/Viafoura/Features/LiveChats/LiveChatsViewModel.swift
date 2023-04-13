//
//  LiveChatsViewModel.swift
//  Viafoura
//
//  Created by Martin De Simone on 14/11/2022.
//

import Foundation
struct LiveChat {
    let title: String
    let image: String
    let containerId: String
    let isVideo: Bool
}

class LiveChatsViewModel {
    var liveChats: [LiveChat] = []
    
    init(){
        liveChats.append(LiveChat(title: "Sports", image: "star", containerId: "sports", isVideo: true))
        liveChats.append(LiveChat(title: "Politics", image: "star", containerId: "politics", isVideo: false))
        liveChats.append(LiveChat(title: "Fashion", image: "star", containerId: "fashion", isVideo: false))
        liveChats.append(LiveChat(title: "Business", image: "star", containerId: "business", isVideo: false))
    }
}
