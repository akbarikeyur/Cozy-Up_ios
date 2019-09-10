//
//  SendMessageToVC.swift
//  Check-Up
//
//  Created by Amisha on 13/09/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import FBSDKShareKit
import AssetsLibrary
import AVFoundation

class SendMessageToVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var storyTblView: UITableView!
    @IBOutlet weak var friendsTblView: UITableView!
    @IBOutlet weak var constraintHeightStoryTbl : NSLayoutConstraint!
    @IBOutlet weak var constraintHeightFriendsTbl : NSLayoutConstraint!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet var shareContainerView: UIView!
    @IBOutlet weak var sharePopupView: UIView!
    @IBOutlet weak var sharePopupImgView: UIImageView!
    @IBOutlet weak var shareContactsBtn: UIButton!
    @IBOutlet weak var totalStoryLbl: UILabel!
    @IBOutlet weak var totalFriendLbl: UILabel!
    
    @IBOutlet weak var userProfilePicBtn: UIButton!
    @IBOutlet weak var myStorySelectionBtn: UIButton!
    
    var screenFrom : String!
    
    var selectedStory : StoryModel!
    var url : URL?
    var thumbImage : UIImage!
    var videoName : String?
    var arrCheckInCourts : [CourtModel] = [CourtModel] ()
    var arrFriend : [UserModel] = [UserModel] ()
    var arrSearchFriendData : [UserModel] = [UserModel] ()
    var arrCourtSelected : [String:Bool] = [String:Bool] ()
    var arrFriendSelected : [String:Bool] = [String:Bool] ()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(noti:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateFriendList), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateCourtList), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_COURTS), object: nil)

        setUIDesigning()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            removeLoader()
        }
    }
    func setUIDesigning()
    {
        
        shareBtn.addCornerRadius(radius: 2.0)
        shareBtn.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        
        storyTblView.backgroundColor = UIColor.clear
        storyTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        storyTblView.tableFooterView = UIView(frame: CGRect.zero)
        
        friendsTblView.backgroundColor = UIColor.clear
        friendsTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        friendsTblView.tableFooterView = UIView(frame: CGRect.zero)
        
        searchTxt.addCornerRadiusOfView(radius: 20)
        searchTxt.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        searchTxt.addPadding(padding: 10)
        
        storyTblView.register(UINib.init(nibName: "CustomCourtStoryCell", bundle: nil), forCellReuseIdentifier: "CustomCourtStoryCell")
        friendsTblView.register(UINib.init(nibName: "CustomMessgaeTVC", bundle: nil), forCellReuseIdentifier: "CustomMessgaeTVC")
        
        userProfilePicBtn.addCornerRadius(radius: userProfilePicBtn.frame.size.width/2)
        
        AppDelegate().sharedDelegate().setUserProfileImage(AppModel.shared.currentUser.uID, button: userProfilePicBtn)
        
        myStorySelectionBtn.isUserInteractionEnabled = false
        clickToSelectMyStory(self)
        
        onUpdateCourtList()
        onUpdateFriendList()
    }
    
    func onUpdateCourtList()
    {
        arrCheckInCourts = [CourtModel] ()
        
        for i in 0..<AppModel.shared.currentUser.courts.count
        {
            let index = AppModel.shared.COURTS.index(where: { (tempCourt) -> Bool in
                tempCourt.location.id == AppModel.shared.currentUser.courts[i]
            })
            
            if index != nil
            {
                arrCheckInCourts.append(AppModel.shared.COURTS[index!])
            }
        }
        for court in arrCourtSelected{
            let index = arrCheckInCourts.index(where: { (tempCourt) -> Bool in
                tempCourt.location.id == court.key
            })
            
            if index == nil
            {
                arrCourtSelected[court.key] = nil
            }
        }
        storyTblView.reloadData()
        constraintHeightStoryTbl.constant = storyTblView.contentSize.height
    }
    
    func onUpdateFriendList()
    {
        arrFriend = [UserModel] ()
        for i in 0..<AppModel.shared.currentUser.contact.count
        {
            let index = AppModel.shared.USERS.index(where: { (tempUser) -> Bool in
                tempUser.uID == AppModel.shared.currentUser.contact[i].id
            })
            
            if index != nil {
                if(AppDelegate().sharedDelegate().isBlockUser(AppModel.shared.USERS[index!].uID)){
                    
                }
                else{
                    arrFriend.append(AppModel.shared.USERS[index!])
                }
                
            }
        }
        if arrFriend.count > 0
        {
            totalFriendLbl.text = "Friends (" + String(arrFriend.count) + ")"
        }
        else
        {
            totalFriendLbl.text = "No Friends"
        }
        
        arrSearchFriendData = [UserModel]()
        for user : UserModel in arrFriend
        {
            if user.name.lowercased().contains((searchTxt.text?.lowercased())!) || user.username.lowercased().contains((searchTxt.text?.lowercased())!)
            {
                arrSearchFriendData.append(user)
            }
        }
        
        for user in arrFriendSelected{
            let index = arrFriend.index(where: { (tempUser) -> Bool in
                tempUser.uID == user.key
            })
            
            if index == nil
            {
                arrFriendSelected[user.key] = nil
            }
        }
        arrFriend = sortUsers(arrFriend)
        arrSearchFriendData = sortUsers(arrSearchFriendData)
        
        friendsTblView.reloadData()
        constraintHeightFriendsTbl.constant = friendsTblView.contentSize.height
    }
    
    @IBAction func clickToSelectMyStory(_ sender: Any)
    {
        myStorySelectionBtn.isSelected = !myStorySelectionBtn.isSelected
    }
    
    @available(iOS 9.0, *)
    @IBAction func clickToShare(_ sender: Any)
    {
        self.view.endEditing(true)
        shareStory()
    }
    
    @IBAction func clickToSend(_ sender: Any)
    {
        self.view.endEditing(true)
        var isAnySelected : Bool = false
        
        var uploadArray : [CourtModel] = [CourtModel] ()
        var sendArray : [UserModel] = [UserModel] ()
        
        if myStorySelectionBtn.isSelected
        {
            isAnySelected = true
        }
        
        for dict in arrCourtSelected
        {
            if dict.value == true
            {
                isAnySelected = true
                let index = AppModel.shared.COURTS.index(where: { (tempCourt) -> Bool in
                    tempCourt.location.id == dict.key
                })
            
                if index != nil
                {
                    uploadArray.append(AppModel.shared.COURTS[index!])
                }
            }
        }
    
        var isFriendSelected : Bool = false
        for dict in arrFriendSelected
        {
            if dict.value == true
            {
                isAnySelected = true
                isFriendSelected = true
                let index = AppModel.shared.USERS.index(where: { (tempUser) -> Bool in
                    tempUser.uID == dict.key
                })
                
                if index != nil
                {
                    sendArray.append(AppModel.shared.USERS[index!])
                }
            }
        }
        if isAnySelected == false
        {
            displayToast("Please select friend to send story or select court to save story.")
        }
        else
        {
            if selectedStory != nil
            {
                continueToSend(uploadArray: uploadArray, sendArray: sendArray, isFriendSelected : isFriendSelected)
            }
            else
            {
                if videoName != nil && videoName != ""
                {
                    if let videoUrl = URL(string : getVideo(videoName: videoName!)!)
                    {
                        displayLoader()
                        Utility_Objective_C.overlayWatermark(thumbImage, video: videoUrl, videoName: getCurrentTimeStampValue(), isWaterMark: false, isStoryFromGallary:AppDelegate().sharedDelegate().isStoryFromGallary, withCompletionHandler: { (newUrl) in
                            DispatchQueue.main.async {
                                removeLoader()
                                let videoName = getCurrentTimeStampValue()
                                storeVideoInDocumentDirectory(videoUrl: URL(string : newUrl!)!, videoName: videoName)
                                self.selectedStory = StoryModel.init(id: getCurrentTimeStampValue(), uID: AppModel.shared.currentUser.uID, local_url: videoName, remote_url: "", thumb_local_url: "", thumb_remote_url: "", date: getCurrentDateInString(), description: "", type: 2, error: "")
                                
                                self.continueToSend(uploadArray: uploadArray, sendArray: sendArray, isFriendSelected : isFriendSelected)
                            }
                        }, errorHandler: { (error) in
                            DispatchQueue.main.async {
                                removeLoader()
                                displayToast(error!)
                            }
                        })
                    }
                }
                else
                {
                    let imgName = getCurrentTimeStampValue()
                    storeImageInDocumentDirectory(image: thumbImage, imageName: imgName)
                    selectedStory = StoryModel.init(id: getCurrentTimeStampValue(), uID: AppModel.shared.currentUser.uID, local_url: imgName, remote_url: "", thumb_local_url: "", thumb_remote_url: "", date: getCurrentDateInString(), description: "", type: 1, error: "")
                    continueToSend(uploadArray: uploadArray, sendArray: sendArray, isFriendSelected : isFriendSelected)
                }
            }
        }
    }
    
    func continueToSend(uploadArray : [CourtModel], sendArray : [UserModel], isFriendSelected:Bool)
    {
        if self.myStorySelectionBtn.isSelected
        {
            let index = AppModel.shared.currentUser.story.index(where: { (tempStory) -> Bool in
                tempStory == self.selectedStory.id
            })
            if index == nil
            {
                AppModel.shared.currentUser.story.append(selectedStory.id)
                AppDelegate().sharedDelegate().updateCurrentUserData()
            }
            else
            {
                if uploadArray.count == 0 && sendArray.count == 0
                {
                    displayToast("This story already added as your story")
                    return
                }
            }
        }
        for tempCourt in uploadArray
        {
            let index = AppModel.shared.COURTS.index(where: { (tempCourt1) -> Bool in
                tempCourt1.location.id == tempCourt.location.id
            })
            
            if index != nil
            {
                tempCourt.story.append(self.selectedStory.id)
                AppDelegate().sharedDelegate().courtRef.child(tempCourt.location.id).child("story").setValue(tempCourt.story)
            }
        }
        
        for tempFriend in sendArray
        {
            AppDelegate().sharedDelegate().sendStoryToFriends(selectedStory, friend: tempFriend)
        }
        
        AppDelegate().sharedDelegate().uploadStory(story: self.selectedStory, msg: nil)
        
        if isFriendSelected == true
        {
            let vc : MessageNotificationVC = self.storyboard!.instantiateViewController(withIdentifier: "MessageNotificationVC") as! MessageNotificationVC
            vc.isMessageDisplay = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func clickToback(_ sender: Any)
    {
        self.view.endEditing(true)
        if screenFrom != nil && screenFrom == "DisplayStoryVC"
        {
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
        else
        {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == storyTblView
        {
            return arrCheckInCourts.count
        }
        else if tableView == friendsTblView
        {
            let countInt : Int = ((searchTxt.text?.count)! > 0) ? arrSearchFriendData.count : arrFriend.count
            return countInt
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == storyTblView
        {
            let cell = storyTblView.dequeueReusableCell(withIdentifier: "CustomCourtStoryCell", for: indexPath) as! CustomCourtStoryCell
            cell.selectionBtn.isSelected = false
            cell.seperatorImg.isHidden = false
            
            let court : CourtModel = arrCheckInCourts[indexPath.row]
            AppDelegate().sharedDelegate().setCourtImage(court.location.image, button: cell.profilePicBtn)
            cell.nameLbl.text = court.location.name
            
            if arrCourtSelected[court.location.id] != nil
            {
                cell.selectionBtn.isSelected = arrCourtSelected[court.location.id]!
            }
            
            if (arrCheckInCourts.count-1) == indexPath.row
            {
                cell.seperatorImg.isHidden = true
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else
        {
            let cell = friendsTblView.dequeueReusableCell(withIdentifier: "CustomMessgaeTVC", for: indexPath) as! CustomMessgaeTVC
            cell.selectionBtn.isSelected = false
            cell.selectionBtn.isHidden = false
            
            let userTemp : UserModel =  ((searchTxt.text?.count)! > 0) ? arrSearchFriendData[indexPath.row] : arrFriend[indexPath.row]

            AppDelegate().sharedDelegate().setUserProfileImage(userTemp.uID, button: cell.profilePicBtn)
            
            cell.nameLbl.text = userTemp.username
            cell.messageLbl.text = userTemp.name
            
            if arrFriendSelected[userTemp.uID] != nil
            {
                cell.selectionBtn.isSelected = arrFriendSelected[userTemp.uID]!
            }
            cell.durationLbl.text = ""
            cell.constraintWidthDurationLbl.constant = 0
            cell.profilePicBtn.isUserInteractionEnabled = true
            cell.profilePicBtn.tag = indexPath.row
            cell.profilePicBtn.addTarget(self, action: #selector(clickToFriendUser(_:)), for: UIControlEvents.touchUpInside)
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        if tableView == storyTblView
        {
            let cell : CustomCourtStoryCell = tableView.cellForRow(at: indexPath) as! CustomCourtStoryCell
            let court : CourtModel = arrCheckInCourts[indexPath.row]
            
            if arrCourtSelected[court.location.id] != nil
            {
                arrCourtSelected[court.location.id] = !arrCourtSelected[court.location.id]!
            }
            else
            {
                arrCourtSelected[court.location.id] = true
            }
            cell.selectionBtn.isSelected = arrCourtSelected[court.location.id]!
        }
        else
        {
            let cell : CustomMessgaeTVC = tableView.cellForRow(at: indexPath) as! CustomMessgaeTVC
            let tempArr : [UserModel] = (((searchTxt.text?.count)! > 0) ? arrSearchFriendData : arrFriend)
            let tempUser : UserModel = tempArr[indexPath.row]
            
            if(AppDelegate().sharedDelegate().isBlockMe(tempUser)){
                arrFriendSelected[tempUser.uID] = false
                displayToast("Opps, " + tempUser.name + " has blocked you.")
            }
            else if arrFriendSelected[tempUser.uID] != nil
            {
                arrFriendSelected[tempUser.uID] = !arrFriendSelected[tempUser.uID]!
            }
            else
            {
                arrFriendSelected[tempUser.uID] = true
            }
            cell.selectionBtn.isSelected = arrFriendSelected[tempUser.uID]!
        }
        
    }
    
    
    @IBAction func clickToFriendUser(_ sender: UIButton)
    {
        AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: ((searchTxt.text?.count)! > 0) ? arrSearchFriendData[sender.tag] : arrFriend[sender.tag])
    }
    
    @IBAction func clickToSelectStory(_ sender: UIButton)
    {
        
    }
    
    @IBAction func clickToSelectFriend(_ sender: UIButton)
    {
        
    }
    
    func openShareView()
    {
        sharePopupView.addCornerRadiusOfView(radius: 30.0)
        sharePopupImgView.addCornerRadiusOfView(radius: 30.0)
        
        displaySubViewtoParentView(self.view, subview: shareContainerView)
    }
    
    @IBAction func clickToShareFacebook(_ sender: Any)
    {
        self.view.endEditing(true)
    }
    
    @IBAction func clickToShareTwitter(_ sender: Any)
    {
        self.view.endEditing(true)
    }
    
    @IBAction func clickToShareInstagram(_ sender: Any)
    {
        self.view.endEditing(true)
        
    }
    
    @available(iOS 9.0, *)
    func shareStory()
    {
        var objectsToShare = [AnyObject]()
        
        if selectedStory != nil
        {
            if selectedStory.type == 1
            {
                if let shareImageObj = getImage(imageName: selectedStory.local_url) {
                    objectsToShare.append(shareImageObj as AnyObject)
                }
                else
                {
                    if selectedStory.remote_url != ""
                    {
                        objectsToShare.append(selectedStory.remote_url as AnyObject)
                    }
                    else
                    {
                        return
                    }
                }
                continueSharing(objectsToShare)
            }
            else
            {
                if let shareVideoObj = getVideo(videoName: selectedStory.local_url)
                {
                    let videoUrlObj = URL(fileURLWithPath : shareVideoObj)
                    objectsToShare.append(videoUrlObj as AnyObject)
                    continueSharing(objectsToShare)
                }
                else
                {
                    if selectedStory.remote_url != ""
                    {
                        do {
                            let videoData = try Data(contentsOf: URL(string : self.selectedStory.remote_url)!)
                            objectsToShare.append(videoData as AnyObject)
                            continueSharing(objectsToShare)
                        } catch {
                            print("Unable to load data: \(error)")
                        }
                    }
                    else
                    {
                        return
                    }
                }
            }
            
        }
        else
        {
            if videoName != nil && videoName != ""
            {
                let shareUrlObj = URL(fileURLWithPath : getVideo(videoName: videoName!)!)
                objectsToShare.append(shareUrlObj as AnyObject)
                continueSharing(objectsToShare)
                
            }
            else
            {
                if let shareImgObj = thumbImage {
                    objectsToShare.append(shareImgObj as AnyObject)
                    continueSharing(objectsToShare)
                }
                else
                {
                    return
                }
            }
        }
    }
    
    func continueSharing(_ objectsToShare : [AnyObject])
    {
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func clickToCloseShareView(_ sender: Any)
    {
        shareContainerView.removeFromSuperview()
    }
    
    func textFieldDidChange(noti : Notification)
    {
        let textField : UITextField = noti.object as! UITextField
        if textField == searchTxt
        {
           onUpdateFriendList()
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

extension UIActivityType {
    @available(iOS 7.0, *)
    public static let postToInstagram: UIActivityType = {
        return UIActivityType.init(rawValue: "com.instagram.exclusivegram")
    }()
}
