//
//  PollTableViewCell.swift
//  Viafoura
//
//  Created by Martin De Simone on 19/07/2023.
//

import UIKit
class PollTableViewCell: UITableViewCell{
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerImage: UIImageView!
    @IBOutlet weak var containerLabel: UILabel!
    
    func setup(forPoll poll: Poll){
        containerLabel.text = poll.title

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
