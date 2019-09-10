//
//  MessageCell.swift
//  Check-Up
//
//  Created by Amisha on 05/10/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var profilePicView: UIView!
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var ConstraintHeightMessageView: NSLayoutConstraint!
    @IBOutlet weak var ConstraintWidthMessageView: NSLayoutConstraint!
    @IBOutlet weak var durationLbl: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var constraintHeaderWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightHeaderView: NSLayoutConstraint!
    
   
    @IBOutlet weak var messageImgBtn: UIButton!
    @IBOutlet weak var ConstraintHeightMsgTxt: NSLayoutConstraint!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var errorBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headerLbl.addCornerRadiusForLabel(radius: 5.0)
        
        messageTxtView.isEditable = false
        messageTxtView.isSelectable = true
        messageTxtView.dataDetectorTypes = UIDataDetectorTypes.all
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
