//
//  CustomCourtStoryCell.swift
//  Check-Up
//
//  Created by Amisha on 07/10/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class CustomCourtStoryCell: UITableViewCell {

    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var selectionBtn: UIButton!
    @IBOutlet weak var seperatorImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profilePicBtn.addCornerRadius(radius: profilePicBtn.frame.size.width/2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
