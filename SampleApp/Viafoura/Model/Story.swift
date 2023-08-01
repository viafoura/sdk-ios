//
//  Story.swift
//  Viafoura
//
//  Created by Martin De Simone on 26/04/2022.
//

public struct Story {
    let pictureUrl: String
    let title: String
    let description: String
    let author: String
    let category: String
    let link: String
    let containerId: String
    let authorId: String
    let storyType: StoryType
}

enum StoryType {
    case blog
    case comments
}
