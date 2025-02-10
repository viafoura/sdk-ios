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
    
    static func randomWithContainerId(containerId: String) -> Story{
        Story(pictureUrl: "https://www.datocms-assets.com/55856/1636753460-information-overload.jpg?crop=focalpoint&fit=crop&fm=webp&fp-x=0.86&fp-y=0.47&h=428&w=856", title: "Moving Staff to Cover the Coronavirus", description: "Here Are What Media Companies Are Doing to Deal With COVID-19 Information Overload", author: "Norman Phillips", category: "ECONOMY", link: "https://viafoura-mobile-demo.vercel.app/posts/here-are-what-media-companies-are-doing-with-covid-19-overload", containerId: containerId, authorId: "3147700024522", storyType: .comments)
    }
}

enum StoryType {
    case comments
    case reviews
}
