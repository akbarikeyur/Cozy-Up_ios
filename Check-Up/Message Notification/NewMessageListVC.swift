//
//  NewMessageListVC.swift
//  Check-Up
//
//  Created by Amisha on 12/09/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class NewMessageListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var constraintHeightSearchView : NSLayoutConstraint!
    
    @IBOutlet weak var totalFriendsLbl: UILabel!
    @IBOutlet weak var friendsView: UIView!
    @IBOutlet weak var friendsTbl: UITableView!
    
    var arrFriends : [UserModel] = [UserModel] ()
    var arrSelectedUser : [String] = [String] ()
    
    var arrSearchFriends : [UserModel] = [UserModel] ()
    
    
    var isRecentDisplay : Bool!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(noti:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateMessage), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateMessage), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_INBOX), object: nil)
        
        friendsTbl.register(UINib.init(nibName: "CustomMessgaeTVC", bundle: nil), forCellReuseIdentifier: "CustomMessgaeTVC")
        
        setUIDesigning()
        onUpdateMessage()
    }

    func setUIDesigning()
    {
        friendsTbl.backgroundColor = UIColor.clear
        friendsTbl.separatorStyle = UITableViewCellSeparatorStyle.none
        friendsTbl.tableFooterView = UIView(frame: CGRect.zero)
        
        searchTxt.addCornerRadiusOfView(radius: 20)
        searchTxt.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        searchTxt.addPadding(padding: 10)
    }
    
    func onUpdateMessage()
    {
        if friendsTbl == nil
        {
            return
        }
        
        arrFriends = [UserModel] ()
        for i in 0..<AppModel.shared.USERS.count
        {
            let index = AppModel.shared.currentUser.contact.index(where: { (contact) -> Bool in
                contact.id == AppModel.shared.USERS[i].uID && contact.requestAction == 3
            })
            if index != nil {
                arrFriends.append(AppModel.shared.USERS[i])
            }
        }
        
        if arrFriends.count > 0
        {
            totalFriendsLbl.text = "Friends(" + String(arrFriends.count) + ")"
        }
        else
        {
            totalFriendsLbl.text = "No Friends"
        }
        arrFriends = sortUsers(arrFriends)
        friendsTbl.reloadData()
    }
    
    @IBAction func clickToBack(_ sender: Any)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (((searchTxt.text?.count)! > 0) ? arrSearchFriends.count : arrFriends.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = friendsTbl.dequeueReusableCell(withIdentifier: "CustomMessgaeTVC", for: indexPath) as! CustomMessgaeTVC
        
        let user : UserModel = ((searchTxt.text?.count)! > 0) ? arrSearchFriends[indexPath.row] : arrFriends[indexPath.row]
        
        AppDelegate().sharedDelegate().setUserProfileImage(user.uID, button: cell.profilePicBtn)
        
        cell.nameLbl.text = user.username
        cell.messageLbl.text = user.name
        
        cell.durationLbl.text = ""
        cell.constraintWidthDurationLbl.constant = 0
        cell.profilePicBtn.isUserInteractionEnabled = true
        cell.profilePicBtn.tag = indexPath.row
        cell.profilePicBtn.addTarget(self, action: #selector(clickToFriendUser(_:)), for: .touchUpInside)
        cell.selectionBtn.isHidden = true
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user : UserModel = ((searchTxt.text?.count)! > 0) ? arrSearchFriends[indexPath.row] : arrFriends[indexPath.row]
        if user.uID != nil && user.uID != ""
        {
            if(AppDelegate().sharedDelegate().isBlockUser(user.uID)){
                displayToast("Unblock for further proceed.")
            }
            else if(AppDelegate().sharedDelegate().isBlockMe(user)){
                displayToast("Opps, " + user.name + " has blocked you.")
            }
            else{
                AppDelegate().sharedDelegate().onChannelTap(connectUserId: user.uID)
            }
        }
        else
        {
            displayToast( "Something wrong.")
        }
    }
    
    @IBAction func clickToFriendUser(_ sender: UIButton)
    {
        AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: ((searchTxt.text?.count)! == 0) ? arrFriends[sender.tag] : arrSearchFriends[sender.tag])
    }
    
    @IBAction func clickToSelectFriends(_ sender: UIButton)
    {
        self.view.endEditing(true)
        let user : UserModel! = arrFriends[sender.tag]
        
        let index = arrSelectedUser.index { (uID) -> Bool in
            uID == user.uID
        }
        
        if index == nil {
            arrSelectedUser.append(user.uID)
        }
        else{
            arrSelectedUser.remove(at: index!)
        }
        friendsTbl.reloadData()
    }
    
    func textFieldDidChange(noti : Notification)
    {
        let textField : UITextField = noti.object as! UITextField
        if textField == searchTxt
        {
            arrSearchFriends = [UserModel]()
            for user : UserModel in arrFriends
            {
                if user.name.lowercased().contains((searchTxt.text?.lowercased())!)
                {
                    arrSearchFriends.append(user)
                }
            }
            arrSearchFriends = sortUsers(arrSearchFriends)
            friendsTbl.reloadData()
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
