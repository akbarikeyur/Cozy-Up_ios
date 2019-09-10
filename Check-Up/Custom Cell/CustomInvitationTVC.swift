//
//  CustomInvitationTVC.swift
//  Check-Up
//
//  Created by Amisha on 11/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import SWTableViewCell

class CustomInvitationTVC: SWTableViewCell {

    @IBOutlet var profilePicBtn: UIButton!
    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var sentByUserLbl: UILabel!
    @IBOutlet var totalMemberLbl: UILabel!
    @IBOutlet var joinBtn: UIButton!
    @IBOutlet var timeBtn: UIButton!
    @IBOutlet var constraintTimeBtnYPosition: NSLayoutConstraint!
    @IBOutlet var seperatorImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        joinBtn.addCornerRadiusOfView(radius: 5.0)
        joinBtn.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        
        timeBtn.addCornerRadiusOfView(radius: 5.0)
        timeBtn.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
