//
//  SendChatMessageTVC.swift
//  Check-Up
//
//  Created by Amisha on 29/09/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class SendChatMessageTVC: MessageCell {

   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profilePicView.addCornerRadiusOfView(radius: profilePicView.frame.size.height/2)
        profilePicBtn.addCornerRadiusOfView(radius: profilePicBtn.frame.size.height/2)
        messageView.addCornerRadiusOfView(radius: 5.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
