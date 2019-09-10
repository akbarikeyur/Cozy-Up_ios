//
//  CreateNewGameEventTrainingVC.swift
//  Check-Up
//
//  Created by Amisha on 17/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import GooglePlacePicker

class CreateNewGameEventTrainingVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, GMSPlacePickerViewControllerDelegate {

    @IBOutlet weak var createEditLbl: UILabel!
    @IBOutlet var gameTypeBtn: UIButton!
    @IBOutlet var eventTypeBtn: UIButton!
    @IBOutlet var trainingTypeBtn: UIButton!
    @IBOutlet var titleTxt: UITextField!
    @IBOutlet weak var locationTxt: UITextField!
    @IBOutlet var dateTimeLbl: UILabel!
    @IBOutlet var totalMemberLbl: UILabel!
    @IBOutlet var memberCollectionView: UICollectionView!
    @IBOutlet var admissionFreeBtn: UIButton!
    @IBOutlet var admissionFeeBtn: UIButton!
    @IBOutlet var privacyPublicBtn: UIButton!
    @IBOutlet var privacyPrivateBtn: UIButton!
    @IBOutlet var decriptionTxtView: UITextView!
    @IBOutlet weak var findGooglePlaceBtn: UIButton!
    
    @IBOutlet var addPlayerContainerView: UIView!
    @IBOutlet var addPlayerPopupView: UIView!
    @IBOutlet var addPlayerPopupTitleLbl: UILabel!
    @IBOutlet var addPlayerTblView: UITableView!
    @IBOutlet var constraintHeightAddPlayerPopupView: NSLayoutConstraint!
    @IBOutlet var addPlayerCancelBtn: UIButton!
    @IBOutlet var addPlayerOkBtn: UIButton!
    @IBOutlet weak var constraintHeightSearchPlayerView: NSLayoutConstraint!
    @IBOutlet weak var searchPlayerTxt: UITextField!
    
    @IBOutlet var datePickerContainerView: UIView!
    @IBOutlet var datePickerPopupView: UIView!
    @IBOutlet var datePickerPoupTitleLbl: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var datePickerCancelBtn: UIButton!
    
    @IBOutlet var searchLocationContainerView: UIView!
    @IBOutlet var searchLocationTxt: UITextField!
    @IBOutlet var searchLocationCancelBtn: UIButton!
    @IBOutlet var searchLocationTblView: UITableView!
    
    @IBOutlet var searchCourtContainerView: UIView!
    @IBOutlet weak var searchCourtPopupView: UIView!
    @IBOutlet weak var searchCourtTblView: UITableView!
    @IBOutlet weak var searchCourtTxt: UITextField!
    @IBOutlet weak var constraintHeightSearchCourtView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightSearchCourtTextView: NSLayoutConstraint!
    
    @IBOutlet var datePickerOkBtn: UIButton!
    
    var arrMemberData = [UserModel]()
    var arrSearchMemberData = [UserModel]()
    var arrSelectedMemberData = [UserModel]()
    var arrTempSelectedMemberData:[String:UserModel] = [String:UserModel]()
    
    var arrLocationData:[LocationModel] = [LocationModel]()
    var arrSearchLocationData:[LocationModel] = [LocationModel]()
    
    var isMinTime : Bool = false
    var isMaxTime : Bool = false

    var minTimeSelected : Date!
    var maxTimeSelected : Date!
    var selectedLocation : LocationModel!
    
    
    var eventModel : EventModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(noti:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateAllUser), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
        
        memberCollectionView.delegate = self
        memberCollectionView.dataSource = self
        memberCollectionView.register(UINib.init(nibName: "CustomUserStoryCVC", bundle: nil), forCellWithReuseIdentifier: "CustomUserStoryCVC")
        
        addPlayerTblView.register(UINib.init(nibName: "CustomAddFriendTVC", bundle: nil), forCellReuseIdentifier: "CustomAddFriendTVC")
        addPlayerTblView.backgroundColor = UIColor.clear
        addPlayerTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        addPlayerTblView.tableFooterView = UIView(frame: CGRect.zero)

        searchLocationTblView.register(UINib.init(nibName: "customAddressTVC", bundle: nil), forCellReuseIdentifier: "customAddressTVC")
        searchLocationTblView.backgroundColor = UIColor.clear
        searchLocationTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        searchLocationTblView.tableFooterView = UIView(frame: CGRect.zero)
        
        searchCourtTblView.register(UINib.init(nibName: "customAddressTVC", bundle: nil), forCellReuseIdentifier: "customAddressTVC")
        searchCourtTblView.backgroundColor = UIColor.clear
        searchCourtTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        searchCourtTblView.tableFooterView = UIView(frame: CGRect.zero)
        
        totalMemberLbl.text = String(format: "(%d)", arrSelectedMemberData.count)
        
        if selectedLocation != nil && selectedLocation.address.count > 0
        {
            locationTxt.text = selectedLocation.address
        }
        
        
        
        if eventModel != nil
        {
            setEventDataValue()
        }
        onUpdateAllUser()
    }
    func onUpdateAllUser(){
        
        arrMemberData = [UserModel]()
        for i in 0..<AppModel.shared.USERS.count
        {
            let index = AppModel.shared.currentUser.contact.index(where: { (contact) -> Bool in
                contact.id == AppModel.shared.USERS[i].uID && contact.requestAction == 3
            })
            if index != nil {
                if(AppDelegate().sharedDelegate().isBlockUser(AppModel.shared.USERS[i].uID)){
                    
                }
                else{
                    arrMemberData.append(AppModel.shared.USERS[i])
                }
            }
        }
        
        arrSearchMemberData = [UserModel]()
        for userModel : UserModel in arrMemberData
        {
            if userModel.name.lowercased().contains((searchPlayerTxt.text?.lowercased())!)
            {
                arrSearchMemberData.append(userModel)
            }
        }
        
        arrSelectedMemberData = [UserModel]()
        if(eventModel != nil){
            for i in 0..<eventModel!.players.count
            {
                let index = AppModel.shared.USERS.index(where: { (tempUser) -> Bool in
                    tempUser.uID == eventModel!.players[i].id
                })
                
                if index != nil
                {
                    arrSelectedMemberData.append(AppModel.shared.USERS[index!])
                }
            }
        }
        for user in arrTempSelectedMemberData{
            if(AppDelegate().sharedDelegate().isBlockUser(user.key)){
                arrTempSelectedMemberData[user.key] = nil
            }
            else{
                let index = arrSelectedMemberData.index(where: { (tempUser) -> Bool in
                    tempUser.uID == user.key
                })
                
                if index == nil
                {
                    arrSelectedMemberData.append(user.value)
                }
            }
        }
        totalMemberLbl.text = String(format: "(%d)", arrSelectedMemberData.count)
        
        setPlayerTableHeight()
        memberCollectionView.reloadData()
    }
    
    func setEventDataValue()
    {
        if eventModel != nil
        {
            createEditLbl.text = "EDIT:"
            gameTypeBtn.isSelected = false
            eventTypeBtn.isSelected = false
            trainingTypeBtn.isSelected = false
            switch eventModel!.type {
            case 1:
                gameTypeBtn.isSelected = true
                break
            case 2:
                eventTypeBtn.isSelected = true
                break
            case 3:
                trainingTypeBtn.isSelected = true
                break
            default:
                break
            }
            
            titleTxt.text = eventModel!.title
            selectedLocation = eventModel!.location
            locationTxt.text = selectedLocation.address
            
            minTimeSelected = getDateTimeFromFCM(eventModel!.minDate)
            maxTimeSelected = getDateTimeFromFCM(eventModel!.maxDate)
            
            
            let format = DateFormatter()
            format.dateFormat = "EEEE " + FORMAT.DISPLAY_TIME
            dateTimeLbl.text = format.string(from: minTimeSelected)
            
            format.dateFormat = FORMAT.DISPLAY_TIME
            dateTimeLbl.text = dateTimeLbl.text! + " to " + format.string(from: maxTimeSelected)
            
            arrSelectedMemberData = [UserModel]()
            for i in 0..<eventModel!.players.count
            {
                let index = AppModel.shared.USERS.index(where: { (tempUser) -> Bool in
                    tempUser.uID == eventModel!.players[i].id
                })
                
                if index != nil
                {
                    arrSelectedMemberData.append(AppModel.shared.USERS[index!])
                }
            }
            
            totalMemberLbl.text = String(format: "(%d)", arrSelectedMemberData.count)
            
            admissionFreeBtn.isSelected = false
            admissionFeeBtn.isSelected = false
            
            switch eventModel!.admissionType {
            case 1:
                admissionFreeBtn.isSelected = true
                break
            case 2:
                admissionFeeBtn.isSelected = true
                break
            default:
                break
            }
            
            switch eventModel!.privacyType {
            case 1:
                privacyPublicBtn.isSelected = true
            case 2:
                privacyPrivateBtn.isSelected = true
            default:
                break
            }
            
            decriptionTxtView.text = eventModel!.description
        }
    }
    
    // MARK: - Button click event
    
    @IBAction func clickToSelectType(_ sender: UIButton)
    {
        self.view.endEditing(true)
        gameTypeBtn.isSelected = false
        eventTypeBtn.isSelected = false
        trainingTypeBtn.isSelected = false
        if sender == gameTypeBtn
        {
            gameTypeBtn.isSelected = true
        }
        else if sender == eventTypeBtn
        {
            eventTypeBtn.isSelected = true
        }
        else if sender == trainingTypeBtn
        {
            trainingTypeBtn.isSelected = true
        }
    }
    
    @IBAction func clickToSelectLocaion(_ sender: UIButton)
    {
        self.view.endEditing(true)
        //openSearchLocationView()
        
        arrLocationData = [LocationModel] ()
        
        for locationModel in AppModel.shared.PRELOCATED_COURTS{
            arrLocationData.append(locationModel)
        }
        for eventModel in AppModel.shared.EVENTS{
            let index = arrLocationData.index { (locationModel) -> Bool in
                eventModel.location.id == locationModel.id
            }
            if(index == nil){
                arrLocationData.append(eventModel.location)
            }
            else{
                arrLocationData[index!] = eventModel.location
            }
        }
        for courtModel in AppModel.shared.COURTS{
            let index = arrLocationData.index { (locationModel) -> Bool in
                courtModel.location.id == locationModel.id
            }
            if(index == nil){
                arrLocationData.append(courtModel.location)
            }
            else{
                arrLocationData[index!] = courtModel.location
            }
        }
        
        openSearchCourtView()
    }
    @IBAction func clickToSelectAdmissionType(_ sender: UIButton)
    {
        self.view.endEditing(true)
        admissionFreeBtn.isSelected = false
        admissionFeeBtn.isSelected = false
        if sender == admissionFreeBtn
        {
            admissionFreeBtn.isSelected = true
        }
        else
        {
            admissionFeeBtn.isSelected = true
        }
    }
    
    @IBAction func clickToSelectPrivacy(_ sender: UIButton)
    {
        self.view.endEditing(true)
        privacyPublicBtn.isSelected = false
        privacyPrivateBtn.isSelected = false
        if sender == privacyPublicBtn
        {
            privacyPublicBtn.isSelected = true
        }
        else
        {
            privacyPrivateBtn.isSelected = true
        }
    }
    
    @IBAction func clickToAddMember(_ sender: UIButton)
    {
        self.view.endEditing(true)
        OpenDialogForAddPlayers()
    }
    
    @IBAction func clickToSelectDateTime(_ sender: Any)
    {
        self.view.endEditing(true)
        openDatePickerDialog()
    }
    
    @IBAction func clickToBack(_ sender: UIButton)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToSubmit(_ sender: Any)
    {
        if titleTxt.text?.count == 0 {
            displayToast(NSLocalizedString("enter_title", comment: ""))
        }
        else if locationTxt.text?.count == 0 {
            displayToast(NSLocalizedString("enter_location", comment: ""))
        }
        else if dateTimeLbl.text?.count == 0 {
            displayToast(NSLocalizedString("enter_time", comment: ""))
        }
//        else if arrMemberData.count == 0 {
//            displayToast(view: self.view, message: NSLocalizedString("add_member", comment: ""))
//        }
        else if decriptionTxtView.text?.count == 0 {
            displayToast(NSLocalizedString("enter_description", comment: ""))
        }
        else
        {
            var type : Int = 0
            if gameTypeBtn.isSelected == true {
                type = 1
            }
            else if eventTypeBtn.isSelected == true {
                type = 2
            }
            else if trainingTypeBtn.isSelected == true {
                type = 3
            }
            
            var admission : Int = 0
            if admissionFreeBtn.isSelected == true {
                admission = 1
            }
            else if admissionFeeBtn.isSelected == true {
                admission = 2
            }
            
            var privacy : Int = 0
            if privacyPublicBtn.isSelected == true {
                privacy = 1
            }
            else if privacyPrivateBtn.isSelected == true {
                privacy = 2
            }
            
            var member = [ContactModel]()
            for i in 0..<arrSelectedMemberData.count
            {
                if(eventModel != nil){
                    let index = eventModel!.players.index(where: { (temp) -> Bool in
                        temp.id == arrSelectedMemberData[i].uID
                    })
                    if(index != nil){
                        member.append(eventModel!.players[index!])
                    }
                    else{
                        let dictTemp : UserModel = arrSelectedMemberData[i]
                        member.append(ContactModel.init(id: dictTemp.uID, requestAction: 1))
                    }
                }
                else{
                    let dictTemp : UserModel = arrSelectedMemberData[i]
                    member.append(ContactModel.init(id: dictTemp.uID, requestAction: 1))
                }
            }
            
            if eventModel == nil // New Event
            {
                AppDelegate().sharedDelegate().createEvent(EventModel.init(id: "", uID: AppModel.shared.currentUser.uID, type: type, title: titleTxt.text!, location: selectedLocation, minDate: sendDateTimeToFCM(minTimeSelected), maxDate: sendDateTimeToFCM(maxTimeSelected), players: member, admissionType: admission, privacyType: privacy, description: decriptionTxtView.text, is_notify:0, is_start_notify:0,comment: [CommentModel]()))
                
            }
            else //Update Event
            {
                AppDelegate().sharedDelegate().updateEvent(eventModel!, updatedEvent: EventModel.init(id: eventModel!.id, uID: AppModel.shared.currentUser.uID, type: type, title: titleTxt.text!, location: selectedLocation, minDate: sendDateTimeToFCM(minTimeSelected), maxDate: sendDateTimeToFCM(maxTimeSelected), players: member, admissionType: admission, privacyType: privacy, description: decriptionTxtView.text,is_notify:eventModel!.is_notify, is_start_notify:eventModel!.is_start_notify, comment: eventModel!.comment))
            }
            
            _ = self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_REDIRECT_EVENT_MAP), object: selectedLocation)
        }
    }
    
    // MARK: - Collectionview Delaget methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrSelectedMemberData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : CustomUserStoryCVC = memberCollectionView.dequeueReusableCell(withReuseIdentifier: "CustomUserStoryCVC", for: indexPath) as! CustomUserStoryCVC
        
        let dict:UserModel = arrSelectedMemberData[indexPath.row]
        
        cell.profilePicBtn.addCornerRadius(radius: cell.profilePicBtn.frame.width/2)
        cell.profilePicBtn.setBackgroundImage(nil, for: UIControlState.normal)
        AppDelegate().sharedDelegate().setUserProfileImage(dict.uID, button: cell.profilePicBtn)
        
        
        cell.userNameDarkLbl.text = dict.name!
        cell.userNameLbl.isHidden = true
        cell.userNameDarkLbl.isHidden = false
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == searchCourtTblView {
            return ((searchCourtTxt.text?.count)! == 0) ? arrLocationData.count : arrSearchLocationData.count
        }
        else if tableView == searchLocationTblView {
            return arrLocationData.count
        }
        return ((searchPlayerTxt.text?.count)! == 0) ? arrMemberData.count : arrSearchMemberData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == searchCourtTblView {
            return 55
        }
        else if tableView == searchLocationTblView {
            return 55
        }
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == searchCourtTblView {
            let cell : customAddressTVC = searchCourtTblView.dequeueReusableCell(withIdentifier: "customAddressTVC", for: indexPath) as! customAddressTVC
            
            let locationModel : LocationModel = (((searchCourtTxt.text?.count)! == 0) ? arrLocationData : arrSearchLocationData)[indexPath.row]
            cell.titleLbl.text = locationModel.name
            cell.addressLbl.text = locationModel.address
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else if tableView == searchLocationTblView {
            let cell : customAddressTVC = searchLocationTblView.dequeueReusableCell(withIdentifier: "customAddressTVC", for: indexPath) as! customAddressTVC
            
            let locationModel : LocationModel = arrLocationData[indexPath.row]
            cell.titleLbl.text = locationModel.name
            cell.addressLbl.text = locationModel.address
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else
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
            cell.addBtn.addTarget(self, action: #selector(clickToAddFriend(_:)), for: UIControlEvents.touchUpInside)
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == searchCourtTblView {
            selectedLocation = (((searchCourtTxt.text?.count)! == 0) ? arrLocationData : arrSearchLocationData)[indexPath.row]
            searchCourtContainerView.removeFromSuperview()
            locationTxt.text = selectedLocation.address
        }
        else
        {
            
        }
    }
    
    @IBAction func clickToAddFriend(_ sender: UIButton)
    {
        self.view.endEditing(true)
        
        let dict : UserModel =  (((searchPlayerTxt.text?.count)! == 0) ? arrMemberData : arrSearchMemberData)[sender.tag]
        
        let index = arrSelectedMemberData.index(where: { (userModel) -> Bool in
            userModel.uID == dict.uID
        })
        if(index == nil){
            if(AppDelegate().sharedDelegate().isBlockMe(dict)){
                arrTempSelectedMemberData[dict.uID] = nil
                displayToast("Opps, " + dict.name + " has blocked you.")
            }
            else{
                arrSelectedMemberData.append(dict)
                arrTempSelectedMemberData[dict.uID] = dict
            }
        }
        else{
            arrSelectedMemberData.remove(at: index!)
            arrTempSelectedMemberData[dict.uID] = nil
        }
        
        totalMemberLbl.text = String(format: "(%d)", arrSelectedMemberData.count)
        addPlayerTblView.reloadData()
        memberCollectionView.reloadData()
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
        
       
        setPlayerTableHeight()
        displaySubViewtoParentView(self.view, subview: addPlayerContainerView)
        
    }
    
    @IBAction func clickToAddPlayerDoneBtn(_ sender: Any)
    {
        addPlayerContainerView.removeFromSuperview()
    }
    
    @IBAction func clickToAddPlayerCancelBtn(_ sender: Any)
    {
        addPlayerContainerView.removeFromSuperview()
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
    
    //MARK: - Date Picker
    func openDatePickerDialog()
    {
        datePickerPopupView.addCornerRadiusOfView(radius: 10.0)
        datePickerOkBtn.addCornerRadiusOfView(radius: 5.0)
        datePickerCancelBtn.addCornerRadiusOfView(radius: 5.0)
        
        isMinTime = true
        isMaxTime = false
        
        datePicker.minimumDate = Date()
        datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        if minTimeSelected == nil {
            minTimeSelected = Date()
        }
        datePicker.setDate(minTimeSelected, animated: true)
        datePickerPoupTitleLbl.text = "SELECT START DATE"
        displaySubViewtoParentView(self.view, subview: datePickerContainerView)
    }
    
    
    @IBAction func clickToDatePickerOkBtn(_ sender: Any)
    {
        if isMinTime == true {
            isMinTime = false
            isMaxTime = true
            minTimeSelected = datePicker.date
            
            datePicker.datePickerMode = UIDatePickerMode.dateAndTime
            if maxTimeSelected == nil {
                maxTimeSelected = minTimeSelected
            }
            datePicker.minimumDate = minTimeSelected
            datePicker.setDate(maxTimeSelected, animated: true)
            datePickerPoupTitleLbl.text = "SELECT END DATE"
        }
        else if isMaxTime == true
        {
            isMinTime = false
            isMaxTime = false
            maxTimeSelected = datePicker.date
            datePickerContainerView.removeFromSuperview()
            
            let format = DateFormatter()
            format.dateFormat = "EEEE " + FORMAT.DISPLAY_TIME
            dateTimeLbl.text = format.string(from: minTimeSelected)
            
            format.dateFormat = FORMAT.DISPLAY_TIME
            dateTimeLbl.text = dateTimeLbl.text! + " to " + format.string(from: maxTimeSelected)
            
        }
        
    }
    
    @IBAction func clickToDatePickerCancelBtn(_ sender: UIButton)
    {
        if isMinTime == true || isMaxTime == true
        {
            minTimeSelected = Date()
            maxTimeSelected = Date()
        }
        datePickerContainerView.removeFromSuperview()
    }
    
    
    
    // MARK: - Search Location View
    
    func openSearchCourtView()
    {
        searchCourtPopupView.addCornerRadiusOfView(radius: 10.0)
        searchCourtTxt.addCornerRadiusOfView(radius: 10)
        searchCourtTxt.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR, alpha: 0.5))
        searchCourtTxt.addPadding(padding: 5)
        
        setCourtTableHeight()
        displaySubViewtoParentView(self.view, subview: searchCourtContainerView)
    }
    
    func setCourtTableHeight()
    {
        searchCourtTblView.reloadData()
        if (searchCourtTblView.contentSize.height+50) > (SCREEN.HEIGHT - 100) {
            constraintHeightSearchCourtTextView.constant = 50
            constraintHeightSearchCourtView.constant = SCREEN.HEIGHT - 100
        }
        else{
            constraintHeightSearchCourtTextView.constant = 50
            constraintHeightSearchCourtView.constant = searchCourtTblView.contentSize.height + constraintHeightSearchCourtTextView.constant + 50
        }
    }
    
    @IBAction func clickToCloseSearchCourtView(_ sender: Any)
    {
        searchCourtContainerView.removeFromSuperview()
        findGooglePlaceBtn.isSelected = false
    }
    
    func textFieldDidChange(noti : Notification)
    {
        let textField : UITextField = noti.object as! UITextField
        if textField == searchCourtTxt
        {
            arrSearchLocationData = [LocationModel]()
            for locationModel : LocationModel in arrLocationData
            {
                //print(locationModel.name)
                if locationModel.name.lowercased().contains((searchCourtTxt.text?.lowercased())!)
                {
                    arrSearchLocationData.append(locationModel)
                }
            }
            setCourtTableHeight()
        }
        else if textField == searchPlayerTxt
        {
            onUpdateAllUser()
        }
    }
    
    @IBAction func clickToFindInGooglePlacePicker(_ sender: Any)
    {
        searchCourtTxt.text = ""
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        let alertConfirmation = UIAlertController(title: "Check-Up", message: "Create new court?", preferredStyle: UIAlertControllerStyle.alert)
        alertConfirmation.addTextField { (textField : UITextField!) -> Void in
            textField.text = place.name
        }
        let placeNameTxt = alertConfirmation.textFields![0] as UITextField
        
        let urlString : String = String(format: API.PLACE_DETAIL, place.placeID)
        //print(urlString)
        Alamofire.request(urlString, method: .post, parameters: ["" : ""],encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success:
                
                if let JSON = response.result.value as? [String:Any]
                {
                    if let item = JSON["result"] as? [String:Any]
                    {
                        //print(item)
                        let id = item["id"] as! String
                        let address = item["formatted_address"] as! String
                        let lat = ((item["geometry"] as! [String:Any])["location"] as! [String:Any])["lat"] as! Float
                        let long = ((item["geometry"] as! [String:Any])["location"] as! [String:Any])["lng"] as! Float
                        
                        var img_url = ""
                        if item["photos"] != nil
                        {
                            let photoArr : [AnyObject] = (item["photos"] as? [AnyObject])!
                            let photoDict = photoArr[0] as! [String : AnyObject]
                            img_url = String(format: API.GOOGLE_IMAGE, photoDict["photo_reference"] as! String)
                        }
                        
//                        if img_url == ""
//                        {
//                            img_url = AppModel.shared.currentUser.remote_pic_url
//                        }
                        
                        var isOpen:Bool = true
                        if item["opening_hours"] != nil
                        {
                            isOpen = (item["opening_hours"] as! [String : AnyObject])["open_now"] as! Bool
                        }
                        
                        let index = AppModel.shared.COURTS.index(where: { (court) -> Bool in
                            id == court.location.id
                        })
                        
                        if(index == nil){
                          
                             let noAction = UIAlertAction (title: "NO", style: UIAlertActionStyle.cancel, handler: nil)
                            
                             let yesAction = UIAlertAction(title: "YES", style: .default) { (action) in
                                self.selectedLocation = LocationModel.init(id: id, name: placeNameTxt.text!, image: img_url, address: address, latitude: lat, longitude: long, isOpen: isOpen)
                                self.locationTxt.text = self.selectedLocation.address
                            }
                            
                            
                            
                            alertConfirmation.addAction(noAction)
                            alertConfirmation.addAction(yesAction)
                            
                            self.present(alertConfirmation, animated: true, completion: nil)
                        }
                        else{
                            self.selectedLocation = AppModel.shared.COURTS[index!].location
                            self.locationTxt.text = self.selectedLocation.address
                        }
                    }
                }
                break
            case .failure(let error):
                
                print(error)
                break
            }
        }
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        //print("No place selected")
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

