//
//  UserProfileDialogView.swift
//  Check-Up
//
//  Created by Amisha on 08/10/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class UserProfileDialogView: UIView {

    @IBOutlet weak var userMessageBtnView: UIView!
    @IBOutlet weak var userPopupView: UIView!
    @IBOutlet weak var userAddFriendBtn: UIButton!
    @IBOutlet weak var userFullNameLbl: UILabel!
    @IBOutlet weak var userUserNameLbl: UILabel!
    @IBOutlet weak var userAgeLbl: UILabel!
    @IBOutlet weak var userHeightLbl: UILabel!
    @IBOutlet weak var userPositionLbl: UILabel!
    @IBOutlet weak var userLocationLbl: UILabel!
    @IBOutlet weak var userCheckInLbl: UILabel!
    @IBOutlet weak var userProfilePicBtn: UIButton!
    @IBOutlet weak var userSettingBtn: UIButton!
    @IBOutlet weak var addRemoveBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    
    var selectedUser : UserModel!
    var isStoryDisplay : Bool = false
    var selectedEvent : EventModel?
    var VC : UIViewController!
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateAllUser), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
        setUIDesigning()
    }
    
    func onUpdateAllUser(){
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        userMessageBtnView.addCornerRadiusOfView(radius: 30)
        userPopupView.addCornerRadiusOfView(radius: 30)
        userProfilePicBtn.addCornerRadiusOfView(radius: userProfilePicBtn.frame.size.width/2)
        
        AppDelegate().sharedDelegate().setUserProfileImage(selectedUser.uID, button: userProfilePicBtn)
        
        userFullNameLbl.text = selectedUser.name
        userUserNameLbl.text = selectedUser.username
        if(AppModel.shared.currentUser.age == 0){
            userAgeLbl.text = "AGE: "
        }
        else{
            userAgeLbl.text = "AGE: " + String(selectedUser.age)
        }
        
        
        userHeightLbl.text = "HEIGHT: " + selectedUser.height
        userPositionLbl.text = "POSITION: " + AppDelegate().sharedDelegate().getUserPosition(position: selectedUser.position)
        userLocationLbl.text = "LOCATION: " + selectedUser.location.address
        userCheckInLbl.text = "CHECK-INS: " + String(selectedUser.total_checkIn)
        
        
        
        addRemoveBtn.setTitle("ADD", for: .normal)
        addRemoveBtn.setTitle("REMOVE", for: .selected)
        
        if selectedUser.uID == AppModel.shared.currentUser.uID
        {
            userMessageBtnView.isHidden = true
            userSettingBtn.isHidden = false
            reportBtn.isHidden = true
            userAddFriendBtn.isSelected = true
            addRemoveBtn.isSelected = false
            
            if(selectedEvent != nil){
                userAddFriendBtn.isSelected = true
                addRemoveBtn.isSelected = true
            }
        }
        else
        {
            setFriendMessageView()
        }
    }
    
    func setFriendMessageView()
    {
        reportBtn.isHidden = false
        userSettingBtn.isHidden = true
        userMessageBtnView.isHidden = true
        if(selectedEvent == nil)
        {
            let index = AppModel.shared.currentUser.contact.index(where: { (tempContact) -> Bool in
                tempContact.id == selectedUser.uID
            })
            
            if index != nil
            {
                if(AppModel.shared.currentUser.contact[index!].requestAction == 3)
                {
                    userAddFriendBtn.isSelected = true
                    addRemoveBtn.isSelected = true
                    userMessageBtnView.isHidden = false
                }
                else{
                    userAddFriendBtn.isSelected = false
                    addRemoveBtn.isSelected = true
                }
            }
            else
            {
                userAddFriendBtn.isSelected = false
                addRemoveBtn.isSelected = false
            }
        }
        else{
            userAddFriendBtn.isSelected = true
            addRemoveBtn.isSelected = true
            let index = AppModel.shared.currentUser.contact.index(where: { (tempContact) -> Bool in
                tempContact.id == selectedUser.uID &&  tempContact.requestAction == 3
            })
            if index != nil
            {
                userMessageBtnView.isHidden = false
            }
        }
    }
    
    @IBAction func clickToSendMessage(_ sender: Any)
    {
        if selectedUser.uID != nil && selectedUser.uID != ""
        {
            if(AppDelegate().sharedDelegate().isBlockUser(selectedUser.uID)){
                displayToast( "Unblock for further proceed.")
            }
            else if(AppDelegate().sharedDelegate().isBlockMe(selectedUser)){
                displayToast("Opps, " + selectedUser.name + " has blocked you.")
            }
            else{
                AppDelegate().sharedDelegate().onChannelTap(connectUserId: selectedUser.uID)
                clickToClose(self)
            }

        }
        else
        {
            displayToast( "Something wrong.")
            clickToClose(self)
        }
        
    }
    
    @IBAction func clickToAddFriend(_ sender: Any)
    {
        if(selectedEvent == nil){
            if selectedUser.uID == AppModel.shared.currentUser.uID
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_REDIRECT_NEW_FRIEND_LIST), object: nil)
            }
            else
            {
                if AppDelegate().sharedDelegate().isBlockUser(selectedUser.uID) && userAddFriendBtn.isSelected == false{
                    displayToast("Unblock for further proceed.")
                }
                else if userAddFriendBtn.isSelected
                {
                    AppDelegate().sharedDelegate().removeFriendFromUser(selectedUser)
                }
                else
                {
                    AppDelegate().sharedDelegate().sendFriendRequest(selectedUser)
                }
                setFriendMessageView()
            }
        }
        else if(selectedEvent != nil){
            let index = selectedEvent?.players.index(where: { (tempContact) -> Bool in
                tempContact.id == selectedUser.uID
            })
            if(index != nil){
                let oldEvent:EventModel = EventModel.init(dict: selectedEvent!.dictionary())
                selectedEvent?.players.remove(at: index!)
                AppDelegate().sharedDelegate().updateEvent(oldEvent, updatedEvent: selectedEvent!)
            }
        }
        
        clickToClose(self)
    }
    
    @IBAction func clickToSetting(_ sender: Any)
    {
        AppDelegate().sharedDelegate().navigateToEditProfile()
        clickToClose(self)
    }
    
    @IBAction func clickToUserProfilePic(_ sender: Any)
    {
        if isStoryDisplay
        {
            if selectedUser.story.count > 0 && AppModel.shared.STORY[selectedUser.story.last!] != nil
            {
                clickToClose(self)
                AppDelegate().sharedDelegate().navigateToDisplayStory(selectedUser)
            }
            else
            {
                displayToast("Story not found.")
            }
        }
    }
    
    @IBAction func clickToClose(_ sender: Any)
    {
        self.removeFromSuperview()
    }
    
    @IBAction func clickToReport(_ sender: Any)
    {
        self.removeFromSuperview()
        AppDelegate().sharedDelegate().reportUser(selectedUser, subject:"Flag User Profile", vc: VC)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
