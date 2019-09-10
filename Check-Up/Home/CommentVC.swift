//
//  CommentVC.swift
//  Check-Up
//
//  Created by Amisha on 02/10/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class CommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var commentTbl: UITableView!
    
    @IBOutlet weak var commentTxtView: UIView!
    @IBOutlet weak var commentTxt: UITextField!
    @IBOutlet weak var sendCommentBtn: UIButton!
    @IBOutlet weak var noDataFoundLbl: UILabel!
    
    var court : CourtModel!
    var event : EventModel!
    
    var offscreenCommentCell : [String : Any] = [String : Any] ()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateComment), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_EVENTS), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateComment), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_COURTS), object: nil)

        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        commentTxtView.addCornerRadiusOfView(radius: 20)
        commentTxtView.applyBorderOfView(width: 1, borderColor: colorFromHex(hex: COLOR.LIGHT_TEXT))
        
        commentTbl.backgroundColor = UIColor.clear
        commentTbl.separatorStyle = UITableViewCellSeparatorStyle.none
        commentTbl.tableFooterView = UIView(frame: CGRect.zero)
        commentTbl.register(UINib.init(nibName: "CustomCommentTVC", bundle: nil), forCellReuseIdentifier: "CustomCommentTVC")
        
        onUpdateComment()
        setNoDataFoundData()
        
    }

    func onUpdateComment()
    {
        if commentTbl == nil
        {
            return
        }
        
        if event == nil {
            let index = AppModel.shared.COURTS.index { (tempCourt) -> Bool in
                tempCourt.location.id == court.location.id
            }
            
            if index != nil {
                court = AppModel.shared.COURTS[index!]
            }
            else{
                displayToast("Sorry,that court just expired!")
                _ = self.navigationController?.popToRootViewController(animated: true)
                
                return
            }
        }
        else
        {
            let index = AppModel.shared.EVENTS.index { (tempEvent) -> Bool in
                tempEvent.id == event.id
            }
            
            if index != nil {
                event = AppModel.shared.EVENTS[index!]
            }
            else{
                displayToast("Sorry,that event just expired!")
                _ = self.navigationController?.popToRootViewController(animated: true)

                return
            }
        }
        
        commentTbl.reloadData()
    }
    
    func setNoDataFoundData()
    {
        if event == nil {
            noDataFoundLbl.isHidden = (court.comment.count > 0)
        }
        else
        {
            noDataFoundLbl.isHidden = (event.comment.count > 0)
        }
    }
    
    @IBAction func clickToSendComment(_ sender: Any)
    {
        self.view.endEditing(true)
        if (commentTxt.text?.count)! > 0
        {
            let comment : CommentModel = CommentModel.init(id: "", comment_userID: AppModel.shared.currentUser.uID, text: commentTxt.text!.encodeString, date: getCurrentDateInString())
            
            if court != nil {
                AppDelegate().sharedDelegate().addCommentToCourt(comment, court: court)
            }
            else
            {
                AppDelegate().sharedDelegate().addCommentToEvent(comment, event: event)
            }
            
            commentTbl.reloadData()
            commentTxt.text = ""
            setNoDataFoundData()
        }
    }
    
    @IBAction func clickToBack(_ sender: Any)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if event == nil {
            return court.comment.count
        }else{
            return event.comment.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        //return 75
        var cell = offscreenCommentCell["CustomCommentTVC"] as? CustomCommentTVC
        if cell == nil {
            cell = commentTbl.dequeueReusableCell(withIdentifier: "CustomCommentTVC") as? CustomCommentTVC
            offscreenCommentCell["CustomCommentTVC"] = cell
        }
        if cell == nil
        {
            return 75.0
        }
        let comment : CommentModel!
            
        if event == nil {
            comment = court.comment[indexPath.row]
        }else{
            comment = event.comment[indexPath.row]
        }
        
        cell?.messageTxtView.text = comment.text.decodeString
        
        let sizeThatFitsTextView:CGSize = cell!.messageTxtView.sizeThatFits(CGSize(width: commentTbl.frame.size.width-85, height: CGFloat(MAXFLOAT)))
        
        let height : Float = Float(75 - 37 + sizeThatFitsTextView.height)
        
        if height > 75
        {
            return CGFloat(height)
        }
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : CustomCommentTVC = commentTbl.dequeueReusableCell(withIdentifier: "CustomCommentTVC", for: indexPath) as! CustomCommentTVC
        
        cell.userProfilePicBtn.setBackgroundImage(UIImage(named: IMAGE.PLACEHOLDER_USER), for: UIControlState.normal)
        cell.nameLbl.text = ""
        cell.messageTxtView.text = ""
        
        let comment : CommentModel!
        
        if event == nil {
            comment = court.comment[indexPath.row]
        }else{
            comment = event.comment[indexPath.row]
        }
        
        let index = AppModel.shared.USERS.index { (user) -> Bool in
            user.uID == comment.comment_userID
        }
        var user : UserModel!
        if index != nil
        {
            user = AppModel.shared.USERS[index!]
        }
        else
        {
            user = AppModel.shared.currentUser
        }
        
        AppDelegate().sharedDelegate().setUserProfileImage(user.uID, button: cell.userProfilePicBtn)
        
        cell.nameLbl.text = user.name
        cell.messageTxtView.text = comment.text.decodeString
        cell.timeLbl.text = getDifferenceFromCurrentTimeInHourInDays(date: comment.date)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
