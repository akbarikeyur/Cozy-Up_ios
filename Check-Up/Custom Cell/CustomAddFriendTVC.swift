//
//  CustomAddFriendTVC.swift
//  Check-Up
//
//  Created by Amisha on 11/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import SWTableViewCell

class CustomAddFriendTVC: SWTableViewCell {

    @IBOutlet var profilePicBtn: UIButton!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var locationLbl: UILabel!
    @IBOutlet var addBtn: UIButton!
    @IBOutlet var seperatorImgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profilePicBtn.addCornerRadiusOfView(radius: profilePicBtn.frame.size.width/2)
        
        addBtn.addCornerRadiusOfView(radius: 5.0)
        addBtn.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
