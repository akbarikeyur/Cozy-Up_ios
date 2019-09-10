//
//  ChatViewController.swift
//  Check-Up
//
//  Created by Amisha on 16/09/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import IQKeyboardManagerSwift
import PEPhotoCropEditor
import AVKit
import AVFoundation
import MediaPlayer
import CoreData

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, customPopUpDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PECropViewControllerDelegate {

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var lastSeenLbl: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var constraintHeightTblView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightMsgTextView: NSLayoutConstraint!
    
    @IBOutlet var sendImageContainerVIew: UIView!
    @IBOutlet weak var receiverImgBtn: UIButton!
    @IBOutlet weak var sendImgView: UIImageView!
    @IBOutlet weak var imageAddCaptionTxt: UITextField!
    
    @IBOutlet var videoPlayContainerView: UIView!
    @IBOutlet var videoPlayView: UIView!
    @IBOutlet var closeVideoPlayViewBtn: UIButton!
    
    var moviePlayer : AVPlayer?
    let playerViewController = AVPlayerViewController()
    
    var channelId : String!
    var receiver : UserModel!
    
    var messagesRef:DatabaseReference!
    var messagesRefHandler : UInt = 0
    var updateMessagesRefHandler : UInt = 0
    var messages:[MessageModel] = [MessageModel]()
    var coreDataMsgDict : [String : Bool] = [String : Bool] ()
    var newSendMessagesArr:[String : Bool] = [String : Bool] () //message id
    
    var offscreenCellSender : [String : Any] = [String : Any] ()
    var offscreenCellSenderImg : [String : Any] = [String : Any] ()
    var offscreenCellReceiver : [String : Any] = [String : Any] ()
    var offscreenCellReceiverImg : [String : Any] = [String : Any] ()
    var lastSeenTimer : Timer!
    
    var CustomPopUp : customPopUp!
    var uploadImage : UIImage!
    
    var isAppear:Bool = false
    
    override func viewWillDisappear(_ animated: Bool) {
        //messagesRef.removeObserver(withHandle: messagesRefHandler)
        //messagesRef.removeObserver(withHandle: updateMessagesRefHandler)
        isAppear = false
        DispatchQueue.main.async {
            removeLoader()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        isAppear = true
    }
    override func viewDidAppear(_ animated: Bool) {
        self.fetchFirebaseMessages()
        self.onUpdateFirebaseMessages()
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserLastSeen), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateStories), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_STORIES), object: nil)
        
        tblView.register(UINib.init(nibName: "SendChatMessageTVC", bundle: nil), forCellReuseIdentifier: "SendChatMessageTVC")
        tblView.register(UINib.init(nibName: "ReceiverChatMessageTVC", bundle: nil), forCellReuseIdentifier: "ReceiverChatMessageTVC")
        tblView.register(UINib.init(nibName: "SenderImageMessageTVC", bundle: nil), forCellReuseIdentifier: "SenderImageMessageTVC")
        tblView.register(UINib.init(nibName: "ReceiverImageMessageTVC", bundle: nil), forCellReuseIdentifier: "ReceiverImageMessageTVC")
        
        
        tblView.backgroundColor = UIColor.clear
        tblView.separatorStyle = UITableViewCellSeparatorStyle.none
        tblView.tableFooterView = UIView(frame: CGRect.zero)

        playerViewController.showsPlaybackControls = false
        playerViewController.view.frame = self.view.bounds
        
        
        msgTextView.applyBorderOfView(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        msgTextView.addCornerRadiusOfView(radius: 2)
        msgTextView.delegate = self
        
        messagesRef = Database.database().reference().child("MESSAGES").child(channelId)
        
        //deleteAllMessageFromCoreData()
        fetchCoreDataMessages()
        updateUserLastSeen()
        
    }
    
    //MARK:- Update func
    
    func updateUserLastSeen()
    {
        if tblView == nil
        {
            return
        }
        if channelId == nil || channelId.count == 0
        {
            return
        }
        
        if let user : UserModel = AppDelegate().sharedDelegate().getConnectUserDetail(channelId: channelId)
        {
            receiver = user
            userNameLbl.text = receiver.name
            
            if receiver.last_seen.count == 0 {
                lastSeenLbl.text = "Online"
                if lastSeenTimer != nil && lastSeenTimer.isValid
                {
                    lastSeenTimer.invalidate()
                }
            }
            else
            {
                lastSeenLbl.text = getDifferenceFromCurrentTimeInHourInDays(date: receiver.last_seen)
                lastSeenTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateUserLastSeen), userInfo: nil, repeats: false)
            }
        }
        
    }
    
    func onUpdateStories()
    {
        if tblView == nil
        {
            return
        }
        fetchCoreDataMessages()
    }
    
    
    //MARK:- messages
    
    func fetchCoreDataMessages(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        messages = [MessageModel]()
        
        let managedContext = appDelegate.persistentContainer.viewContext
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: COREDATA.MESSAGE.TABLE_NAME)
        fetchRequest.predicate = NSPredicate(format: "channeld == %@",channelId)
        // Add Sort Descriptors
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "channeld", ascending: true), NSSortDescriptor(key: "msgID", ascending: true)]
        
        // Initialize Asynchronous Fetch Request
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (asynchronousFetchResult) -> Void in
            DispatchQueue.main.async {
                if let result = asynchronousFetchResult.finalResult {
                    
                    // Update Items
                    let messagesArr: [NSManagedObject] = result as! [NSManagedObject]
                    
                    for msg in messagesArr
                    {
                        if msg.value(forKey: "storyID") != nil && (msg.value(forKey: "storyID") as! String == "" || AppModel.shared.STORY[msg.value(forKey: "storyID") as! String] != nil)
                        {
                            let tempMsg : MessageModel = MessageModel.init(msgID: msg.value(forKey: COREDATA.MESSAGE.msgID) as! String, key: msg.value(forKey: COREDATA.MESSAGE.key) as! String, connectUserID: msg.value(forKey: COREDATA.MESSAGE.connectUserID) as! String, date: msg.value(forKey: COREDATA.MESSAGE.date) as! String, text: msg.value(forKey: COREDATA.MESSAGE.text) as! String, storyID: msg.value(forKey: COREDATA.MESSAGE.storyID) as! String, status: msg.value(forKey: COREDATA.MESSAGE.status) as! Int)
                            self.messages.append(tempMsg)
                            self.coreDataMsgDict[tempMsg.msgID] = true
                        }
                        else
                        {
                            managedContext.delete(msg)
                        }
                    }
                    self.tblView.reloadData()
                    self.setTblViewHeight()
                }
            }
        }
        
        do {
            // Execute Asynchronous Fetch Request
            let asynchronousFetchResult = try managedContext.execute(asynchronousFetchRequest)
            
            print(asynchronousFetchResult)
            
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
   

    func fetchFirebaseMessages()
    {
        messagesRefHandler =  messagesRef.observe(DataEventType.childAdded) { (snapshot : DataSnapshot) in
            if(self.isAppear == false){
                return
            }
            if(snapshot.exists())
            {
                let msgDict = snapshot.value as? [String : AnyObject] ?? [:]
                let message : MessageModel = MessageModel.init(dict: msgDict)
                
                if let _ = self.newSendMessagesArr[message.msgID]
                {}
                else{
                    if let _ = self.coreDataMsgDict[message.msgID]{
                        //skip firebase message if its save in core data
                    }
                    else if (message.status != 1 || message.connectUserID != AppModel.shared.currentUser.uID)
                    {
                        if message.storyID != ""
                        {
                            //print(message.storyID)
                            if AppModel.shared.STORY[message.storyID] != nil
                            {
                                self.addMessage(message)
                                if message.connectUserID == AppModel.shared.currentUser.uID
                                {
                                    AppDelegate().sharedDelegate().onGetMessage(message: message, chanelId: self.channelId)
                                }
                            }
                        }
                        else
                        {
                            self.addMessage(message)
                            if message.connectUserID == AppModel.shared.currentUser.uID
                            {
                                AppDelegate().sharedDelegate().onGetMessage(message: message, chanelId: self.channelId)
                            }
                        }
                    }
                }
            }
        }
    }
    func onUpdateFirebaseMessages(){
        updateMessagesRefHandler = messagesRef.observe(DataEventType.childChanged) { (snapshot : DataSnapshot) in
            if(self.isAppear == false){
                return
            }
            if(snapshot.exists())
            {
                let msgDict = snapshot.value as? [String : AnyObject] ?? [:]
                let message : MessageModel = MessageModel.init(dict: msgDict)
               
                if let _ = self.coreDataMsgDict[message.msgID]
                {
                    self.updateMessage(message)
                }
                else
                {
                    if (message.status != 1 || message.connectUserID != AppModel.shared.currentUser.uID){
                        if message.storyID != ""
                        {
                            //print(message.storyID)
                            if AppModel.shared.STORY[message.storyID] != nil
                            {
                                self.addMessage(message)
                                if message.connectUserID == AppModel.shared.currentUser.uID
                                {
                                    AppDelegate().sharedDelegate().onGetMessage(message: message, chanelId: self.channelId)
                                }
                            }
                        }
                        else
                        {
                            self.addMessage(message)
                            if message.connectUserID == AppModel.shared.currentUser.uID
                            {
                                AppDelegate().sharedDelegate().onGetMessage(message: message, chanelId: self.channelId)
                            }
                        }
                    }
                    
                }
            }
            
        }
    }
    
    func addMessage(_ newMessage:MessageModel){
        
        messages.append(newMessage)
        coreDataMsgDict[newMessage.msgID] = true
        self.tblView.beginUpdates()
        self.tblView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .automatic)
        self.tblView.endUpdates()
        self.setTblViewHeight()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: COREDATA.MESSAGE.TABLE_NAME,
                                                in: managedContext)!
        
        let message = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
        
        message.setValue(channelId, forKeyPath: COREDATA.MESSAGE.CHANNEL_ID)
        message.setValue(newMessage.msgID, forKey: COREDATA.MESSAGE.msgID)
        message.setValue(newMessage.connectUserID, forKey: COREDATA.MESSAGE.connectUserID)
        message.setValue(newMessage.date, forKey: COREDATA.MESSAGE.date)
        message.setValue(newMessage.key, forKey: COREDATA.MESSAGE.key)
        message.setValue(newMessage.status, forKey: COREDATA.MESSAGE.status)
        message.setValue(newMessage.storyID, forKey: COREDATA.MESSAGE.storyID)
        message.setValue(newMessage.text, forKey: COREDATA.MESSAGE.text)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func updateMessage(_ message:MessageModel){
        
        let index = self.messages.index(where: { (temp) -> Bool in
            temp.msgID == message.msgID
        })
        if(index != nil){
            self.messages[index!] = message
            self.tblView.beginUpdates()
            self.tblView.reloadRows(at: [IndexPath(row:index!, section:0)], with: .automatic)
            self.tblView.endUpdates()
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: COREDATA.MESSAGE.TABLE_NAME)
            fetchRequest.predicate = NSPredicate(format: "%@ = %@ AND %@ = %@",COREDATA.MESSAGE.CHANNEL_ID,channelId,COREDATA.MESSAGE.msgID,message.msgID)
            do {
                let messagesArr: [NSManagedObject] = try managedContext.fetch(fetchRequest)
                
                if(messagesArr.count == 1)
                {
                    let msgUpdate = messagesArr[0]
                    msgUpdate.setValue(channelId, forKeyPath: COREDATA.MESSAGE.CHANNEL_ID)
                    msgUpdate.setValue(message.msgID, forKey: COREDATA.MESSAGE.msgID)
                    msgUpdate.setValue(message.connectUserID, forKey: COREDATA.MESSAGE.connectUserID)
                    msgUpdate.setValue(message.date, forKey: COREDATA.MESSAGE.date)
                    msgUpdate.setValue(message.key, forKey: COREDATA.MESSAGE.key)
                    msgUpdate.setValue(message.status, forKey: COREDATA.MESSAGE.status)
                    msgUpdate.setValue(message.storyID, forKey: COREDATA.MESSAGE.storyID)
                    msgUpdate.setValue(message.text, forKey: COREDATA.MESSAGE.text)
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not update. \(error), \(error.userInfo)")
                    }

                }
                
            } catch let error as NSError {
                print("Could not update. \(error), \(error.userInfo)")
            }
            
        }
    }
   
    
    //MARK:- Button tap action
    @IBAction func clickToAttachment(_ sender: Any)
    {
        self.view.endEditing(true)
        self.openCustomPopup()
    }
    
    @IBAction func clickToSendMessage(_ sender: Any)
    {
        msgTextView.text = msgTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if msgTextView.text != ""
        {
            let newMsgRef : DatabaseReference = messagesRef.childByAutoId()
            
            let msgModel: MessageModel = MessageModel.init(msgID: getCurrentTimeStampValue(), key : newMsgRef.key, connectUserID: receiver.uID, date: getCurrentDateInString(), text: msgTextView.text.encodeString, storyID : "", status:2)
            addMessage(msgModel)
            newSendMessagesArr[msgModel.msgID] = true
            newMsgRef.setValue(msgModel.dictionary())
            msgTextView.text = ""
            AppDelegate().sharedDelegate().onSendMessage(message: msgModel, chanelId: channelId)
        }
    }
    @IBAction func clickToBack(_ sender: Any)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let dict : MessageModel = messages[indexPath.row]
        if dict.connectUserID != AppModel.shared.currentUser.uID
        {
            if dict.storyID != ""
            {
                if let tempStory = AppModel.shared.STORY[dict.storyID]
                {
                    var cell:SenderImageMessageTVC!
                    cell = offscreenCellSenderImg["SenderImageMessageTVC"] as? SenderImageMessageTVC
                    if cell == nil {
                        cell = tblView.dequeueReusableCell(withIdentifier: "SenderImageMessageTVC") as! SenderImageMessageTVC
                        offscreenCellSenderImg["SenderImageMessageTVC"] = cell
                    }
                    
                    var headerHeight : CGFloat = 0
                    if indexPath.row == 0 || isSameDate(firstDate: dict.date, secondDate: messages[indexPath.row-1].date) == false
                    {
                        cell.headerView.isHidden = false
                        cell.headerLbl.text = getdayDifferenceFromCurrentDay(dict.date)
                        headerHeight = 30
                    }
                    
                    cell.messageTxtView.text = tempStory.description.decodeString
                    
                    let sizeThatFitsTextView:CGSize = cell.messageTxtView.sizeThatFits(CGSize(width: tblView.frame.size.width-115, height: CGFloat(MAXFLOAT)))
                    cell.ConstraintHeightMsgTxt.constant = sizeThatFitsTextView.height
                    cell.ConstraintHeightMessageView.constant = 170 - 35 + (cell.ConstraintHeightMsgTxt.constant);
                    return 30 + (cell.ConstraintHeightMessageView.constant) + headerHeight
                }
                else{
                    return 0
                }
                
            }
            else
            {
                var cell:SendChatMessageTVC!
                cell = offscreenCellSender["SendChatMessageTVC"] as? SendChatMessageTVC
                if cell == nil {
                    cell = tblView.dequeueReusableCell(withIdentifier: "SendChatMessageTVC") as! SendChatMessageTVC
                    offscreenCellSender["SendChatMessageTVC"] = cell
                }
                cell.messageTxtView.text = dict.text.decodeString
                
                let sizeThatFitsTextView:CGSize = cell.messageTxtView.sizeThatFits(CGSize(width: tblView.frame.size.width-110, height: CGFloat(MAXFLOAT)))
                cell.ConstraintWidthMessageView.constant = sizeThatFitsTextView.width + 5
                cell.ConstraintHeightMessageView.constant = sizeThatFitsTextView.height + 5
                
                var headerHeight : CGFloat = 0
                if indexPath.row == 0 || isSameDate(firstDate: dict.date, secondDate: messages[indexPath.row-1].date) == false
                {
                    headerHeight = 30
                }

                return 70 - 35 + cell.ConstraintHeightMessageView.constant + headerHeight
            }
        }
        else
        {
            if dict.storyID != ""
            {
                if let tempStory = AppModel.shared.STORY[dict.storyID]
                {
                    var cell:ReceiverImageMessageTVC!
                    cell = offscreenCellReceiverImg["ReceiverImageMessageTVC"] as? ReceiverImageMessageTVC
                    if cell == nil {
                        cell = tblView.dequeueReusableCell(withIdentifier: "ReceiverImageMessageTVC") as! ReceiverImageMessageTVC
                        offscreenCellReceiverImg["ReceiverImageMessageTVC"] = cell
                    }
                    cell.messageTxtView.text = tempStory.description.decodeString
                    
                    let sizeThatFitsTextView:CGSize = cell.messageTxtView.sizeThatFits(CGSize(width: tblView.frame.size.width-115, height: CGFloat(MAXFLOAT)))
                    cell.ConstraintHeightMsgTxt.constant = sizeThatFitsTextView.height
                    cell.ConstraintHeightMessageView.constant = 170 - 35 + (cell.ConstraintHeightMsgTxt.constant);
                    var headerHeight : CGFloat = 0
                    if indexPath.row == 0 || isSameDate(firstDate: dict.date, secondDate: messages[indexPath.row-1].date) == false
                    {
                        cell.headerView.isHidden = false
                        cell.headerLbl.text = getdayDifferenceFromCurrentDay(dict.date)
                        headerHeight = 30
                    }
                    return 30 + (cell.ConstraintHeightMessageView.constant) + headerHeight
                }
                else
                {
                    return 0
                }
            }
            var cell:ReceiverChatMessageTVC!
            cell = offscreenCellReceiver["ReceiverChatMessageTVC"] as? ReceiverChatMessageTVC
            if cell == nil {
                cell = tblView.dequeueReusableCell(withIdentifier: "ReceiverChatMessageTVC") as! ReceiverChatMessageTVC
                offscreenCellReceiver["ReceiverChatMessageTVC"] = cell
            }
            
            
            cell.messageTxtView.text = dict.text.decodeString
            
            let sizeThatFitsTextView:CGSize = cell.messageTxtView.sizeThatFits(CGSize(width: tblView.frame.size.width-110, height: CGFloat(MAXFLOAT)))
            cell.ConstraintWidthMessageView.constant = sizeThatFitsTextView.width + 5
            cell.ConstraintHeightMessageView.constant = sizeThatFitsTextView.height + 5
            var headerHeight : CGFloat = 0
            if indexPath.row == 0 || isSameDate(firstDate: dict.date, secondDate: messages[indexPath.row-1].date) == false
            {
                cell.headerView.isHidden = false
                cell.headerLbl.text = getdayDifferenceFromCurrentDay(dict.date)
                headerHeight = 30
            }
            return 70 - 35 + cell.ConstraintHeightMessageView.constant + headerHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : MessageCell!
        
        let dict : MessageModel = messages[indexPath.row]
        
        if dict.connectUserID != AppModel.shared.currentUser.uID {
            //sender message
            if(dict.storyID == ""){
                cell = tblView.dequeueReusableCell(withIdentifier: "SendChatMessageTVC", for: indexPath) as! MessageCell
            }
            else{
                cell = tblView.dequeueReusableCell(withIdentifier: "SenderImageMessageTVC", for: indexPath) as! MessageCell
            }
            AppDelegate().sharedDelegate().setUserProfileImage(AppModel.shared.currentUser.uID, button: cell.profilePicBtn)
            cell.messageTxtView.linkTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        }
        else{
            if(dict.storyID == ""){
                cell = tblView.dequeueReusableCell(withIdentifier: "ReceiverChatMessageTVC", for: indexPath) as! MessageCell
            }
            else{
                cell = tblView.dequeueReusableCell(withIdentifier: "ReceiverImageMessageTVC", for: indexPath) as! MessageCell
            }
            AppDelegate().sharedDelegate().setUserProfileImage(receiver.uID, button: cell.profilePicBtn)
            cell.messageTxtView.linkTextAttributes = [NSForegroundColorAttributeName : colorFromHex(hex: "3C3739")]
        }
        
        if indexPath.row == 0 || isSameDate(firstDate: dict.date, secondDate: messages[indexPath.row-1].date) == false
        {
            cell.headerView.isHidden = false
            cell.headerLbl.text = "  " + getdayDifferenceFromCurrentDay(dict.date) + "  "
            cell.constraintHeaderWidth.constant = (cell.headerLbl.intrinsicContentSize.width)
            cell.constraintHeightHeaderView.constant = 30
        }
        else
        {
            cell.headerView.isHidden = true
            cell.constraintHeaderWidth.constant = 0
            cell.constraintHeightHeaderView.constant = 0
        }
        if indexPath.row > 0  && dict.connectUserID == messages[indexPath.row-1].connectUserID
        {
            cell.profilePicView.isHidden = true
        }
        else
        {
            cell.profilePicView.isHidden = false
        }
        
        cell.durationLbl.text = getFormatedDateStringFromFCM(FORMAT.FCM_DATETIME, newFormat: FORMAT.DISPLAY_TIME, date: dict.date)
        
        if(dict.storyID == ""){
            
            cell.messageTxtView.text = dict.text.decodeString
            let sizeThatFitsTextView:CGSize = cell.messageTxtView.sizeThatFits(CGSize(width: tblView.frame.size.width-110, height: CGFloat(MAXFLOAT)))
            cell.ConstraintWidthMessageView.constant = sizeThatFitsTextView.width + 5
            cell.ConstraintHeightMessageView.constant = sizeThatFitsTextView.height + 5
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else
        {
            let tempStory = AppModel.shared.STORY[dict.storyID]!
            
            cell.messageImgBtn.setBackgroundImage(nil, for: UIControlState.normal)
            cell.messageImgBtn.setImage(UIImage(named: IMAGE.PLACEHOLDER_BG), for: UIControlState.normal)
            cell.messageImgBtn.contentMode = .scaleAspectFit
            
            cell.messageTxtView.text = ""
            cell.errorBtn.isHidden = true
            cell.ConstraintHeightMsgTxt.constant = 0
            cell.loader.isHidden = true
            cell.errorBtn.isSelected = false
            cell.errorBtn.setTitle("Error", for: .normal)
            cell.errorBtn.setTitle("Retry", for: .selected)
            cell.loader.stopAnimating()
            cell.messageImgBtn.tag = indexPath.row
            cell.messageImgBtn.addTarget(self, action: #selector(showStory(_:)), for: UIControlEvents.touchUpInside)
            cell.errorBtn.tag = indexPath.row
            cell.errorBtn.addTarget(self, action: #selector(retryToUploadMedia(_:)), for: UIControlEvents.touchUpInside)
            
            if tempStory.error.count > 0  && dict.connectUserID == AppModel.shared.currentUser.uID
            {
                cell.errorBtn.isHidden = false
                
                if(tempStory.uID == AppModel.shared.currentUser.uID){
                    cell.errorBtn.isSelected = true
                }
            }
            else
            {
                //display loader
                if AppModel.shared.UPLOADING_STORY_QUEUE[tempStory.id] != nil
                {
                    cell.loader.isHidden = false
                    cell.loader.startAnimating()
                }
                
                if tempStory.type == 1 // image
                {
                    if let image = getImage(imageName: tempStory.local_url)
                    {
                        cell.messageImgBtn.setImage(nil, for: UIControlState.normal)
                        cell.messageImgBtn.setBackgroundImage(image.toFitSize(cell.messageImgBtn.frame.size, method: MGImageResizeCrop), for: UIControlState.normal)
                    }
                    
                    if(tempStory.remote_url == "")
                    {
                        if(tempStory.uID == AppModel.shared.currentUser.uID && AppModel.shared.UPLOADING_STORY_QUEUE[tempStory.id] == nil)
                        {
                            cell.errorBtn.isSelected = true
                        }
                    }
                    else
                    {
                        if let image = getImage(imageName: tempStory.local_url)
                        {
                            cell.messageImgBtn.setImage(nil, for: UIControlState.normal)
                            cell.messageImgBtn.setBackgroundImage(image.toFitSize(cell.messageImgBtn.frame.size, method: MGImageResizeCrop), for: UIControlState.normal)
                        }
                        else
                        {
                            cell.messageImgBtn.sd_setBackgroundImage(with: URL(string: tempStory.remote_url), for: UIControlState.normal,completed: { (image, error, SDImageCacheType, url) in
                                if error == nil{
                                    if tempStory.local_url.count > 0
                                    {
                                        storeImageInDocumentDirectory(image: image!, imageName: tempStory.local_url)
                                    }
                                    cell.messageImgBtn.setImage(nil, for: UIControlState.normal)
                                    cell.messageImgBtn.setBackgroundImage(image?.toFitSize(cell.messageImgBtn.frame.size, method: MGImageResizeCrop), for: UIControlState.normal)
                                }
                                
                            })
                        }
                    }
                }
                else //type 2 video
                {
                    if let image = getImage(imageName: tempStory.thumb_local_url)
                    {
                        
                        cell.messageImgBtn.setImage(UIImage.init(named: "play_button"), for: UIControlState.normal)
                        cell.messageImgBtn.setBackgroundImage(image.toFitSize(cell.messageImgBtn.frame.size, method: MGImageResizeCrop), for: UIControlState.normal)
                    }
                    
                    if (tempStory.remote_url == "" || tempStory.thumb_remote_url == "") && AppModel.shared.UPLOADING_STORY_QUEUE[tempStory.id] == nil
                    {
                        if(tempStory.uID == AppModel.shared.currentUser.uID)
                        {
                            cell.errorBtn.isSelected = true
                        }
                    }
                    else
                    {
                        if let image = getImage(imageName: tempStory.thumb_local_url)
                        {
                            
                            cell.messageImgBtn.setImage(UIImage.init(named: "play_button"), for: UIControlState.normal)
                            cell.messageImgBtn.setBackgroundImage(image.toFitSize(cell.messageImgBtn.frame.size, method: MGImageResizeCrop), for: UIControlState.normal)
                        }
                        else
                        {
                            cell.messageImgBtn.sd_setBackgroundImage(with: URL(string: tempStory.thumb_remote_url), for: UIControlState.normal,   completed: { (image, error, SDImageCacheType, url) in
                                if error == nil{
                                    if tempStory.local_url.count > 0
                                    {
                                        storeImageInDocumentDirectory(image: image!, imageName: tempStory.local_url)
                                    }
                                    cell.messageImgBtn.setImage(UIImage.init(named: "play_button"), for: UIControlState.normal)
                                    cell.messageImgBtn.setBackgroundImage(image?.toFitSize(cell.messageImgBtn.frame.size, method: MGImageResizeCrop), for: UIControlState.normal)
                                }
                            })
                        }
                    }
                }
                
                cell.messageTxtView.text = tempStory.description.decodeString
                if cell.messageTxtView.text.count > 0
                {
                    let sizeThatFitsTextView:CGSize = cell.messageTxtView.sizeThatFits(CGSize(width: tblView.frame.size.width-115, height: CGFloat(MAXFLOAT)))
                    cell.ConstraintHeightMsgTxt.constant = sizeThatFitsTextView.height
                }
            }
            cell.ConstraintHeightMessageView.constant = 170 - 35 + cell.ConstraintHeightMsgTxt.constant;
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    
    }
    
    // MARK: - TextView delegate
    func textViewDidChange(_ textView: UITextView)
    {
        if textView == msgTextView
        {
            if msgTextView.contentSize.height > 70 {
                constraintHeightMsgTextView.constant = 70 + 25
            }
            else
            {
                constraintHeightMsgTextView.constant = msgTextView.contentSize.height + 25
            }
            setTblViewHeight()
        }
    }
    
    func scrollTableviewToBottom()
    {
        if self.tblView != nil &&  self.messages.count > 0
        {
            self.tblView.scrollToRow(at: IndexPath(item: self.tblView.numberOfRows(inSection: 0) - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    
    func setTblViewHeight()
    {
        constraintHeightTblView.constant = self.view.frame.size.height - (64 + 65 + constraintHeightMsgTextView.constant)
        scrollTableviewToBottom()
    }
    
    @IBAction func retryToUploadMedia(_ sender: UIButton)
    {
        if sender.isSelected == true
        {
            let msgModel : MessageModel = messages[sender.tag]
            //uploadChatingMedia(msgModel: msgModel, msgIndex: sender.tag)
            
            
            if let tempStory = AppModel.shared.STORY[msgModel.storyID]
            {
                AppDelegate().sharedDelegate().uploadStory(story: tempStory, msg: msgModel)
                
                self.tblView.beginUpdates()
                self.tblView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: UITableViewRowAnimation.automatic)
                self.tblView.endUpdates()
            }
        }
    }
    
    //MARK: - Story Image Video Display
    @IBAction func showStory(_ sender: UIButton)
    {
        let dict : MessageModel = messages[sender.tag]
        if let tempStory = AppModel.shared.STORY[dict.storyID]
        {
            if tempStory.type == 1 // image
            {
                let imgView : UIImageView = UIImageView.init(frame: self.view.frame)
                imgView.contentMode = UIViewContentMode.scaleAspectFit
                videoPlayView.addSubview(imgView)
                videoPlayView.bringSubview(toFront: closeVideoPlayViewBtn)
                if let image = getImage(imageName: tempStory.local_url)
                {
                    imgView.image = image
                }
                else
                {
                    if tempStory.remote_url != ""
                    {
                        DispatchQueue.main.async {
                            displayLoader()
                        }
                        
                        imgView.sd_setImage(with: URL(string: tempStory.remote_url), completed: { (image, error, SDImageCacheType, url) in
                            DispatchQueue.main.async {
                                if error == nil{
                                    imgView.image = image
                                }
                                removeLoader()
                            }
                        })
                    }
                    else
                    {
                        displayErrorAlertView(title: "Error", message: "Image Not Available")
                        return
                    }
                }
                displaySubViewtoParentView(self.view, subview: videoPlayContainerView)
            }
            else //video
            {
                DispatchQueue.main.async {
                    let vc : DisplayStoryVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayStoryVC") as! DisplayStoryVC
                    vc.selectedStory = tempStory
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func closeVideoView(_ sender: Any)
    {
        DispatchQueue.main.async {
            removeLoader()
        }
        
        for subview in videoPlayView.subviews {
            subview.removeFromSuperview()
        }
        
        videoPlayContainerView.removeFromSuperview()
        
    }
    
    
    //MARK: - Custom Popup
    func openCustomPopup()
    {
        CustomPopUp = self.storyboard?.instantiateViewController(withIdentifier: "customPopUp") as! customPopUp
        CustomPopUp.delegate = self
        self.view.addSubview(CustomPopUp.view)
        let popupSize: CGFloat = CustomPopUp.popupView.frame.size.width
        CustomPopUp.removeView.isHidden = true
        CustomPopUp.constraintWidthCameraView.constant = popupSize / 2
        CustomPopUp.constraintWidthGalleryView.constant = popupSize / 2
        CustomPopUp.constraintWidthRemoveImageView.constant = 0
        
        displaySubViewtoParentView(self.view, subview: CustomPopUp.view)
        
        CustomPopUp.view.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.55, initialSpringVelocity: 1.0, options: [], animations: {() -> Void in
            self.CustomPopUp.view.transform = CGAffineTransform.identity
        }, completion: {(_ finished: Bool) -> Void in
        })
    }
    
    func closeToClick()
    {
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
            self.CustomPopUp.view.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
            self.CustomPopUp.view.alpha = 0.0
        }, completion: {(_ finished: Bool) -> Void in
            self.CustomPopUp.view.removeFromSuperview()
        })
    }
    
    func captureCameraImage()
    {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displayToast("Your device has no camera")
            CustomPopUp.view.removeFromSuperview()
        }
        else {
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .camera
            self.present(imgPicker, animated: true, completion: {() -> Void in
            })
            CustomPopUp.view.removeFromSuperview()
        }
    }
    
    func selectGalleryImage()
    {
        CustomPopUp.view.removeFromSuperview()
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = .photoLibrary
        imgPicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.present(imgPicker, animated: true, completion: {() -> Void in
        })
    }
    
    func removeImage()
    {
        
    }
    
    func imagePickerController(_ imgPicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Picking Image from Camera/ Library
        imgPicker.dismiss(animated: true, completion: {() -> Void in
        })
        CustomPopUp.view.removeFromSuperview()
        
        if let selectedImage: UIImage = (info["UIImagePickerControllerOriginalImage"] as? UIImage)
        {
            let controller = PECropViewController()
            controller.delegate = self as PECropViewControllerDelegate
            controller.image = selectedImage
            controller.keepingCropAspectRatio = false
            controller.toolbarHidden = true
            let width: CGFloat? = selectedImage.size.width
            let height: CGFloat? = selectedImage.size.height
            let length: CGFloat = min(width!, height!)
            controller.imageCropRect = CGRect(x: CGFloat((width! - length) / 2), y: CGFloat((height! - length) / 2), width: length, height: length)
            let navigationController = UINavigationController(rootViewController: controller)
            self.present(navigationController, animated: true, completion: { _ in })
        }
        else if let videoURL = info[UIImagePickerControllerMediaURL] as? URL
        {
            //print(videoURL)
            
            let videoName : String = getCurrentTimeStampValue()
            storeVideoInDocumentDirectory(videoUrl: videoURL, videoName: videoName)
            
            let newStory : StoryModel = StoryModel.init(id: getCurrentTimeStampValue(), uID: AppModel.shared.currentUser.uID, local_url: videoName, remote_url: "", thumb_local_url: "", thumb_remote_url: "", date: getCurrentDateInString(), description: "", type: 2, error: "")
            
            let newMsgModel: MessageModel = MessageModel.init(msgID: getCurrentTimeStampValue(), key: "", connectUserID: self.receiver.uID, date: getCurrentDateInString(), text: "", storyID : newStory.id, status:1)
            
            let newMsgRef : DatabaseReference = self.messagesRef.childByAutoId()
            newMsgModel.key = newMsgRef.key
            newMsgRef.setValue(newMsgModel.dictionary())
            
            
            
            displayLoader()
            AppDelegate().sharedDelegate().window?.isUserInteractionEnabled = false
            displayToast("Compressing video...")
            compressLocalVideo(videoName, completionHandler: { (expSession) in
                
                removeLoader()
                AppDelegate().sharedDelegate().window?.isUserInteractionEnabled = true
                
                if(expSession != nil && expSession.outputURL != nil){
                    storeVideoInDocumentDirectory(videoUrl: expSession.outputURL!, videoName: videoName)
                }
                AppDelegate().sharedDelegate().uploadStory(story: newStory, msg: newMsgModel)
                self.addMessage(newMsgModel)
                self.newSendMessagesArr[newMsgModel.msgID] = true
            })
        }
    }
    
    func cropViewController(_ controller: PECropViewController, didFinishCroppingImage croppedImage: UIImage) {
        controller.dismiss(animated: true, completion: { _ in })
        // Adjusting Image Orientation
        
        let imgCompress: UIImage? = compressImage(croppedImage, to: CGSize(width: CGFloat(IMAGESIZE.IMAGE_WIDTH), height: CGFloat(IMAGESIZE.IMAGE_HEIGHT)))
        uploadImage = imgCompress
        openSendImageContainerView()
    }
    
    func cropViewControllerDidCancel(_ controller: PECropViewController) {
        controller.dismiss(animated: true, completion: { _ in })
    }
    
    func openSendImageContainerView()
    {
        
        receiverImgBtn.addCornerRadius(radius: receiverImgBtn.frame.size.width/2)
        
        AppDelegate().sharedDelegate().setUserProfileImage(receiver.uID, button: receiverImgBtn)
        
        sendImgView.image = uploadImage
        displaySubViewtoParentView(self.view, subview: sendImageContainerVIew)
    }
    
    @IBAction func clickToCloseImageContainerView(_ sender: Any)
    {
        sendImageContainerVIew.removeFromSuperview()
    }
    
    
    @IBAction func clickToSendImage(_ sender: Any)
    {
        self.view.endEditing(true)
        sendImageContainerVIew.removeFromSuperview()
        
        let imgName : String = getCurrentTimeStampValue()
        storeImageInDocumentDirectory(image: uploadImage, imageName: imgName)
        
        let newStory : StoryModel = StoryModel.init(id: getCurrentTimeStampValue(), uID: AppModel.shared.currentUser.uID, local_url: imgName, remote_url: "", thumb_local_url: "", thumb_remote_url: "", date: getCurrentDateInString(), description: imageAddCaptionTxt.text!.encodeString, type: 1, error: "")
        
        let newMsgModel: MessageModel = MessageModel.init(msgID: getCurrentTimeStampValue(), key: "", connectUserID: receiver.uID, date: getCurrentDateInString(), text: "", storyID : newStory.id, status:1)
        
        let newMsgRef : DatabaseReference = self.messagesRef.childByAutoId()
        newMsgModel.key = newMsgRef.key
        newMsgRef.setValue(newMsgModel.dictionary())
        
        AppDelegate().sharedDelegate().uploadStory(story: newStory, msg: newMsgModel)
        addMessage(newMsgModel)
        newSendMessagesArr[newMsgModel.msgID] = true
        imageAddCaptionTxt.text = ""
    }

    func updateMessgaeInCoreData()
    {
        
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


/*
 func fetchCoreDataMessages1()
 {
 guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
 return
 }
 
 let managedContext = appDelegate.persistentContainer.viewContext
 
 let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: COREDATA.MESSAGE.TABLE_NAME)
 fetchRequest.predicate = NSPredicate(format: "channeld == %@",channelId)
 do {
 let messagesArr: [NSManagedObject] = try managedContext.fetch(fetchRequest)
 
 for msg in messagesArr
 {
 if AppModel.shared.STORY[msg.value(forKey: "storyID") as! String] != nil
 {
 let tempMsg : MessageModel = MessageModel.init(msgID: msg.value(forKey: COREDATA.MESSAGE.msgID) as! String, key: msg.value(forKey: COREDATA.MESSAGE.key) as! String, connectUserID: msg.value(forKey: COREDATA.MESSAGE.connectUserID) as! String, date: msg.value(forKey: COREDATA.MESSAGE.date) as! String, text: msg.value(forKey: COREDATA.MESSAGE.text) as! String, storyID: msg.value(forKey: COREDATA.MESSAGE.storyID) as! String, status: msg.value(forKey: COREDATA.MESSAGE.status) as! Int)
 messages.append(tempMsg)
 coreDataMsgDict[tempMsg.msgID] = true
 }
 else
 {
 managedContext.delete(msg)
 }
 }
 sortAllMessages()
 self.setTblViewHeight()
 } catch let error as NSError {
 print("Could not fetch. \(error), \(error.userInfo)")
 }
 fetchFirebaseMessages()
 onUpdateFirebaseMessages()
 }*/
