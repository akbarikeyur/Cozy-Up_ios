//
//  CustomPinInfoWindow.swift
//  Check-Up
//
//  Created by Amisha on 10/09/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class CustomPinInfoWindow: UIView {

    
    @IBOutlet weak var pinContainerView: UIView!
    @IBOutlet weak var pinContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var pinContainerWidth: NSLayoutConstraint!
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var gameScoreBtn: UIButton!
    @IBOutlet weak var constraintWidthGameView: NSLayoutConstraint!
    
    @IBOutlet weak var worldCupView: UIView!
    @IBOutlet weak var worldCupScoreBtn: UIButton!
    @IBOutlet weak var constraintWidthWorldCupView: NSLayoutConstraint!
    
    @IBOutlet weak var trainingView: UIView!
    @IBOutlet weak var trainingScoreBtn: UIButton!
    @IBOutlet weak var constraintWidthTrainingView: NSLayoutConstraint!
   
    @IBOutlet weak var infoWindowBtn: UIButton!
    
    @IBOutlet weak var pinTitleView: UIView!
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var constraintWidthProfilePic: NSLayoutConstraint!
    @IBOutlet weak var pinTitleLbl: UILabel!
    @IBOutlet weak var pinAddressLbl: UILabel!
    @IBOutlet weak var constraintHeightPinTitleView: NSLayoutConstraint!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func draw(_ rect: CGRect) {
        // Drawing code
        pinTitleView.addCornerRadiusOfView(radius: 5.0)
        profilePicBtn.addCornerRadius(radius: profilePicBtn.frame.size.height/2)
    }
    
}
