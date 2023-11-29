//
//  Content.swift
//  Viafoura
//
//  Created by Martin De Simone on 19/07/2023.
//

import Foundation
public struct Content {
    let type: ContentType
    let story: Story?
    let poll: Poll?
}

public enum ContentType {
    case story
    case poll
}

public let defaultContents: [Content] = [
    Content(type: .story, story: Story(pictureUrl: "https://www.datocms-assets.com/55856/1636753460-information-overload.jpg?crop=focalpoint&fit=crop&fm=webp&fp-x=0.86&fp-y=0.47&h=428&w=856", title: "Moving Staff to Cover the Coronavirus", description: "Here Are What Media Companies Are Doing to Deal With COVID-19 Information Overload", author: "Norman Phillips", category: "ECONOMIA", link: "https://viafoura-mobile-demo.vercel.app/posts/here-are-what-media-companies-are-doing-with-covid-19-overload", containerId: "d79c8098-5e7f-5a5f-82a7-be80c9d8b5f1", authorId: "3147700024522", storyType: .comments), poll: nil),
    Content(type: .poll, story: nil, poll: Poll(contentContainerUUID: UUID(uuidString: "9BC06A89-2B04-402F-8379-D4E21A249B3C")!, title: "Who is the best player ever?")),
    Content(type: .story, story: Story(pictureUrl: "https://www.datocms-assets.com/55856/1636663477-blognewheights.jpg?fit=crop&fm=webp&h=428&w=856", title: "Grow civility", description: "Don't shut out your community, instead guide them towards civility", author: "Tom Hardington", category: "ECONOMIA", link: "https://viafoura-mobile-demo.vercel.app/posts/dont-shut-out-your-community-guide-them-to-civility", containerId: "101113531", authorId: "3147700024522", storyType: .comments), poll: nil),
    Content(type: .story, story: Story(pictureUrl: "https://www.datocms-assets.com/55856/1639925068-brexit-to-cost-the-uk.jpg?fit=crop&fm=webp&h=428&w=856", title: "Brexit cost", description: "Brexit to cost £1,200 for each person in UK", author: "Tom Hardington", category: "ECONOMIA", link: "https://viafoura-mobile-demo.vercel.app/posts/brexit-to-cost-gbp1-200-for-each-person-in-uk", containerId: "a0335064233e55d-4442-aa6b-7fdcfe54636b", authorId: "3147700024522", storyType: .comments), poll: nil)
]
