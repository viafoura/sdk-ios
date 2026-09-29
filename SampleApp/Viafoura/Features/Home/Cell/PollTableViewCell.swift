//
//  PollTableViewCell.swift
//  Viafoura
//
//  Created by Martin De Simone on 19/07/2023.
//

import UIKit
class PollTableViewCell: UITableViewCell{
    
    let containerView = UIView()
    let containerImage = UIImageView()
    let containerLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout(){
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        contentView.addSubview(containerView)

        containerImage.translatesAutoresizingMaskIntoConstraints = false
        containerImage.contentMode = .scaleAspectFit
        containerView.addSubview(containerImage)

        containerLabel.translatesAutoresizingMaskIntoConstraints = false
        containerLabel.font = .systemFont(ofSize: 17, weight: .medium)
        containerLabel.textColor = .black
        containerView.addSubview(containerLabel)

        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 14),
            containerView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -14),
            containerView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),

            containerImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            containerImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            containerImage.widthAnchor.constraint(equalToConstant: 40),
            containerImage.heightAnchor.constraint(equalToConstant: 40),

            containerLabel.leadingAnchor.constraint(equalTo: containerImage.trailingAnchor, constant: 24),
            containerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            containerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            containerLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            containerLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    func setup(forPoll poll: Poll){
        setup(title: poll.title, image: "soccerball")
    }

    func setup(title: String, image: String) {
        containerLabel.text = title

        containerImage.image = UIImage(systemName: image)?.withRenderingMode(.alwaysTemplate)

        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = false
        containerView.layer.cornerCurve = .continuous
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.rasterizationScale = UIScreen.main.scale
        containerView.layer.shouldRasterize = true
        
        selectionStyle = .none
    }
}
