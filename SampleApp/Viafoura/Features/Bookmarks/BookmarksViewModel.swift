//
//  BookmarksViewModel.swift
//  Viafoura
//
//  Created by Martin De Simone on 14/11/2022.
//

import Foundation
struct Bookmark {
    let title: String
    let image: String
}

class BookmarksViewModel {
    var bookmarks: [Bookmark] = []
    
    init(){
        bookmarks.append(Bookmark(title: "Enterteinment", image: "star"))
    }
}
