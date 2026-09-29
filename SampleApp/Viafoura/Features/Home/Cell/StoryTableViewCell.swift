//
//  StoryTableViewCell.swift
//  Viafoura
//
//  Created by Martin De Simone on 26/04/2022.
//

import UIKit
import Kingfisher

class StoryTableViewCell: UITableViewCell{
    let storyTitleLabel = UILabel()
    let storyDescLabel = UILabel()
    let storyCategoryLabel = UILabel()
    let storyAuthorLabel = UILabel()
    let storyPictureImage = UIImageView()
    let storyView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout(){
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground

        storyView.translatesAutoresizingMaskIntoConstraints = false
        storyView.backgroundColor = .systemBackground
        contentView.addSubview(storyView)

        storyPictureImage.translatesAutoresizingMaskIntoConstraints = false
        storyPictureImage.contentMode = .scaleAspectFill
        storyPictureImage.clipsToBounds = true
        storyView.addSubview(storyPictureImage)

        storyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        storyTitleLabel.font = .systemFont(ofSize: 23, weight: .heavy)
        storyTitleLabel.textColor = .black
        storyView.addSubview(storyTitleLabel)

        storyDescLabel.translatesAutoresizingMaskIntoConstraints = false
        storyDescLabel.font = .systemFont(ofSize: 16, weight: .light)
        storyDescLabel.textColor = .black
        storyDescLabel.numberOfLines = 3
        storyView.addSubview(storyDescLabel)

        let metadataColor = UIColor(white: 0.667, alpha: 1)

        storyCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        storyCategoryLabel.font = .systemFont(ofSize: 13)
        storyCategoryLabel.textColor = metadataColor
        storyView.addSubview(storyCategoryLabel)

        storyAuthorLabel.translatesAutoresizingMaskIntoConstraints = false
        storyAuthorLabel.font = .systemFont(ofSize: 13)
        storyAuthorLabel.textColor = metadataColor
        storyView.addSubview(storyAuthorLabel)

        NSLayoutConstraint.activate([
            storyView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            storyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            storyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            storyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            storyPictureImage.topAnchor.constraint(equalTo: storyView.topAnchor),
            storyPictureImage.leadingAnchor.constraint(equalTo: storyView.leadingAnchor),
            storyPictureImage.trailingAnchor.constraint(equalTo: storyView.trailingAnchor),
            storyPictureImage.heightAnchor.constraint(equalToConstant: 100),

            storyTitleLabel.topAnchor.constraint(equalTo: storyPictureImage.bottomAnchor, constant: 10),
            storyTitleLabel.leadingAnchor.constraint(equalTo: storyView.leadingAnchor, constant: 20),
            storyTitleLabel.trailingAnchor.constraint(equalTo: storyView.trailingAnchor, constant: -20),

            storyDescLabel.topAnchor.constraint(equalTo: storyTitleLabel.bottomAnchor),
            storyDescLabel.leadingAnchor.constraint(equalTo: storyView.leadingAnchor, constant: 20),
            storyDescLabel.trailingAnchor.constraint(equalTo: storyView.trailingAnchor, constant: -20),

            storyCategoryLabel.topAnchor.constraint(equalTo: storyDescLabel.bottomAnchor, constant: 20),
            storyCategoryLabel.leadingAnchor.constraint(equalTo: storyView.leadingAnchor, constant: 20),

            storyAuthorLabel.topAnchor.constraint(equalTo: storyDescLabel.bottomAnchor, constant: 20),
            storyAuthorLabel.leadingAnchor.constraint(equalTo: storyCategoryLabel.trailingAnchor, constant: 5)
        ])
    }
    
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
