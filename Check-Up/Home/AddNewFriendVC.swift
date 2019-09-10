//
//  AddNewFriendVC.swift
//  Check-Up
//
//  Created by Amisha on 01/10/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class AddNewFriendVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var noDatafound: UILabel!
    @IBOutlet weak var searchTxt: UITextField!
    
    var arrNewFriends : [UserModel] = [UserModel] ()
    var arrSearchNewFriends : [UserModel] = [UserModel] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(noti:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        tblView.backgroundColor = UIColor.clear
        tblView.separatorStyle = UITableViewCellSeparatorStyle.none
        tblView.tableFooterView = UIView(frame: CGRect.zero)
        tblView.register(UINib.init(nibName: "CustomContactTVC", bundle: nil), forCellReuseIdentifier: "CustomContactTVC")
        
        searchTxt.addCornerRadiusOfView(radius: 20)
        searchTxt.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        searchTxt.addPadding(padding: 10)
        
        for i in 0..<AppModel.shared.USERS.count
        {
            let index = AppModel.shared.currentUser.contact.index(where: { (contact) -> Bool in
                contact.id == AppModel.shared.USERS[i].uID
            })
            if index == nil
            {
                arrNewFriends.append(AppModel.shared.USERS[i])
            }
        }
        arrNewFriends = sortUsers(arrNewFriends)
        
        if arrNewFriends.count == 0
        {
            noDatafound.isHidden = false
        }
        else
        {
            noDatafound.isHidden = true
        }
    }

    @IBAction func clickToBack(_ sender: Any)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToSearch(_ sender: Any)
    {
        self.view.endEditing(true)
        
//        for i in 0..<AppModel.shared.USERS.count
//        {
//            let index = AppModel.shared.currentUser.contact.index(where: { (contact) -> Bool in
//                contact.id == AppModel.shared.USERS[i].uID
//            })
//            if index == nil
//            {
//                if AppModel.shared.USERS[i].username.lowercased().contains((searchTxt.text?.lowercased())!)
//                {
//                    arrSearchNewFriends.append(AppModel.shared.USERS[i])
//                }
//            }
//        }
//
//        tblView.reloadData()
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ((searchTxt.text?.count)! > 0) ? arrSearchNewFriends.count : arrNewFriends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : CustomContactTVC = tblView.dequeueReusableCell(withIdentifier: "CustomContactTVC", for: indexPath) as! CustomContactTVC
        
        let user : UserModel = ((searchTxt.text?.count)! > 0) ? arrSearchNewFriends[indexPath.row] : arrNewFriends[indexPath.row]
        cell.titleLbl.text = user.username
        cell.subTitleLbl.text = user.name
        
        AppDelegate().sharedDelegate().setUserProfileImage(user.uID, button: cell.userProfilePicBtn)
        
        cell.userProfilePicBtn.isUserInteractionEnabled = true
        cell.userProfilePicBtn.tag = indexPath.row
        cell.userProfilePicBtn.addTarget(self, action: #selector(clickToFriendUser(_:)), for: UIControlEvents.touchUpInside)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.view.endEditing(true)
        let selectedUser : UserModel = ((searchTxt.text?.count)! > 0) ? arrSearchNewFriends[indexPath.row] : arrNewFriends[indexPath.row]
        //remove user from list
        let index = arrNewFriends.index(where: { (user) -> Bool in
            user.uID == selectedUser.uID
        })
        if index != nil {
            arrNewFriends.remove(at: index!)
        }
        //add to friend
        AppDelegate().sharedDelegate().sendFriendRequest(selectedUser)
        if arrNewFriends.count == 0
        {
            clickToBack(self)
        }
        tblView.reloadData()
        displayToast("Friend request sent successfully")
    }
    
    @IBAction func clickToFriendUser(_ sender: UIButton)
    {
        AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: ((searchTxt.text?.count)! > 0) ? arrSearchNewFriends[sender.tag] : arrNewFriends[sender.tag])
    }
    
    func textFieldDidChange(noti : Notification)
    {
        let textField : UITextField = noti.object as! UITextField
        if textField == searchTxt
        {
            arrSearchNewFriends = [UserModel]()
            for user : UserModel in arrNewFriends
            {
                if user.name.lowercased().contains((searchTxt.text?.lowercased())!) || user.username.lowercased().contains((searchTxt.text?.lowercased())!)
                {
                    arrSearchNewFriends.append(user)
                }
            }
            tblView.reloadData()
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
