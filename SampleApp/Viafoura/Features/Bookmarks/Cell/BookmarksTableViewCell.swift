//
//  BookmarksTableViewCell.swift
//  Viafoura
//
//  Created by Martin De Simone on 14/11/2022.
//

import UIKit

class BookmarksTableViewCell: UITableViewCell{
    @IBOutlet weak var bookmarkImage: UIImageView!
    @IBOutlet weak var bookmarkLabel: UILabel!
    
    func setup(forBookmark bookmark: Bookmark){
        bookmarkLabel.text = bookmark.title
        bookmarkImage.image = UIImage(systemName: bookmark.image)
        
        selectionStyle = .none
    }
}
