//
//  MessageNotificationVC.swift
//  Check-Up
//
//  Created by Amisha on 11/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import SWTableViewCell
import GoogleMobileAds

class MessageNotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, GADBannerViewDelegate {

    @IBOutlet var inviteMsgBgImgView: UIImageView!
    @IBOutlet var inviteBtn: UIButton!
    @IBOutlet var messageBtn: UIButton!
    @IBOutlet var friendRequestView: UIView!
    @IBOutlet var friendRequestTblView: UITableView!
    @IBOutlet var constraintHeightFriendRequestTbl: NSLayoutConstraint!
    @IBOutlet var todayInvitationView: UIView!
    @IBOutlet var todayInvitationTblView: UITableView!
    @IBOutlet var constraintHeightTodayInvitationTbl: NSLayoutConstraint!
    @IBOutlet var upcomingInvitationView: UIView!
    @IBOutlet var upcomingInvitationTblView: UITableView!
    @IBOutlet var constraintHeightUpcomingInvitationTbl: NSLayoutConstraint!
    
    @IBOutlet var notificationScrollView: UIScrollView!
    @IBOutlet var messageView: UIView!
    @IBOutlet var messageTblView: UITableView!
    @IBOutlet weak var unreadNotificationBtn: UIButton!
    
    @IBOutlet weak var bannerAdView: UIView!
    @IBOutlet weak var constraintHeightBannerAdView: NSLayoutConstraint!
    
    @IBOutlet weak var noDataFound: UILabel!
    
    var screenFrom : String!
    
    var isMessageDisplay : Bool = false
    
    var arrFriendRequest : [UserModel] = [UserModel] ()
    var arrMessage : [InboxListModel] = [InboxListModel] ()

    var arrTodayEvent : [EventModel] = [EventModel] ()
    var arrUpcomingEvent : [EventModel] = [EventModel] ()
    
    
    // MARK: - View Did Load
    
    override func viewWillAppear(_ animated: Bool)
    {
        OnUpdateMesaage()
        AppDelegate().sharedDelegate().setPushBadges()
        AppDelegate().sharedDelegate().onUpdateBadgeCount()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(onUpadteBadgeCount), name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_BADGE_COUNT), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateFriendRequest), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateEventData), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_EVENTS), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OnUpdateMesaage), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_INBOX), object: nil)
        
        
        setUIDesigning()
        
        friendRequestTblView.register(UINib.init(nibName: "CustomAddFriendTVC", bundle: nil), forCellReuseIdentifier: "CustomAddFriendTVC")
        todayInvitationTblView.register(UINib.init(nibName: "CustomInvitationTVC", bundle: nil), forCellReuseIdentifier: "CustomInvitationTVC")
        upcomingInvitationTblView.register(UINib.init(nibName: "CustomInvitationTVC", bundle: nil), forCellReuseIdentifier: "CustomInvitationTVC")
        messageTblView.register(UINib.init(nibName: "CustomMessgaeTVC", bundle: nil), forCellReuseIdentifier: "CustomMessgaeTVC")
        
    }
    
    func setBadgeCount()
    {
        AppDelegate().sharedDelegate().setPushBadges()
    }
    
    func setUIDesigning()
    {
        inviteMsgBgImgView.addCornerRadiusOfView(radius: 20.0)
        
        friendRequestTblView.backgroundColor = UIColor.clear
        friendRequestTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        friendRequestTblView.tableFooterView = UIView(frame: CGRect.zero)
        
        todayInvitationTblView.backgroundColor = UIColor.clear
        todayInvitationTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        todayInvitationTblView.tableFooterView = UIView(frame: CGRect.zero)
        
        upcomingInvitationTblView.backgroundColor = UIColor.clear
        upcomingInvitationTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        upcomingInvitationTblView.tableFooterView = UIView(frame: CGRect.zero)
        
        messageTblView.backgroundColor = UIColor.clear
        messageTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        messageTblView.tableFooterView = UIView(frame: CGRect.zero)
        
        setupBannerView()
        
        onUpdateFriendRequest()
        onUpdateEventData()
        if isMessageDisplay == true
        {
            clickToMessage(self)
        }
        else
        {
            clickToInvite(self)
        }
        
        OnUpdateMesaage()
        
    }
    
    func setupBannerView()
    {
        let bannerView: GADBannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = GOOGLE.BANNER_AD_ID
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerAdView.addSubview(bannerView)
        bannerView.load(GADRequest())
        constraintHeightBannerAdView.constant = 50
    }
    
    func onUpadteBadgeCount()
    {
        if AppModel.shared.BADGE_COUNT > 0
        {
            unreadNotificationBtn.setTitle(String(AppModel.shared.BADGE_COUNT), for: .normal)
            unreadNotificationBtn.isHidden = false
        }
        else
        {
            unreadNotificationBtn.isHidden = true
        }
    }
    
    func onUpdateFriendRequest()
    {
        if messageTblView == nil
        {
            return
        }
        arrFriendRequest = [UserModel] ()
        
        for i in 0..<AppModel.shared.currentUser.contact.count
        {
            let index = AppModel.shared.USERS.index(where: { (user) -> Bool in
                user.uID == AppModel.shared.currentUser.contact[i].id && AppModel.shared.currentUser.contact[i].requestAction == 2
            })
            if index != nil {
                arrFriendRequest.append(AppModel.shared.USERS[index!])
            }
        }
        setTableviewHeight()
        
        if inviteBtn.isSelected
        {
            noDataFound.text = "You have no invitation & events"
            noDataFound.isHidden = true
            if arrFriendRequest.count == 0 && arrTodayEvent.count == 0 && arrUpcomingEvent.count == 0
            {
                noDataFound.isHidden = false
            }
        }
    }
    
    func onUpdateEventData()
    {
        if messageTblView == nil
        {
            return
        }
        arrTodayEvent = [EventModel] ()
        arrUpcomingEvent = [EventModel] ()
        
        for i in 0..<AppModel.shared.EVENTS.count
        {
            let index = AppModel.shared.EVENTS[i].players.index(where: { (tempContact) -> Bool in
                tempContact.id == AppModel.shared.currentUser.uID
            })
            let event = AppModel.shared.EVENTS[i]
            if index != nil || event.uID == AppModel.shared.currentUser.uID
            {
                if(isTodayEvent(event: event)){
                    arrTodayEvent.append(event)
                }
                else if (isEventExpired(event : event)){
                    
                }
                else{
                    arrUpcomingEvent.append(event)
                }
            }
            
        }
        
        if arrTodayEvent.count > 1
        {
            arrTodayEvent.sort {
                let elapsed0 = $0.minDate
                let elapsed1 = $1.minDate
                return elapsed0! < elapsed1!
            }
        }
        
        if arrUpcomingEvent.count > 1
        {
            arrUpcomingEvent.sort {
                let elapsed0 = $0.minDate
                let elapsed1 = $1.minDate
                return elapsed0! < elapsed1!
            }
        }
        
        setTableviewHeight()
        
        if inviteBtn.isSelected
        {
            noDataFound.text = "You have no invitation & events"
            noDataFound.isHidden = true
            if arrFriendRequest.count == 0 && arrTodayEvent.count == 0 && arrUpcomingEvent.count == 0
            {
                noDataFound.isHidden = false
            }
        }
    }
    
    func OnUpdateMesaage()
    {
        if messageTblView == nil
        {
            return
        }
        
        arrMessage = [InboxListModel] ()
        for i in 0..<AppModel.shared.INBOXLIST.count
        {
            if (AppDelegate().sharedDelegate().isMyChanel(channelId: AppModel.shared.INBOXLIST[i].id)) && (AppModel.shared.INBOXLIST[i].lastMessage.msgID != "")
            {
                arrMessage.append(AppModel.shared.INBOXLIST[i])
            }
        }
        
        //arrMessage = arrMessage.sorted(by: { getDateFromUTCDate(date: $0.lastMessage.date) < (getDateFromUTCDate(date: $1.lastMessage.date))})
        
        if arrMessage.count > 1
        {
            arrMessage.sort {
                let elapsed0 = $0.lastMessage.date
                let elapsed1 = $1.lastMessage.date
                return elapsed0! > elapsed1!
            }
        }
        

        messageTblView.reloadData()
        
        if messageBtn.isSelected
        {
            noDataFound.text = "You have no messages"
            noDataFound.isHidden = true
            if arrMessage.count == 0 {
                noDataFound.isHidden = false
            }
        }
    }

    
    func setTableviewHeight()
    {
        friendRequestTblView.reloadData()
        if friendRequestTblView.contentSize.height > 0 {
            constraintHeightFriendRequestTbl.constant = friendRequestTblView.contentSize.height + 40
            friendRequestView.isHidden = false
        }else{
            constraintHeightFriendRequestTbl.constant = 0
            friendRequestView.isHidden = true
        }
        
        todayInvitationTblView.reloadData()
        if todayInvitationTblView.contentSize.height > 0 {
            constraintHeightTodayInvitationTbl.constant = todayInvitationTblView.contentSize.height + 40
            todayInvitationView.isHidden = false
        }else{
            constraintHeightTodayInvitationTbl.constant = 0
            todayInvitationView.isHidden = true
        }

        upcomingInvitationTblView.reloadData()
        if upcomingInvitationTblView.contentSize.height > 0 {
            constraintHeightUpcomingInvitationTbl.constant = upcomingInvitationTblView.contentSize.height + 40
            upcomingInvitationView.isHidden = false
        }else{
            constraintHeightUpcomingInvitationTbl.constant = 0
            upcomingInvitationView.isHidden = true
        }
    }
    
    // MARK: - Button click event
    
    @IBAction func clickToSendNewMessage(_ sender: Any)
    {
        let vc : NewMessageListVC = self.storyboard?.instantiateViewController(withIdentifier: "NewMessageListVC") as! NewMessageListVC
        vc.isRecentDisplay = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToAddNewFriend(_ sender: Any)
    {
        let vc : ContactsVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToInvite(_ sender: Any)
    {
        messageBtn.isSelected = false
        inviteBtn.isSelected = true
        messageView.isHidden = true
        notificationScrollView.isHidden = false
        setTableviewHeight()
        
        noDataFound.text = "You have no invitation & events"
        noDataFound.isHidden = true
        if arrFriendRequest.count == 0 && arrTodayEvent.count == 0 && arrUpcomingEvent.count == 0
        {
            noDataFound.isHidden = false
        }
    }
    
    @IBAction func clickToMessage(_ sender: Any)
    {
        messageBtn.isSelected = true
        inviteBtn.isSelected = false
        messageView.isHidden = false
        notificationScrollView.isHidden = true
        messageTblView.reloadData()
        
        noDataFound.text = "You have no messages"
        noDataFound.isHidden = true
        if arrMessage.count == 0 {
            noDataFound.isHidden = false
        }
    }
    
    @IBAction func clickToHome(_ sender: Any)
    {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func clickToStoryBtn(_ sender: Any)
    {
        if screenFrom != nil && screenFrom == "StoriesVC"
        {
            _ = self.navigationController?.popViewController(animated: true)
        }
        else
        {
            let vc : StoriesVC = self.storyboard?.instantiateViewController(withIdentifier: "StoriesVC") as! StoriesVC
            vc.screenFrom = "MessageNotificationVC"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == messageTblView {
            return arrMessage.count
        }
        else if tableView == friendRequestTblView
        {
            return arrFriendRequest.count
        }
        else if tableView == todayInvitationTblView
        {
            return arrTodayEvent.count
        }
        else if tableView == upcomingInvitationTblView
        {
            return arrUpcomingEvent.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == friendRequestTblView {
            return 75.0
        }
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == messageTblView
        {
            let cell = messageTblView.dequeueReusableCell(withIdentifier: "CustomMessgaeTVC", for: indexPath) as! CustomMessgaeTVC
            
            let inbox : InboxListModel = arrMessage[indexPath.row]
            
            if let user : UserModel = AppDelegate().sharedDelegate().getConnectUserDetail(channelId: inbox.id)
            {
                cell.nameLbl.text = user.name
                AppDelegate().sharedDelegate().setUserProfileImage(user.uID, button: cell.profilePicBtn)
            }
            
            
            if let tempStory = AppModel.shared.STORY[inbox.lastMessage.storyID]
            {
                if tempStory.type == 1 {
                    cell.imageMsgBtn.isHidden = false
                    cell.imageMsgBtn.setTitle("Image", for: UIControlState.normal)
                    cell.messageLbl.isHidden = true
                }
                else if tempStory.type == 2
                {
                    cell.imageMsgBtn.isHidden = false
                    cell.messageLbl.isHidden = true
                    cell.imageMsgBtn.setTitle("Story", for: UIControlState.normal)
                }
            }
            else
            {
                cell.imageMsgBtn.isHidden = true
                cell.messageLbl.isHidden = false
                cell.messageLbl.text = inbox.lastMessage.text.decodeString
            }
            
            
            cell.badgesLbl.text = ""
            cell.badgesLbl.isHidden = true
            let badgeKey : String = AppDelegate().sharedDelegate().getCurrentUserBadgeKey(inbox.id)
            if badgeKey == "badge1"
            {
                if inbox.badge1 > 0 {
                    cell.badgesLbl.text = String(inbox.badge1)
                    cell.badgesLbl.isHidden = false
                }
            }
            else
            {
                if inbox.badge2 > 0 {
                    cell.badgesLbl.text = String(inbox.badge2)
                    cell.badgesLbl.isHidden = false
                }
            }
            
            cell.durationLbl.text = getDifferenceFromCurrentTimeInHourInDays(date: inbox.lastMessage.date)
            cell.constraintWidthDurationLbl.constant = 90;
            
            cell.profilePicBtn.isUserInteractionEnabled = true
            cell.profilePicBtn.tag = indexPath.row
            cell.profilePicBtn.addTarget(self, action: #selector(clickToMessageUser(_:)), for: UIControlEvents.touchUpInside)
            
            if arrMessage.count-1 == indexPath.row
            {
                cell.seperatorImg.isHidden = true
            }
            else
            {
                cell.seperatorImg.isHidden = false
            }
            cell.setRightUtilityButtons(CancelRequestCellButton() as! [Any], withButtonWidth: 70)
            cell.delegate = self
            cell.tag = 400
            
            cell.selectionBtn.isHidden = true
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else if tableView == friendRequestTblView
        {
            let cell = friendRequestTblView.dequeueReusableCell(withIdentifier: "CustomAddFriendTVC", for: indexPath) as! CustomAddFriendTVC
            let user : UserModel = arrFriendRequest[indexPath.row]
            
            cell.nameLbl.text = user.username
            
            AppDelegate().sharedDelegate().setUserProfileImage(user.uID, button: cell.profilePicBtn)
            
            cell.locationLbl.text = user.name

            
            cell.addBtn.tag = indexPath.row
            cell.addBtn.addTarget(self, action: #selector(clickToAddFriend(_:)), for: UIControlEvents.touchUpInside)
            
            cell.setRightUtilityButtons(CancelRequestCellButton() as! [Any], withButtonWidth: 70)
            cell.delegate = self
            cell.tag = 100
            
            cell.profilePicBtn.isUserInteractionEnabled = true
            cell.profilePicBtn.tag = indexPath.row
            cell.profilePicBtn.addTarget(self, action: #selector(clickToFriendRequestUser(_:)), for: UIControlEvents.touchUpInside)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else if tableView == todayInvitationTblView
        {
            let cell = todayInvitationTblView.dequeueReusableCell(withIdentifier: "CustomInvitationTVC", for: indexPath) as! CustomInvitationTVC
            
            let event : EventModel = arrTodayEvent[indexPath.row]
            
            cell.profilePicBtn.setImage(nil, for: UIControlState.normal)
            cell.profilePicBtn.setBackgroundImage(nil, for: UIControlState.normal)
            cell.joinBtn.isHidden = true
            cell.constraintTimeBtnYPosition.constant = 0
            cell.joinBtn.tag = indexPath.row
            cell.joinBtn.addTarget(self, action: #selector(clickToJoinTodayEvent(_:)), for: UIControlEvents.touchUpInside)
            
            if getDifferenceFromCurrentTime(date: event.minDate) < 0
            {
                cell.timeBtn.setTitle(getTimeStringFromFCM(event.minDate), for: UIControlState.normal)
            }
            else if getDifferenceToCurrentTime(date: event.maxDate) < 0
            {
                cell.timeBtn.setTitle("EXPIRED", for: UIControlState.normal)
            }
            else
            {
                cell.timeBtn.setTitle("NOW", for: UIControlState.normal)
            }
            
            cell.timeBtn.tag = indexPath.row
            cell.timeBtn.addTarget(self, action: #selector(clickToTimeBtn(_:)), for: UIControlEvents.touchUpInside)
            cell.dateLbl.isHidden = true
            cell.sentByUserLbl.text = ""
            
            let index = event.players.index(where: { (contact) -> Bool in
                contact.id == AppModel.shared.currentUser.uID
            })
            if index != nil
            {
                if event.players[index!].requestAction == 1
                {
                    cell.joinBtn.isHidden = false
                    cell.constraintTimeBtnYPosition.constant = 18
                }
            }
            
            cell.nameLbl.text = event.title
            switch event.type
            {
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
            
            let index1 = AppModel.shared.USERS.index(where: { (userID) -> Bool in
                userID.uID == event.uID
            })
            
            if index1 != nil {
                cell.sentByUserLbl.text = "Sent by " + AppModel.shared.USERS[index1!].name
            }
            else{
                cell.sentByUserLbl.text = "Sent by you"
            }
            
            if event.type == 2 {
                cell.totalMemberLbl.text = String(event.players.count) + (event.players.count > 1 ? " players" : " player") + " going"
            } else {
                cell.totalMemberLbl.text = String(event.players.count) + (event.players.count > 1 ? " others" : " other") + " invited"
            }
            
            if arrTodayEvent.count-1 == indexPath.row {
                cell.seperatorImgView.isHidden = true
            } else {
                cell.seperatorImgView.isHidden = false
            }
            cell.setRightUtilityButtons(CancelRequestCellButton() as! [Any], withButtonWidth: 70)
            cell.delegate = self
            cell.tag = 200
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else
        {
            let cell = upcomingInvitationTblView.dequeueReusableCell(withIdentifier: "CustomInvitationTVC", for: indexPath) as! CustomInvitationTVC
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            let event : EventModel = arrUpcomingEvent[indexPath.row]
            cell.profilePicBtn.setImage(nil, for: UIControlState.normal)
            cell.profilePicBtn.setBackgroundImage(nil, for: UIControlState.normal)
            cell.joinBtn.isHidden = true
            cell.constraintTimeBtnYPosition.constant = 0
            cell.joinBtn.tag = indexPath.row
            cell.joinBtn.addTarget(self, action: #selector(clickToJoinUpcomingEvent(_:)), for: UIControlEvents.touchUpInside)
            cell.timeBtn.setTitle(getTimeStringFromFCM(event.minDate), for: UIControlState.normal)
            cell.timeBtn.tag = indexPath.row
            cell.timeBtn.addTarget(self, action: #selector(clickToTimeBtn(_:)), for: UIControlEvents.touchUpInside)
            cell.dateLbl.isHidden = false
            cell.dateLbl.text = getFormatedDateStringFromFCM(FORMAT.FCM_DATETIME, newFormat: "M/d", date: event.minDate)
            cell.sentByUserLbl.text = ""
            
            let index = event.players.index(where: { (contact) -> Bool in
                contact.id == AppModel.shared.currentUser.uID
            })
            if index != nil
            {
                if event.players[index!].requestAction == 1
                {
                    cell.joinBtn.isHidden = false
                    cell.constraintTimeBtnYPosition.constant = 18
                }
            }
            
            cell.nameLbl.text = event.title
            
            switch event.type {
                case 1:
                    cell.profilePicBtn.setImage(UIImage(named: IMAGE.GAMES_GRAY_SMALL), for: UIControlState.normal)
                    break
                case 2:
                    cell.profilePicBtn.setImage(UIImage(named: IMAGE.WORLDCUP_GRAY_SMALL), for: UIControlState.normal)
                    break
                case 3:
                    cell.profilePicBtn.setImage(UIImage(named: IMAGE.TRAINER_GRAY_SMALL), for: UIControlState.normal)
                    break
                default:
                    break
            }
            
            let index1 = AppModel.shared.USERS.index(where: { (userID) -> Bool in
                userID.uID == event.uID
            })
            
            if index1 != nil {
                cell.sentByUserLbl.text = "Sent by " + AppModel.shared.USERS[index1!].name
            }
            else{
                cell.sentByUserLbl.text = "Sent by you"
            }
            
            if event.type == 2 {
                cell.totalMemberLbl.text = String(event.players.count) + (event.players.count > 1 ? " players" : " player") + " going"
            } else {
                cell.totalMemberLbl.text = String(event.players.count) + (event.players.count > 1 ? " others" : " other") + " invited"
            }
            
            if arrUpcomingEvent.count-1 == indexPath.row {
                cell.seperatorImgView.isHidden = true
            }
            else{
                cell.seperatorImgView.isHidden = false
            }
            cell.setRightUtilityButtons(CancelRequestCellButton() as! [Any], withButtonWidth: 70)
            cell.delegate = self
            cell.tag = 300
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == messageTblView
        {
            let inbox : InboxListModel = arrMessage[indexPath.row]
            if let user : UserModel = AppDelegate().sharedDelegate().getConnectUserDetail(channelId: inbox.id)
            {
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
        }
        else if tableView == todayInvitationTblView
        {
            let vc : GameDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "GameDetailVC") as! GameDetailVC
            vc.eventModel = arrTodayEvent[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if tableView == upcomingInvitationTblView
        {
            let vc : GameDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "GameDetailVC") as! GameDetailVC
            vc.eventModel = arrUpcomingEvent[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func clickToFriendRequestUser(_ sender: UIButton)
    {
        AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: arrFriendRequest[sender.tag])
    }
    
    @IBAction func clickToMessageUser(_ sender: UIButton)
    {
        let inbox : InboxListModel = arrMessage[sender.tag]
        if let user : UserModel = AppDelegate().sharedDelegate().getConnectUserDetail(channelId: inbox.id)
        {
            AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: user)
        }
    }
    
    func CancelRequestCellButton() -> NSArray {
        let rightUtilityButtons = NSMutableArray()
        rightUtilityButtons.sw_addUtilityButton(with: colorFromHex(hex: COLOR.WHITE), icon: UIImage.init(named: "cross_dark"))
        return rightUtilityButtons
    }
    
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        
        if cell.tag == 100 //Friend Request
        {
            let cellIndexPath : NSIndexPath = friendRequestTblView.indexPath(for: cell)! as NSIndexPath
            let user : UserModel = arrFriendRequest[cellIndexPath.row]
            AppDelegate().sharedDelegate().removeFriendFromUser(user)
            arrFriendRequest.remove(at: cellIndexPath.row)
            setBadgeCount()
        }
        else if cell.tag == 400 //Messages
        {
            let cellIndexPath : NSIndexPath = messageTblView.indexPath(for: cell)! as NSIndexPath
            let inbox : InboxListModel = arrMessage[cellIndexPath.row]
            
            let index = AppModel.shared.INBOXLIST.index(where: { (tempIndex) -> Bool in
                tempIndex.id == inbox.id
            })
            
            if index != nil
            {
                AppModel.shared.INBOXLIST.remove(at: index!)
                AppDelegate().sharedDelegate().inboxListRef.child(inbox.id).removeValue()
                AppDelegate().sharedDelegate().messageListRef.child(inbox.id).removeValue()
                arrMessage.remove(at: cellIndexPath.row)
                AppDelegate().sharedDelegate().deleteAllMessageFromCoreData(inbox.id)
            }
        }
        else{
            let event : EventModel!
            if cell.tag == 200  //Today Event
            {
                let cellIndexPath : NSIndexPath = todayInvitationTblView.indexPath(for: cell)! as NSIndexPath
                event = arrTodayEvent[cellIndexPath.row]
                arrTodayEvent.remove(at: cellIndexPath.row)
                
                AppDelegate().sharedDelegate().removeEventInvitation(event)
                setBadgeCount()
            }
            else if cell.tag == 300 //Upcoming Event
            {
                let cellIndexPath : NSIndexPath = upcomingInvitationTblView.indexPath(for: cell)! as NSIndexPath
                event = arrUpcomingEvent[cellIndexPath.row]
                arrUpcomingEvent.remove(at: cellIndexPath.row)
                
                AppDelegate().sharedDelegate().removeEventInvitation(event)
                setBadgeCount()
            }
        }
        
        setTableviewHeight()
        cell.hideUtilityButtons(animated: true)
    }
    
    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    @IBAction func clickToAddFriend(_ sender: UIButton)
    {
        //print(sender.tag)
        
        let user : UserModel = arrFriendRequest[sender.tag]
        AppDelegate().sharedDelegate().addFriend(user)
        arrFriendRequest.remove(at: sender.tag)
        setTableviewHeight()
        setBadgeCount()
    }
    
    @IBAction func clickToJoinTodayEvent(_ sender: UIButton)
    {
        AppDelegate().sharedDelegate().joinEvent(arrTodayEvent[sender.tag])
        setBadgeCount()
    }
    
    @IBAction func clickToJoinUpcomingEvent(_ sender: UIButton)
    {
        AppDelegate().sharedDelegate().joinEvent(arrUpcomingEvent[sender.tag])
        setBadgeCount()
    }
    
    @IBAction func clickToTimeBtn(_ sender: UIButton)
    {
        //print(sender.tag)
    }
    
    //MARK: - Banner Ad Delegate
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        //print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        //print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        //print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        //print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        //print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        //print("adViewWillLeaveApplication")
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
