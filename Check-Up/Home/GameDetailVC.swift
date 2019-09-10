//
//  GameDetailVC.swift
//  Check-Up
//
//  Created by Amisha on 20/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class GameDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleScreenLbl: UILabel!
    
    @IBOutlet weak var editEventBtn: UIButton!
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var nameTitleLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var admissionTypeBtn: UILabel!
    @IBOutlet weak var privacyBtn: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var playerLbl: UILabel!
    @IBOutlet weak var playerCollectionView: UICollectionView!
    @IBOutlet weak var commentTblView: UITableView!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var noCommentFound: UILabel!
    @IBOutlet weak var pinImgView: UIImageView!
    
    @IBOutlet weak var inviteUserBtn: UIButton!
    @IBOutlet weak var constraintWidthInviteUser: NSLayoutConstraint!
    
    
    @IBOutlet weak var constraintHeightDetailView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightCommentTblView: NSLayoutConstraint!
    @IBOutlet weak var hostLbl: UILabel!
    
    @IBOutlet var addPlayerContainerView: UIView!
    @IBOutlet var addPlayerPopupView: UIView!
    @IBOutlet var addPlayerPopupTitleLbl: UILabel!
    @IBOutlet var addPlayerTblView: UITableView!
    @IBOutlet var constraintHeightAddPlayerPopupView: NSLayoutConstraint!
    @IBOutlet var addPlayerCancelBtn: UIButton!
    @IBOutlet var addPlayerOkBtn: UIButton!
    @IBOutlet weak var constraintHeightSearchPlayerView: NSLayoutConstraint!
    @IBOutlet weak var searchPlayerTxt: UITextField!
    
    var eventModel:EventModel!
    var arrPlayerData:[UserModel] = [UserModel] ()
    var arrCommentData:[String] = [String] ()
    
    var arrMemberData = [UserModel]()
    var arrSearchMemberData = [UserModel]()
    var arrSelectedMemberData = [UserModel]()
    var offscreenCommentCell : [String : Any] = [String : Any] ()
    var isAppear:Bool = false
    var _uID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(noti:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setGameDetail), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_EVENTS), object: nil)
        
         isAppear = true
        setUIDesigning()
        //print(eventModel.dictionary())
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isAppear = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAppear = true
        
    }
    func setUIDesigning()
    {
        _uID = eventModel.uID
        
        joinBtn.addCornerRadius(radius: 5.0)
        joinBtn.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        shareBtn.addCornerRadius(radius: 5.0)
        shareBtn.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        
        profilePicBtn.addCornerRadius(radius: profilePicBtn.frame.size.height/2)
        commentBtn.addCornerRadius(radius: 15.0)
        
        playerCollectionView.delegate = self
        playerCollectionView.dataSource = self
        playerCollectionView.register(UINib.init(nibName: "CustomUserStoryCVC", bundle: nil), forCellWithReuseIdentifier: "CustomUserStoryCVC")
        
        addPlayerTblView.backgroundColor = UIColor.clear
        addPlayerTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        addPlayerTblView.tableFooterView = UIView(frame: CGRect.zero)
        addPlayerTblView.register(UINib.init(nibName: "CustomAddFriendTVC", bundle: nil), forCellReuseIdentifier: "CustomAddFriendTVC")
        
        commentTblView.delegate = self
        commentTblView.dataSource = self
        commentTblView.backgroundColor = UIColor.clear
        commentTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        commentTblView.tableFooterView = UIView(frame: CGRect.zero)
        commentTblView.register(UINib.init(nibName: "CustomCommentTVC", bundle: nil), forCellReuseIdentifier: "CustomCommentTVC")
        
        hostLbl.isHidden = true
        editEventBtn.isHidden = true
        inviteUserBtn.isHidden = true
        constraintWidthInviteUser.constant = 0
        
        setGameDetail()
    }
    
    func setGameDetail()
    {
        if commentTblView == nil || isAppear == false
        {
            return
        }
        
        let index = AppModel.shared.EVENTS.index { (event) -> Bool in
            event.id == eventModel.id
        }
        
        if index != nil {
            eventModel = AppModel.shared.EVENTS[index!]
        }
        else{
            if(_uID != AppDelegate().sharedDelegate().currentUserId()){
                displayToast("Sorry,that event just expired.")
            }
            self.clickToBack(self)
            return;
        }
        titleScreenLbl.text = getEventTypeName().uppercased()
        
        
        if eventModel.uID == AppModel.shared.currentUser.uID
        {
            hostLbl.isHidden = false
            editEventBtn.isHidden = false
        }
        
        
        if(eventModel.uID == AppModel.shared.currentUser.uID){
            inviteUserBtn.isHidden = false
            constraintWidthInviteUser.constant = 45
        }
        else if(eventModel.privacyType == 1){
            let index1 = eventModel.players.index { (tempContact) -> Bool in
                tempContact.id == AppModel.shared.currentUser.uID
            }
            if index1 != nil
            {
                inviteUserBtn.isHidden = false
                constraintWidthInviteUser.constant = 45
            }
        }
        
        
        AppDelegate().sharedDelegate().setUserProfileImage(eventModel.uID, button: profilePicBtn)
        
        
        nameTitleLbl.text = eventModel.title
        locationLbl.text = eventModel.location.address
        dateTimeLbl.text = getFormatedDateStringFromFCM(FORMAT.FCM_DATETIME, newFormat: FORMAT.DISPLAY_DATE, date: eventModel.minDate) + " (" + getTimeStringFromFCM(eventModel.minDate) + " - " + getTimeStringFromFCM(eventModel.maxDate) + ")"
        
        
        descriptionLbl.numberOfLines = 0
        descriptionLbl.text = "\"" + eventModel.description + "\""
        
        constraintHeightDetailView.constant = 170 - 25 + descriptionLbl.getLableHeight()
        switch eventModel.admissionType
        {
            case 1:
                admissionTypeBtn.text = "FREE"
                break
            case 2:
                admissionTypeBtn.text = "FEE"
                break
            default:
                break
        }
        
        switch eventModel.privacyType
        {
            case 1:
                privacyBtn.text = "PUBLIC"
                break
            case 2:
                privacyBtn.text = "PRIVACY"
                break
            default:
                break
        }
        
        arrPlayerData = [UserModel] ()
        for i in 0..<eventModel.players.count
        {
            let index = AppModel.shared.USERS.index(where: { (userModel) -> Bool in
                eventModel.players[i].id == userModel.uID
            })
            if(index != nil){
                arrPlayerData.append(AppModel.shared.USERS[index!])
            }
            else if eventModel.players[i].id == AppModel.shared.currentUser.uID
            {
                arrPlayerData.append(AppModel.shared.currentUser)
            }
        }
        
        playerLbl.text = String(format: "Players (%d)", eventModel.players.count)
        playerCollectionView.reloadData()
        
        let type:Int = eventModel.type
        
        if isPastEvent(event: eventModel)
        {
            if type == 1
            {
                pinImgView.image = UIImage(named: IMAGE.GAMES_GRAY)
            }
            else if type == 2
            {
                pinImgView.image = UIImage(named: IMAGE.WORLDCUP_GRAY)
            }
            else if type == 3
            {
                pinImgView.image = UIImage(named: IMAGE.TRAINER_GRAY)
            }
        }
        else
        {
            if type == 1
            {
                pinImgView.image = UIImage(named: IMAGE.GAMES_ORANGE)
            }
            else if type == 2
            {
                pinImgView.image = UIImage(named: IMAGE.WORLDCUP_ORANGE)
            }
            else if type == 3
            {
                pinImgView.image = UIImage(named: IMAGE.TRAINER_ORANGE)
            }
        }
        setCommentTblViewHeight()
    }
    
    
    func getEventTypeName() -> String
    {
        var eventType : String = ""
        switch eventModel.type
        {
        case 1:
            eventType = "Game"
            break
        case 2:
            eventType = "Event"
            break
        case 3:
            eventType = "Training"
            break
        default:
            break
        }
        return eventType
    }
    
    func isMemberOfEvent() -> Bool
    {
        let index = eventModel.players.index(where: { (contact) -> Bool in
            contact.id == AppModel.shared.currentUser.uID
        })
        if index != nil {
            return true
        }
        else
        {
            return false
        }
    }
    func isJoinedEvent() -> Bool
    {
        let index = eventModel.players.index(where: { (contact) -> Bool in
            contact.id == AppModel.shared.currentUser.uID && contact.requestAction == 3
        })
        if index != nil {
            return true
        }
        else
        {
            return false
        }
    }
    
    @IBAction func clickToJoinBtn(_ sender: Any)
    {
        if eventModel.uID == AppModel.shared.currentUser.uID
        {
            displayToast("You are the host of " + getEventTypeName())
        }
        else
        {
            if(eventModel.privacyType == 1){
                if(isJoinedEvent()){
                    displayToast("You already joined " + getEventTypeName())
                }
                else{
                    //join event
                    AppDelegate().sharedDelegate().joinEvent(eventModel)
                    displayToast(getEventTypeName() + " joined successfully.")
                }
            }
            else{ // private
                if(isMemberOfEvent()){
                    if(isJoinedEvent()){
                        displayToast("You already joined " + getEventTypeName())
                    }
                    else{
                        //join event
                        AppDelegate().sharedDelegate().joinEvent(eventModel)
                        displayToast(getEventTypeName() + " joined successfully.")
                    }
                }
                else{
                    displayToast("Sorry, you can't join private " + getEventTypeName())
                }
            }
        }
    }
    
    @IBAction func clickToShareBtn(_ sender: Any)
    {
        if eventModel.uID == AppModel.shared.currentUser.uID || isJoinedEvent()
        {
            shareEvent(shareText: eventModel.title, shareImage: profilePicBtn.backgroundImage(for: UIControlState.normal))
        }
        else{
            displayToast("Sorry, you can't share " + getEventTypeName())
        }
    }
    
    @IBAction func clickToComment(_ sender: Any)
    {
        if eventModel.uID == AppModel.shared.currentUser.uID || isJoinedEvent(){
            let vc : CommentVC = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
            vc.court = nil
            vc.event = eventModel
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            if(isMemberOfEvent()){
                displayToast( "Please join " + getEventTypeName())
            }
            else{
                displayToast( "Sorry, you can't comment.")
            }

        }
    }
    
    @IBAction func clickToBack(_ sender: Any)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToEditEvent(_ sender: Any)
    {
        let vc : CreateNewGameEventTrainingVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateNewGameEventTrainingVC") as! CreateNewGameEventTrainingVC
        vc.eventModel = eventModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToInviteMember(_ sender: UIButton)
    {
        self.view.endEditing(true)
        OpenDialogForAddPlayers()
    }
    
    // MARK: - Collectionview Delaget methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrPlayerData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : CustomUserStoryCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomUserStoryCVC", for: indexPath) as! CustomUserStoryCVC
        
        let dict : UserModel = arrPlayerData[indexPath.row]
        cell.userNameLbl.text = dict.name
        
        AppDelegate().sharedDelegate().setUserProfileImage(dict.uID, button: cell.profilePicBtn)
        
        cell.profilePicBtn.addCornerRadius(radius: cell.profilePicBtn.frame.size.width/2)
        cell.userNameLbl.isHidden = false
        cell.userNameDarkLbl.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(eventModel.uID == AppModel.shared.currentUser.uID || isJoinedEvent()){
            AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: arrPlayerData[indexPath.row], isStoryDisplay: true, selectedEvent:eventModel)
        }
        else{
            AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: arrPlayerData[indexPath.row])
        }
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == addPlayerTblView
        {
            return ((searchPlayerTxt.text?.count)! == 0) ? arrMemberData.count : arrSearchMemberData.count
        }
        return eventModel.comment.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == commentTblView
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
            let comment : CommentModel = eventModel.comment[(eventModel.comment.count-1) - indexPath.row]
            
            cell?.messageTxtView.text = comment.text.decodeString
            
            let sizeThatFitsTextView:CGSize = cell!.messageTxtView.sizeThatFits(CGSize(width: commentTblView.frame.size.width-85, height: CGFloat(MAXFLOAT)))
            
            let height : Float = Float(75 - 37 + sizeThatFitsTextView.height)
            
            if height > 75
            {
                return CGFloat(height)
            }
            return 75.0
        }
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == addPlayerTblView
        {
            let cell = addPlayerTblView.dequeueReusableCell(withIdentifier: "CustomAddFriendTVC", for: indexPath) as! CustomAddFriendTVC
            
            let dict : UserModel = (((searchPlayerTxt.text?.count)! == 0) ? arrMemberData : arrSearchMemberData)[indexPath.row]
            
            cell.nameLbl.text = dict.name ?? ""
            cell.locationLbl.text = dict.location.address ?? ""
            
            AppDelegate().sharedDelegate().setUserProfileImage(dict.uID, button: cell.profilePicBtn)
            
            let index = arrSelectedMemberData.index(where: { (userModel) -> Bool in
                userModel.uID == dict.uID
            })
            if(index == nil){
                cell.addBtn.isSelected = false
            }
            else{
                cell.addBtn.isSelected = true
            }
            
            cell.addBtn.setBackgroundImage(imageWithColor(color: UIColor.clear), for: UIControlState.selected)
            cell.addBtn.setBackgroundImage(imageWithColor(color: colorFromHex(hex: COLOR.APP_COLOR)), for: UIControlState.selected)
            
            cell.addBtn.setTitleColor(colorFromHex(hex: COLOR.APP_COLOR), for: UIControlState.normal)
            cell.addBtn.setTitleColor(colorFromHex(hex: COLOR.WHITE), for: UIControlState.selected)
            
            cell.addBtn.tag = indexPath.row
            cell.addBtn.addTarget(self, action: #selector(clickToAddMember(_:)), for: UIControlEvents.touchUpInside)
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else
        {
            let cell : CustomCommentTVC = commentTblView.dequeueReusableCell(withIdentifier: "CustomCommentTVC", for: indexPath) as! CustomCommentTVC
            
            let comment : CommentModel = eventModel.comment[(eventModel.comment.count-1) - indexPath.row]
            
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func setCommentTblViewHeight()
    {
        commentTblView.reloadData()
        
        if commentTblView.contentSize.height > 0
        {
            constraintHeightCommentTblView.constant = commentTblView.contentSize.height + 88
            noCommentFound.isHidden = true
        }
        else
        {
            constraintHeightCommentTblView.constant = 30 + 88
            noCommentFound.isHidden = false
        }
        
    }
    
    @IBAction func clickToAddMember(_ sender: UIButton)
    {
        self.view.endEditing(true)
        
        let dict : UserModel = (((searchPlayerTxt.text?.count)! == 0) ? arrMemberData : arrSearchMemberData)[sender.tag]
        
        let index = arrSelectedMemberData.index(where: { (userModel) -> Bool in
            userModel.uID == dict.uID
        })
        if(index == nil){
            if(AppDelegate().sharedDelegate().isBlockMe(dict)){
                displayToast("Opps, " + dict.name + " has blocked you.")
            }
            else if(AppDelegate().sharedDelegate().isBlockUser(dict.uID)){
                displayToast("Unblock for further proceed.")
            }
            else{
                arrSelectedMemberData.append(dict)
            }
        }
        else{
            arrSelectedMemberData.remove(at: index!)
        }
        setPlayerTableHeight()
    }
    
    func shareEvent(shareText:String?,shareImage:UIImage?){
        
        var objectsToShare = [AnyObject]()
        
        let shareText : String = "Check-Up at " + eventModel.location.name + "\nTo use this app, install it from : " + APP.SHARE_URL + "\""
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
    
    
    //MARK: - Add Players
    func OpenDialogForAddPlayers()
    {
        addPlayerPopupView.addCornerRadiusOfView(radius: 10.0)
        addPlayerOkBtn.addCornerRadiusOfView(radius: 5.0)
        addPlayerCancelBtn.addCornerRadiusOfView(radius: 5.0)
        
        searchPlayerTxt.addCornerRadiusOfView(radius: 10)
        searchPlayerTxt.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR, alpha: 0.5))
        searchPlayerTxt.addPadding(padding: 5)
        
        setMemberData()
       
        if arrMemberData.count > 0
        {
            displaySubViewtoParentView(self.view, subview: addPlayerContainerView)
        }
        else
        {
            displayToast("No more friends.")
        }
        
    }
    func setMemberData(){
        arrSelectedMemberData = [UserModel] ()
        arrMemberData = [UserModel] ()
        
        for i in 0..<AppModel.shared.USERS.count
        {
            let index = AppModel.shared.currentUser.contact.index(where: { (contact) -> Bool in
                contact.id == AppModel.shared.USERS[i].uID && contact.requestAction == 3 && eventModel.uID != AppModel.shared.USERS[i].uID
            })
            if index != nil {
                
                let index1 = eventModel.players.index(where: { (tempCourt) -> Bool in
                    tempCourt.id == AppModel.shared.USERS[i].uID
                })
                
                if index1 == nil
                {
                    arrMemberData.append(AppModel.shared.USERS[i])
                }
            }
        }
        setPlayerTableHeight()
    }
    func setPlayerTableHeight()
    {
        addPlayerTblView.reloadData()
        
        if (addPlayerTblView.contentSize.height+50+105) > (SCREEN.HEIGHT - 100) {
            constraintHeightSearchPlayerView.constant = 50
            constraintHeightAddPlayerPopupView.constant = SCREEN.HEIGHT - 100
        }
        else{
            if(searchPlayerTxt.text?.count ==  0){
                constraintHeightSearchPlayerView.constant = 0
            }
            else{
                constraintHeightSearchPlayerView.constant = 50
            }
            constraintHeightAddPlayerPopupView.constant = addPlayerTblView.contentSize.height + constraintHeightSearchPlayerView.constant + 105
        }
        
    }
    
    @IBAction func clickToAddPlayerDoneBtn(_ sender: Any)
    {
        AppDelegate().sharedDelegate().addMoreUserToEvent(arrSelectedMemberData, event: eventModel)
        addPlayerContainerView.removeFromSuperview()
    }
    
    @IBAction func clickToAddPlayerCancelBtn(_ sender: Any)
    {
        addPlayerContainerView.removeFromSuperview()
    }
    
    func textFieldDidChange(noti : Notification)
    {
        let textField : UITextField = noti.object as! UITextField
        if textField == searchPlayerTxt
        {
            arrSearchMemberData = [UserModel]()
            for userModel : UserModel in arrMemberData
            {
                if userModel.name.lowercased().contains((searchPlayerTxt.text?.lowercased())!)
                {
                    arrSearchMemberData.append(userModel)
                }
            }
            setPlayerTableHeight()
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
