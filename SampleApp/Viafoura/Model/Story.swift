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
    let storyType: StoryType
}

enum StoryType {
    case blog
    case comments
}

public let defaultStories: [Story] = [
    Story(pictureUrl: "https://www.datocms-assets.com/55856/1636753460-information-overload.jpg?crop=focalpoint&fit=crop&fm=webp&fp-x=0.86&fp-y=0.47&h=428&w=856", title: "Moving Staff to Cover the Coronavirus", description: "Here Are What Media Companies Are Doing to Deal With COVID-19 Information Overload", author: "Norman Phillips", category: "ECONOMIA", link: "https://viafoura-mobile-demo.vercel.app/posts/here-are-what-media-companies-are-doing-with-covid-19-overload", containerId: "101113541", storyType: .comments),
    Story(pictureUrl: "https://www.datocms-assets.com/55856/1636663477-blognewheights.jpg?fit=crop&fm=webp&h=428&w=856", title: "Grow civility", description: "Don't shut out your community, instead guide them towards civility", author: "Tom Hardington", category: "ECONOMIA", link: "https://viafoura-mobile-demo.vercel.app/posts/dont-shut-out-your-community-guide-them-to-civility", containerId: "101113531", storyType: .comments),
    Story(pictureUrl: "https://www.datocms-assets.com/55856/1639925068-brexit-to-cost-the-uk.jpg?fit=crop&fm=webp&h=428&w=856", title: "Brexit cost", description: "Brexit to cost £1,200 for each person in UK", author: "Tom Hardington", category: "ECONOMIA", link: "https://viafoura-mobile-demo.vercel.app/posts/brexit-to-cost-gbp1-200-for-each-person-in-uk", containerId: "101113509", storyType: .comments)
]
