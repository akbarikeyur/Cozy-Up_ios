//
//  CustomContactTVC.swift
//  Check-Up
//
//  Created by Amisha on 26/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class CustomContactTVC: UITableViewCell {

    @IBOutlet weak var userProfilePicBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var seperatorImgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userProfilePicBtn.addCornerRadius(radius: userProfilePicBtn.frame.size.width/2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
