//
//  ContactsVC.swift
//  Check-Up
//
//  Created by Amisha on 26/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import MessageUI
import FBSDKMessengerShareKit
import FBSDKShareKit

class ContactsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, customAlertDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet var blockUserTblView: UITableView!
    @IBOutlet var friendTblView: UITableView!
    @IBOutlet weak var allAppUserTbl: UITableView!
    
    @IBOutlet weak var blockUserView: UIView!
    @IBOutlet weak var friendsView: UIView!
    @IBOutlet weak var allAppUserView: UIView!
    
    @IBOutlet weak var searchTxt: UITextField!
    
    @IBOutlet var constrainHeightblockUserTbl: NSLayoutConstraint!
    @IBOutlet var constrainHeightFriendTbl: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightAllAppUserView: NSLayoutConstraint!
    
    var arrBlockUser  = [UserModel]()
    var arrFriends = [UserModel]()
    var selectedUser : UserModel!
    var arrAllAppUser = [UserModel]()
    var arrSearchAllAppUser = [UserModel]()
    
    var alert : customAlertView!
    
    var shareMessage : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(noti:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateContactList), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
        
        blockUserTblView.register(UINib.init(nibName: "CustomContactTVC", bundle: nil), forCellReuseIdentifier: "CustomContactTVC")
        friendTblView.register(UINib.init(nibName: "CustomContactTVC", bundle: nil), forCellReuseIdentifier: "CustomContactTVC")
        allAppUserTbl.register(UINib.init(nibName: "CustomContactTVC", bundle: nil), forCellReuseIdentifier: "CustomContactTVC")
        
        searchTxt.addCornerRadiusOfView(radius: 20)
        searchTxt.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        searchTxt.addPadding(padding: 10)
        
        shareMessage = "CheckUp :\nTo use this app, install it from : " + APP.SHARE_URL
        
        onUpdateContactList()
    }

    func onUpdateContactList()
    {
        arrFriends = [UserModel] ()
        arrBlockUser = [UserModel]()
        
        for i in 0..<AppModel.shared.USERS.count
        {
            let index = AppModel.shared.currentUser.contact.index(where: { (contact) -> Bool in
                contact.id == AppModel.shared.USERS[i].uID && contact.requestAction == 3
            })
            if index != nil {
                if(AppDelegate().sharedDelegate().isBlockUser(AppModel.shared.USERS[i].uID)){
                    arrBlockUser.append(AppModel.shared.USERS[i])
                }
                else{
                    arrFriends.append(AppModel.shared.USERS[i])
                }
            }
        }
        
        setTableViewHeight()
        
        onUpdateAppUserList()
    }
    
    func onUpdateAppUserList()
    {
        arrAllAppUser = [UserModel] ()
        for i in 0..<AppModel.shared.USERS.count
        {
            let index = AppModel.shared.currentUser.contact.index(where: { (tempContact) -> Bool in
                tempContact.id == AppModel.shared.USERS[i].uID && tempContact.requestAction == 3
            })
            
            if index == nil
            {
                arrAllAppUser.append(AppModel.shared.USERS[i])
            }
        }
    }
    
    func setTableViewHeight()
    {
        if searchTxt.text == ""
        {
            arrBlockUser = sortUsers(arrBlockUser)
            blockUserTblView.reloadData()
            if arrBlockUser.count > 0
            {
                constrainHeightblockUserTbl.constant = blockUserTblView.contentSize.height + 40
                blockUserView.isHidden = false
            }
            else
            {
                constrainHeightblockUserTbl.constant = 0
                blockUserView.isHidden = true
            }
            
            arrFriends = sortUsers(arrFriends)
            friendTblView.reloadData()
            if arrFriends.count > 0
            {
                constrainHeightFriendTbl.constant = friendTblView.contentSize.height + 40
                friendsView.isHidden = false
            }
            else
            {
                constrainHeightFriendTbl.constant = 0
                friendsView.isHidden = true
            }
            
            allAppUserView.isHidden = true
            constraintHeightAllAppUserView.constant = 0
        }
        else
        {
            arrSearchAllAppUser = sortUsers(arrSearchAllAppUser)
            allAppUserTbl.reloadData()
            constrainHeightblockUserTbl.constant = 0
            blockUserView.isHidden = true
            constrainHeightFriendTbl.constant = 0
            friendsView.isHidden = true
            
            allAppUserView.isHidden = false
            constraintHeightAllAppUserView.constant = allAppUserTbl.contentSize.height + 40
        }
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToAddFriend(_ sender: Any)
    {
        self.view.endEditing(true)
    }
    
    @IBAction func clickToFacebook(_ sender: Any)
    {
        let content = FBSDKShareLinkContent()
        content.quote = shareMessage.replacingOccurrences(of: APP.SHARE_URL, with: "")
        content.contentURL = URL(string: APP.SHARE_URL)
        
        let messageDialog = FBSDKMessageDialog()
        messageDialog.delegate = nil
        messageDialog.shareContent = content
        
        if messageDialog.canShow() {
            messageDialog.show()
        }
        
}
    
    @IBAction func clickToContactList(_ sender: Any)
    {
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = shareMessage
        messageVC.messageComposeDelegate = self;
        
        self.present(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == blockUserTblView {
            return arrBlockUser.count
        }
        else if tableView == friendTblView {
            return arrFriends.count
        }
        else if tableView == allAppUserTbl {
            return arrSearchAllAppUser.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == blockUserTblView
        {
            let cell : CustomContactTVC = blockUserTblView.dequeueReusableCell(withIdentifier: "CustomContactTVC", for: indexPath) as! CustomContactTVC
            
            let user : UserModel = arrBlockUser[indexPath.row]
            cell.titleLbl.text = user.username
            cell.subTitleLbl.text = user.name
            
            AppDelegate().sharedDelegate().setUserProfileImage(user.uID, button: cell.userProfilePicBtn)
            
            if arrBlockUser.count - 1 == indexPath.row {
                cell.seperatorImgView.isHidden = true
            }else {
                cell.seperatorImgView.isHidden = false
            }
            cell.userProfilePicBtn.isUserInteractionEnabled = true
            cell.userProfilePicBtn.tag = indexPath.row
            cell.userProfilePicBtn.addTarget(self, action: #selector(clickToBlockUser(_:)), for: UIControlEvents.touchUpInside)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else if tableView == friendTblView
        {
            let cell : CustomContactTVC = friendTblView.dequeueReusableCell(withIdentifier: "CustomContactTVC", for: indexPath) as! CustomContactTVC
            
            let user : UserModel = arrFriends[indexPath.row]
            cell.titleLbl.text = user.username
            cell.subTitleLbl.text = user.name
            
            AppDelegate().sharedDelegate().setUserProfileImage(user.uID, button: cell.userProfilePicBtn)
            if arrFriends.count - 1 == indexPath.row {
                cell.seperatorImgView.isHidden = true
            }else {
                cell.seperatorImgView.isHidden = false
            }
            
            cell.userProfilePicBtn.isUserInteractionEnabled = true
            cell.userProfilePicBtn.tag = indexPath.row
            cell.userProfilePicBtn.addTarget(self, action: #selector(clickToFriendUser(_:)), for: UIControlEvents.touchUpInside)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else
        {
            let cell : CustomContactTVC = allAppUserTbl.dequeueReusableCell(withIdentifier: "CustomContactTVC", for: indexPath) as! CustomContactTVC
            
            let user : UserModel = arrSearchAllAppUser[indexPath.row]
            cell.titleLbl.text = user.username
            cell.subTitleLbl.text = user.name
            
            AppDelegate().sharedDelegate().setUserProfileImage(user.uID, button: cell.userProfilePicBtn)
            if arrFriends.count - 1 == indexPath.row {
                cell.seperatorImgView.isHidden = true
            }else {
                cell.seperatorImgView.isHidden = false
            }
            
            cell.userProfilePicBtn.isUserInteractionEnabled = false
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.view.endEditing(true)
        if tableView == blockUserTblView
        {
            selectedUser = arrBlockUser[indexPath.row]
            AppDelegate().sharedDelegate().reportUser(selectedUser, subject: "", vc: self)
        }
        else if tableView == friendTblView
        {
            selectedUser = arrFriends[indexPath.row]
            if selectedUser.uID != nil && selectedUser.uID != ""
            {
                if(AppDelegate().sharedDelegate().isBlockUser(selectedUser.uID)){
                    displayToast("Unblock for further proceed.")
                }
                else if(AppDelegate().sharedDelegate().isBlockMe(selectedUser)){
                    displayToast("Opps, " + selectedUser.name + " has blocked you.")
                }
                else{
                    AppDelegate().sharedDelegate().onChannelTap(connectUserId: selectedUser.uID)
                }
            }
            else
            {
                displayToast( "Something wrong.")
            }
        }
        else if tableView == allAppUserTbl
        {
            selectedUser = arrSearchAllAppUser[indexPath.row]
            AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: selectedUser)
        }
        
    }
    
    @IBAction func clickToBlockUser(_ sender: UIButton)
    {
        selectedUser = arrBlockUser[sender.tag]
        AppDelegate().sharedDelegate().reportUser(selectedUser, subject: "", vc: self)
    }
    
    
    @IBAction func clickToFriendUser(_ sender: UIButton)
    {
        selectedUser = arrFriends[sender.tag]
        AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: selectedUser)
    }
    
   
    
    @IBAction func clickToFriendUnfriendBtn(_ sender: UIButton)
    {
        //print(selectedUser.uID)
        unfriendConfirmation()
    }
    
    @IBAction func clickToSendMessage(_ sender: Any)
    {
        self.view.endEditing(true)
        
        if selectedUser.uID != nil && selectedUser.uID != ""
        {
            if(AppDelegate().sharedDelegate().isBlockUser(selectedUser.uID)){
                displayToast("Unblock for further proceed.")
            }
            else if(AppDelegate().sharedDelegate().isBlockMe(selectedUser)){
                displayToast("Opps, " + selectedUser.name + " has blocked you.")
            }
            else{
                AppDelegate().sharedDelegate().onChannelTap(connectUserId: selectedUser.uID)
            }
        }
        else
        {
            displayToast("Something wrong.")
        }
    }
    
    
    func unfriendConfirmation()
    {
        alert = self.storyboard?.instantiateViewController(withIdentifier: VIEW.ALERT) as! customAlertView
        alert.delegate = self
        self.view.addSubview(alert.view)
        displaySubViewtoParentView(self.view, subview: alert.view)
        
        alert.view.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.55, initialSpringVelocity: 1.0, options: [], animations: {() -> Void in
            self.alert.view.transform = CGAffineTransform.identity
        }, completion: {(_ finished: Bool) -> Void in
        })
        
        alert.alertTitle(title: "CheckUp", alertMessage: "Are you sure want to unfriend ?", cancelBtnTitle:"NO" , otherBtnTitle: "YES")
    }
    
    func selectDidOkay()
    {
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
            self.alert.view.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
            self.alert.view.alpha = 0.0
        }, completion: {(_ finished: Bool) -> Void in
            self.alert.view.removeFromSuperview()
        })
        
        
        //remove from friends
        AppDelegate().sharedDelegate().removeFriendFromUser(selectedUser)
        let index = arrFriends.index(where: { (user) -> Bool in
            user.uID == selectedUser.uID
        })
        if index != nil {
            arrFriends.remove(at: index!)
        }
        
        setTableViewHeight()
    }
    
    func selectDidCancel()
    {
        
    }
    
    // MARK: - TextField Delegate
    func textFieldDidChange(noti : Notification)
    {
        let textField : UITextField = noti.object as! UITextField
        if textField == searchTxt
        {
            arrSearchAllAppUser = [UserModel] ()
            for user : UserModel in arrAllAppUser
            {
                if (searchTxt.text == "*" || user.name.lowercased().contains((searchTxt.text?.lowercased())!)) || (user.username.lowercased().contains((searchTxt.text?.lowercased())!))
                {
                    arrSearchAllAppUser.append(user)
                }
            }
            setTableViewHeight()
        }
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
