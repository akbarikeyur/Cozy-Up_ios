//
//  CustomCommentTVC.swift
//  Check-Up
//
//  Created by Amisha on 28/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class CustomCommentTVC: UITableViewCell {

    @IBOutlet weak var userProfilePicBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var messageTxtView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userProfilePicBtn.addCornerRadius(radius: userProfilePicBtn.frame.size.width/2)
        
        messageTxtView.isEditable = false
        messageTxtView.isSelectable = true
        messageTxtView.dataDetectorTypes = UIDataDetectorTypes.all
        messageTxtView.linkTextAttributes = [NSForegroundColorAttributeName : colorFromHex(hex: "3C3739")]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
