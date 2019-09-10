//
//  CourtDetailVC.swift
//  Check-Up
//
//  Created by Apple on 28/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import MobileCoreServices

class CourtDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var courtProfilePicBtn: UIButton!
    @IBOutlet weak var courtTitleLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var directionBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var deleteCourtBtn: UIButton!
    
    @IBOutlet weak var checkInLbl: UILabel!
    @IBOutlet weak var checkedInCollectionView: UICollectionView!
    
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityLbl: UILabel!
    @IBOutlet weak var activityCollectionView: UICollectionView!
    @IBOutlet weak var noActivityLbl: UILabel!
    
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsLbl: UILabel!
    @IBOutlet weak var commentTblView: UITableView!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var constraintHeightCommentTblView: NSLayoutConstraint!
    @IBOutlet weak var noCommentLbl: UILabel!
    
    @IBOutlet weak var constraintHeightCheckedInView: NSLayoutConstraint!
    @IBOutlet weak var constrainHeightActivityView: NSLayoutConstraint!
    
    var currCourtModel:CourtModel!
    var arrCheckInData:[UserModel] = [UserModel] ()
    var arrActivityData:[EventModel] = [EventModel] ()
    var offscreenCommentCell : [String : Any] = [String : Any] ()
    var isAppear:Bool = false
    var _uID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(setCourtDetail), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_EVENTS), object: nil)
  
        NotificationCenter.default.addObserver(self, selector: #selector(setCourtDetail), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_COURTS), object: nil)
        
        isAppear = true
        setUIDesigning()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isAppear = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAppear = true
        setCourtDetail()
    }
    
    func setUIDesigning()
    {
        _uID = currCourtModel.uID
        
        deleteCourtBtn.isHidden = true
        courtProfilePicBtn.addCornerRadius(radius: courtProfilePicBtn.frame.size.height/2)
        directionBtn.addCornerRadius(radius: 5)
        directionBtn.applyBorder(width: 2, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        shareBtn.addCornerRadius(radius: 5)
        shareBtn.applyBorder(width: 2, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        commentBtn.addCornerRadius(radius: 15.0)
        
        activityLbl.text = "Activity"
        commentsLbl.text = "Comments"
        
        checkedInCollectionView.delegate = self
        checkedInCollectionView.dataSource = self
        checkedInCollectionView.register(UINib.init(nibName: "CustomUserStoryCVC", bundle: nil), forCellWithReuseIdentifier: "CustomUserStoryCVC")
        
        activityCollectionView.delegate = self
        activityCollectionView.dataSource = self
        activityCollectionView.register(UINib.init(nibName: "CustomUserStoryCVC", bundle: nil), forCellWithReuseIdentifier: "CustomUserStoryCVC")
        
        commentTblView.delegate = self
        commentTblView.dataSource = self
        commentTblView.backgroundColor = UIColor.clear
        commentTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        commentTblView.tableFooterView = UIView(frame: CGRect.zero)
        commentTblView.register(UINib.init(nibName: "CustomCommentTVC", bundle: nil), forCellReuseIdentifier: "CustomCommentTVC")
        
    }

    
    func setCourtDetail()
    {
        if courtProfilePicBtn == nil || isAppear == false{
            return
        }
        
        let index = AppModel.shared.COURTS.index { (court) -> Bool in
            currCourtModel.location.id == court.location.id
        }
        
        if index != nil {
            currCourtModel = AppModel.shared.COURTS[index!]
        }
        else{
            if(_uID != AppDelegate().sharedDelegate().currentUserId()){
                displayToast( "Sorry,that court just expired.")
            }
            
            self.clickToBack(self)
            return
        }
        AppDelegate().sharedDelegate().setCourtImage(currCourtModel.location.image, button: courtProfilePicBtn)
        courtTitleLbl.text = currCourtModel.location.name
        locationLbl.text = currCourtModel.location.address
        if currCourtModel.location.isOpen == true
        {
            dateTimeLbl.text = "NOW"
        }
        else
        {
            dateTimeLbl.text = "CLOSE"
        }
        
        arrCheckInData = [UserModel]()
        for i in 0..<currCourtModel.players.count
        {
            let index = AppModel.shared.USERS.index(where: { (userModel) -> Bool in
                currCourtModel.players[i] == userModel.uID
            })
            if(index != nil){
                arrCheckInData.append(AppModel.shared.USERS[index!])
            }
            else if (currCourtModel.players[i] == AppModel.shared.currentUser.uID)
            {
                arrCheckInData.append(AppModel.shared.currentUser)
            }
        }
        checkedInCollectionView.reloadData()
        
        arrActivityData = [EventModel] ()
        
        for i in 0..<currCourtModel.activity.count
        {
            let index = AppModel.shared.EVENTS.index(where: { (eventModel) -> Bool in
                currCourtModel.activity[i] == eventModel.id
            })
            if(index != nil){
                let eventTemp : EventModel = AppModel.shared.EVENTS[index!]
                
                if getDifferenceToCurrentTime(date: eventTemp.maxDate) < 0
                {
                    continue
                }
                arrActivityData.append(eventTemp)
            }
        }
        activityCollectionView.reloadData()
        
        
        if currCourtModel.players.count > 0
        {
            checkInLbl.text = "Checked-in (" + String(currCourtModel.players.count) + ")"
        }
        else
        {
            checkInLbl.text = "No user checked-in"
        }
        
        if arrActivityData.count > 0
        {
            activityLbl.text = "Activity (" + String(arrActivityData.count) + ")"
        }
        else
        {
            activityLbl.text = "No Activity"
        }
        
        if currCourtModel.comment.count > 0
        {
            commentsLbl.text = "Comment (" + String(currCourtModel.comment.count) + ")"
        }
        else
        {
            commentsLbl.text = "No Comments"
        }
        
        setCommentTblViewHeight()

        if currCourtModel.uID == AppModel.shared.currentUser.uID && currCourtModel.type == 2// && currCourtModel.activity.count == 0
        {
            deleteCourtBtn.isHidden = false
        }
        
    }
    
    // MARK: - Button click event
    
    @IBAction func clickToBack(_ sender: Any)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToCreateNewGameEventTraining(_ sender: Any)
    {
        let vc : CreateNewGameEventTrainingVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateNewGameEventTrainingVC") as! CreateNewGameEventTrainingVC
        vc.selectedLocation = currCourtModel.location
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToComment(_ sender: Any)
    {
        let vc : CommentVC = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        vc.court = currCourtModel
        vc.event = nil
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func clickToDirection(_ sender: Any)
    {
        let current_latitude : Float = Preference.sharedInstance.getUserLatitude()
        let current_longitude : Float = Preference.sharedInstance.getUserLongitude()
        
        let court_latitude : Float = currCourtModel.location.latitude
        let court_longitude : Float = currCourtModel.location.longitude
        
        let url : String = String(format: "http://www.google.com/maps?saddr=%f,%f&daddr=%f,%f", current_latitude, current_longitude, court_latitude, court_longitude)
        UIApplication.shared.openURL(URL(string: url)!)
    }
    
    @IBAction func clickToShare(_ sender: Any)
    {
        shareEvent(shareImage: courtProfilePicBtn.backgroundImage(for: UIControlState.normal))
    }
 
    @IBAction func clickkToDisplayStory(_ sender: Any)
    {
        if currCourtModel.story.count > 0
        {
            if AppModel.shared.STORY[currCourtModel.story.last!] != nil{
                let vc : DisplayStoryVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayStoryVC") as! DisplayStoryVC
                vc.arrCourt = [currCourtModel]
                vc.mainIndex = 0
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
        }
        displayToast("Story not found.")
    }
 
    @IBAction func clickkToDeleteCourt(_ sender: Any)
    {
        let alertConfirmation = UIAlertController(title: "Check-Up", message: "Are you sure you want to delete court?\nYou will also loss all events if added in this court.", preferredStyle: UIAlertControllerStyle.alert)
        let noAction = UIAlertAction (title: "NO", style: UIAlertActionStyle.cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "YES", style: .default) { (action) in
            
            AppDelegate().sharedDelegate().removeCreatedCourt(self.currCourtModel)
            self.clickToBack(self)
        }
        alertConfirmation.addAction(noAction)
        alertConfirmation.addAction(yesAction)
        
        self.present(alertConfirmation, animated: true, completion: nil)
    }
    // MARK: - Collectionview Delaget methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == checkedInCollectionView {
            return arrCheckInData.count
        }
        return arrActivityData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == checkedInCollectionView
        {
            let cell : CustomUserStoryCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomUserStoryCVC", for: indexPath) as! CustomUserStoryCVC
            
            let dict : UserModel = arrCheckInData[indexPath.row] 
            cell.userNameLbl.text = dict.name
            
            AppDelegate().sharedDelegate().setUserProfileImage(dict.uID, button: cell.profilePicBtn)
            
            cell.profilePicBtn.addCornerRadius(radius: cell.profilePicBtn.frame.size.width/2)
            cell.userNameLbl.isHidden = false
            cell.userNameDarkLbl.isHidden = true
            return cell
        }
        else
        {
            let cell : CustomUserStoryCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomUserStoryCVC", for: indexPath) as! CustomUserStoryCVC
            
            let event : EventModel = arrActivityData[indexPath.row]
            cell.userNameLbl.text = event.title
            cell.profilePicBtn.setImage(nil, for: UIControlState.normal)
            cell.profilePicBtn.setBackgroundImage(nil, for: UIControlState.normal)
            
            switch event.type {
            case 1:
                cell.profilePicBtn.setImage(UIImage(named: IMAGE.GAMES_ORANGE_SMALL), for: UIControlState.normal)
                break
            case 2:
                cell.profilePicBtn.setImage(UIImage(named: IMAGE.WORLDCUP_ORANGE_SMALL), for: UIControlState.normal)
                break
            case 3:
                cell.profilePicBtn.setImage(UIImage(named: IMAGE.TRAINER_ORANGE_SMALL), for: UIControlState.normal)
                break
            default:
                break
            }
            
            cell.userNameLbl.isHidden = false
            cell.userNameDarkLbl.isHidden = true
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == checkedInCollectionView
        {
            AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: arrCheckInData[indexPath.row])
        }
        else
        {
            let vc : GameDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "GameDetailVC") as! GameDetailVC
            vc.eventModel = arrActivityData[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if currCourtModel.comment.count > 3
        {
            return 3
        }
        return currCourtModel.comment.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var cell = offscreenCommentCell["CustomCommentTVC"] as? CustomCommentTVC
        if cell == nil {
            cell = commentTblView.dequeueReusableCell(withIdentifier: "CustomCommentTVC") as? CustomCommentTVC
            offscreenCommentCell["CustomCommentTVC"] = cell
        }
        
        if cell == nil
        {
            return 75.0
        }
        let comment : CommentModel = currCourtModel.comment[(currCourtModel.comment.count-1) - indexPath.row]
        
        cell?.messageTxtView.text = comment.text.decodeString
        
        let sizeThatFitsTextView:CGSize = cell!.messageTxtView.sizeThatFits(CGSize(width: commentTblView.frame.size.width-85, height: CGFloat(MAXFLOAT)))
        
        let height : Float = Float(75 - 37 + sizeThatFitsTextView.height)
        
        if height > 75
        {
            return CGFloat(height)
        }

        return 75.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : CustomCommentTVC = commentTblView.dequeueReusableCell(withIdentifier: "CustomCommentTVC", for: indexPath) as! CustomCommentTVC
        
        let comment : CommentModel = currCourtModel.comment[(currCourtModel.comment.count-1) - indexPath.row]
        
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
    
    func setCommentTblViewHeight()
    {
        commentTblView.reloadData()
        
        if commentTblView.contentSize.height > 0
        {
            constraintHeightCommentTblView.constant = commentTblView.contentSize.height + 88
        }
        else
        {
            constraintHeightCommentTblView.constant = 30 + 88
        }
        
    }
    
    func shareEvent(shareImage:UIImage?){
        
        var objectsToShare = [AnyObject]()
        
        
        let shareText : String = "Check-Up at " + currCourtModel.location.name + "\nTo use this app, install it from : " + APP.SHARE_URL + "\""
        objectsToShare.append(shareText as AnyObject)
        
        if let shareImageObj = shareImage{
            objectsToShare.append(shareImageObj)
        }
        
        if shareText != nil || shareImage != nil{
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            present(activityViewController, animated: true, completion: nil)
        }else{
            //print("There is nothing to share")
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
