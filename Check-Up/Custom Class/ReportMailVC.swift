//
//  ReportMailVC.swift
//  Check-Up
//
//  Created by PC on 11/27/17.
//  Copyright © 2017 AK Infotech. All rights reserved.
//

import UIKit
import MessageUI

class ReportMailVC: UIViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

     override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func reportUser(_ selectedUser:UserModel, subject:String){
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients([APP.REPORT_EMAIL])
        composeVC.setSubject(subject)
        composeVC.setMessageBody("Reported User : " + selectedUser.username, isHTML: false)
        // Present the view controller modally.
        present(composeVC, animated: true)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
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
