//
//  CustomPinView.swift
//  Check-Up
//
//  Created by Amisha on 28/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class CustomPinView: UIView {

    @IBOutlet weak var pinImg: UIButton!
    @IBOutlet weak var totalCountBtn: UIButton!
    @IBOutlet weak var distanceLbl: UILabel!
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        totalCountBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.bringSubview(toFront: totalCountBtn)
    }
 

}
