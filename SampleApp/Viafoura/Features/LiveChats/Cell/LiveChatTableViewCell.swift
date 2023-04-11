//
//  LiveChatTableViewCell.swift
//  Viafoura
//
//  Created by Martin De Simone on 14/11/2022.
//

import UIKit

class LiveChatTableViewCell: UITableViewCell{
    @IBOutlet weak var liveChatImage: UIImageView!
    @IBOutlet weak var liveChatLabel: UILabel!
    
    func setup(forChat liveChat: LiveChat){
        liveChatLabel.text = liveChat.title
        liveChatImage.image = UIImage(systemName: liveChat.image)
        
        selectionStyle = .none
    }
}
