//
//  StoryTableViewCell.swift
//  Viafoura
//
//  Created by Martin De Simone on 26/04/2022.
//

import UIKit
import Kingfisher

class StoryTableViewCell: UITableViewCell{
    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var storyDescLabel: UILabel!
    @IBOutlet weak var storyCategoryLabel: UILabel!
    @IBOutlet weak var storyAuthorLabel: UILabel!
    @IBOutlet weak var storyPictureImage: UIImageView!
    @IBOutlet weak var storyView: UIView!
    
    func setup(forStory story: Story){
        storyTitleLabel.text = story.title
        storyAuthorLabel.text = story.author
        storyCategoryLabel.text = story.category.uppercased() + " -"
        storyDescLabel.text = story.description.uppercased()
        
        storyPictureImage.image = nil
        storyPictureImage.kf.setImage(with: URL(string: story.pictureUrl))
        storyPictureImage.clipsToBounds = true
        storyPictureImage.layer.cornerRadius = 12
        storyPictureImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        storyView.backgroundColor = .white
        storyView.layer.masksToBounds = false
        storyView.layer.cornerCurve = .continuous
        storyView.layer.cornerRadius = 12
        storyView.layer.shadowColor = UIColor.black.cgColor
        storyView.layer.shadowOffset = CGSize(width: 0, height: 2)
        storyView.layer.shadowRadius = 8
        storyView.layer.shadowOpacity = 0.15
        storyView.layer.rasterizationScale = UIScreen.main.scale
        storyView.layer.shouldRasterize = true
        
        selectionStyle = .none
    }
}
