//
//  customAlertView.swift
//  Check-Up
//
//  Created by Amisha on 12/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

@objc protocol customAlertDelegate
{
    @objc optional func selectDidCancel()
    @objc optional func selectDidOkay()
    @objc optional func selectDidSingleCancel()
}

class customAlertView: UIViewController {

    var delegate:customAlertDelegate?
    @IBOutlet var popupView: UIView!
    @IBOutlet var titleView: UIView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var alertMsgView: UIView!
    @IBOutlet var alertMsgLbl: UILabel!
    @IBOutlet var singleBtnView: UIView!
    @IBOutlet var cancelSingleBtn: UIButton!
    @IBOutlet var doubleBtnView: UIView!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var okBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        popupView.layer.cornerRadius = 10.0
        popupView.layer.masksToBounds = true
        
        alertButtonDesign(button: okBtn)
        alertButtonDesign(button: cancelBtn)
        alertButtonDesign(button: cancelSingleBtn)
    }
    
    func alertButtonDesign(button:UIButton)
    {
        button.layer.cornerRadius = 5;
        button.titleLabel?.numberOfLines = 1;
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
    }

    func alertTitle(title: String, alertMessage alertMsg: String, cancelBtnTitle cancel: String, otherBtnTitle other: String) {
        
        titleLbl.text = title
        alertMsgLbl.text = alertMsg
        
        cancelSingleBtn.setTitle(cancel, for: .normal)
        cancelBtn.setTitle(cancel, for: .normal)
        
        if other.count > 0
        {
            doubleBtnView.isHidden = false
            singleBtnView.isHidden = true
            okBtn.setTitle(other, for: .normal)
        }
        else
        {
            doubleBtnView.isHidden = true
            singleBtnView.isHidden = false
        }
        
    }
    
    @IBAction func outerBtnClicked(_ sender: Any)
    {
        delegate?.selectDidCancel!()
    }
    
    @IBAction func clickToCancelSingleBtn(_ sender: Any)
    {
        delegate?.selectDidSingleCancel!()
    }
    
    @IBAction func clickToCancelBtn(_ sender: Any)
    {
        delegate?.selectDidCancel!()
    }
    
    @IBAction func clickToOkBtn(_ sender: Any)
    {
        delegate?.selectDidOkay!()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
