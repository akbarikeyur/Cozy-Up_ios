//
//  CustomMessgaeTVC.swift
//  Check-Up
//
//  Created by Amisha on 13/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import SWTableViewCell

class CustomMessgaeTVC: SWTableViewCell {

    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var selectionBtn: UIButton!
    @IBOutlet weak var badgesLbl: UILabel!
    @IBOutlet weak var imageMsgBtn: UIButton!
    @IBOutlet weak var seperatorImg: UIImageView!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var constraintWidthDurationLbl: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profilePicBtn.addCornerRadius(radius: profilePicBtn.frame.size.width/2)
        
        badgesLbl.addCornerRadiusForLabel(radius: badgesLbl.frame.size.width/2)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
