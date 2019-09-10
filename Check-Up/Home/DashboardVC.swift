
//
//  DashboardVC.swift
//  Check-Up
//
//  Created by Amisha on 10/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage
import GoogleMaps
import Alamofire
import MobileCoreServices
import GooglePlaces
import GooglePlacePicker
import Firebase
import FirebaseAuth
import FirebaseDatabase

class DashboardVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, GMSMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, GMSPlacePickerViewControllerDelegate {
    
    @IBOutlet var yourStoryBtn: UIButton!
    @IBOutlet var userProfileBtn: UIButton!
    @IBOutlet var checkupBtn: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchCourtView: UIView!
    @IBOutlet var searchCourtTxt: UITextField!
    @IBOutlet weak var searchCourtTblView: UIView!
    @IBOutlet weak var searchTbl: UITableView!
    @IBOutlet var courtMapView: GMSMapView!
    @IBOutlet weak var unreadNotificationBtn: UIButton!
    
    @IBOutlet var checkupContainerView: UIView!
    @IBOutlet var checkUpTopPopupView: UIView!
    @IBOutlet var checkUpBottomPopupView: UIView!
    @IBOutlet var checkUpPopupProfilePicBtn: UIButton!
    @IBOutlet var checkUpPopupProfileBtnView: UIView!
    @IBOutlet var checkUpPoupupUserBottomView: UIView!
    @IBOutlet var constraintHeightCheckUpPopupBottomView: NSLayoutConstraint!
    @IBOutlet var constraintHeightCheckUpPopupView: NSLayoutConstraint!
    
    @IBOutlet weak var checkupNameLbl: UILabel!
    @IBOutlet weak var checkupUsernameLbl: UILabel!
    @IBOutlet weak var checkupAgeLbl: UILabel!
    @IBOutlet weak var checkupHeightLbl: UILabel!
    @IBOutlet weak var checkupPositionLbl: UILabel!
    @IBOutlet weak var checkupLocationLbl: UILabel!
    @IBOutlet weak var checkupCheckInLbl: UILabel!
    
    @IBOutlet weak var checkupCourtPicBtn: UIButton!
    @IBOutlet weak var checkupCourtNameLbl: UILabel!
    @IBOutlet weak var checkupCourtLocationLbl: UILabel!
    @IBOutlet weak var checkupCourtMemberLbl: UILabel!

    var arrUserStoryData = [UserModel]()
    var arrCourtData:[AppModel]! = [AppModel]() //prelocated Courts + events + Courts
    var arrSearchCourtData = [AppModel] ()
    var selectedCourt : CourtModel!
    var markers:[GMSMarker] = [GMSMarker]()
    
    var isProfileDialog : Bool = false
    
    var marker:GMSMarker = GMSMarker()
    var myLatitude:Float!
    var myLongitude:Float!
    
    var userImage : UIImage = UIImage()
    var isDashboardScreen : Bool = true
    var infoWindow : CustomPinInfoWindow!
    
    var isCheckInDialogOpen : Bool = false
    
    var viewAppearCnt : Int = 0
    @IBOutlet var verifyContainerView: UIView!
    @IBOutlet weak var mobileNumberView: UIView!
    @IBOutlet weak var mobileCodeView: UIView!
    @IBOutlet weak var mobileNumberTxt: UITextField!
    @IBOutlet weak var mobileCodeTxt: UITextField!
    
    var methodStart:Date = Date()
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if courtMapView != nil && courtMapView.selectedMarker != nil
        {
            courtMapView.selectedMarker = nil
        }
        isDashboardScreen = true
        AppDelegate().sharedDelegate().onUpdateBadgeCount()
        AppDelegate().sharedDelegate().updateLastSeen(isOnline: true)
        viewAppearCnt =  viewAppearCnt + 1
        if(viewAppearCnt == 5){
            checkForCheckedIn()
            viewAppearCnt = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isDashboardScreen = false
    }
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(redirectToProfile), name: NSNotification.Name(rawValue: NOTIFICATION.SHOW_PROFILE_SCREEN), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateLoggedInUserData), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setUserCurrentLocation), name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_CURRENT_USER_LOCATION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpadteBadgeCount), name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_BADGE_COUNT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(redirectToNewEventMap(noti:)), name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_REDIRECT_EVENT_MAP), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkForCheckedIn), name: NSNotification.Name(rawValue: NOTIFICATION.CHECK_FOR_CHECKEDIN), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupCourtsOnMap), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_EVENTS), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateAllStoryData), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_STORIES), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupCourtsOnMap), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_COURTS), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(noti:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
     
        AppDelegate().sharedDelegate().callAllHandler()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "CustomUserStoryCVC", bundle: nil), forCellWithReuseIdentifier: "CustomUserStoryCVC")
        
        setUIDesigning()
        
        delay(10){
            AppDelegate().sharedDelegate().uploadRemainingStory()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Preference.sharedInstance.setDataToPreference(data: true as AnyObject, forKey: "isLastSeenUpdate")
    }
    
    func isVerified(_ openDialog:Bool = true) -> Bool
    {
        if Auth.auth().currentUser?.isEmailVerified == true || AppModel.shared.currentUser.login_type == USER.FB_LOGIN || AppModel.shared.currentUser.login_type == USER.MOBILE_LOGIN
        {
            return true
        }
        else{
            
            Auth.auth().currentUser?.reload(completion: { (error) in
                if error == nil
                {
                    if Auth.auth().currentUser?.isEmailVerified == false{
                        displayToast( "Please verify your email address")
                    }
                }
                else
                {
                    displayToast( error!.localizedDescription)
                }
            })
        }
        return false
    }
    // MARK: - UIDesigning methods
    func setUIDesigning()
    {
        yourStoryBtn.addCornerRadius(radius: yourStoryBtn.frame.size.width/2)
        userProfileBtn.addCornerRadius(radius: userProfileBtn.frame.size.width/2)
        checkupBtn.addCornerRadius(radius: checkupBtn.frame.size.width/2)
        checkUpPopupProfilePicBtn.addCornerRadius(radius: checkUpPopupProfilePicBtn.frame.size.width/2)
        
        unreadNotificationBtn.addCornerRadius(radius: unreadNotificationBtn.frame.size.width/2)
        
        searchCourtView.addCornerRadiusOfView(radius: 5.0)
        createMapView()
        
        
        searchTbl.register(UINib.init(nibName: "customAddressTVC", bundle: nil), forCellReuseIdentifier: "customAddressTVC")
        searchTbl.backgroundColor = UIColor.clear
        searchTbl.separatorStyle = UITableViewCellSeparatorStyle.none
        searchTbl.tableFooterView = UIView(frame: CGRect.zero)
        searchCourtTblView.isHidden = true
        searchCourtTblView.backgroundColor = UIColor.clear
        
    }
    
    
    
    // MARK: - Brodcast methods
    func redirectToProfile()
    {
        let vc : EditProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        vc.isHideBackBtn = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func onUpdateLoggedInUserData()
    {
        if userProfileBtn == nil
        {
            return
        }
        AppDelegate().sharedDelegate().setUserProfileImage(AppModel.shared.currentUser.uID, button: self.userProfileBtn)
        AppDelegate().sharedDelegate().setUserProfileImage(AppModel.shared.currentUser.uID, button: self.yourStoryBtn)
    }
    func setUserCurrentLocation()
    {
        if courtMapView == nil
        {
            return
        }
        
        myLatitude = Preference.sharedInstance.getUserLatitude()
        myLongitude = Preference.sharedInstance.getUserLongitude()
        
        let position : CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(myLatitude), CLLocationDegrees(myLongitude))
        
        // Creates a marker in the center of the map
        marker.map = nil
        marker.position = position
        marker.map = courtMapView
        marker.title = "You are here"
        marker.icon = UIImage(named: IMAGE.USER_LOCATION)
        marker.zIndex = -1
        
        let move : GMSCameraUpdate = GMSCameraUpdate.setTarget(position)
        courtMapView.animate(with: move)
    }
    func onUpadteBadgeCount()
    {
        if unreadNotificationBtn == nil
        {
            return
        }
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
    
    func redirectToNewEventMap(noti : NSNotification)
    {
        let location :LocationModel = noti.object as! LocationModel
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude), zoom: 13.0)
        courtMapView.camera = camera
    }
    func checkForCheckedIn(){
        if AppModel.shared.currentUser == nil || AppModel.shared.currentUser.curr_court != "" || (isCheckInDialogOpen && isProfileDialog == false){
            return
        }
        
        //Check-In Dialog code
        var tempArr:[AppModel] = [AppModel] ()
        if isDashboardScreen == true && isVerified(false)
        {
            for appModel in arrCourtData
            {
                var location:LocationModel!
                if(appModel is CourtModel){
                    location = (appModel as! CourtModel).location
                }
                else
                {
                    location = (appModel as! LocationModel)
                }
                let oldCoordinate = CLLocation(latitude: CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude))
                let newCoordinate = CLLocation(latitude: CLLocationDegrees(Preference.sharedInstance.getUserLatitude()), longitude: CLLocationDegrees(Preference.sharedInstance.getUserLongitude()))
                
                let distanceInMeters = oldCoordinate.distance(from: newCoordinate) // result is in meters
                
                if Preference.sharedInstance.getUserLatitude() != 0 && Preference.sharedInstance.getUserLongitude() != 0 && distanceInMeters <= CLLocationDistance(USERVALUE.CHECKIN_DIFFERENCE)
                {
                    if(appModel is CourtModel){
                        let index = (appModel as! CourtModel).players.index(where: { (userID) -> Bool in
                            userID == AppModel.shared.currentUser.uID
                        })
                        
                        if(index == nil)
                        {
                            tempArr.append(appModel)
                        }
                    }
                    else
                    {
                        tempArr.append(appModel)
                    }
                    
                }
            }
            
            if tempArr.count > 0
            {
                setCheckedInCourt(tempArr[Int(arc4random_uniform(UInt32(tempArr.count)))])
                openUserProfileDialog()
                let state:UIApplicationState = UIApplication.shared.applicationState
                if state == UIApplicationState.active {
                }
                else{
                    AppDelegate().sharedDelegate().sendPush(title: "", body: "You want to check-in " + selectedCourt.location.name + " ?" , user: AppModel.shared.currentUser, type: PUSH_NOTIFICATION.TYPE.WANT_TO_CHECK_IN, otherId: "")
                }
            }
        }
    }
    func setCheckedInCourt(_ appModel:AppModel)
    {
        if(appModel is LocationModel){// prelocated
            selectedCourt = CourtModel.init(location: appModel as! LocationModel, players: [String](), activity: [String](), comment: [CommentModel](), story: [String](), date: getCurrentDateInString(), type: 1, uID : AppModel.shared.currentUser.uID)
        }
        else {
            selectedCourt = appModel as! CourtModel;
        }
    }
    
    func onUpdateAllStoryData()
    {
        if courtMapView == nil
        {
            return
        }
        arrUserStoryData = [UserModel]()
        
        for contact in AppModel.shared.currentUser.contact
        {
            let index = AppModel.shared.USERS.index(where: { (user) -> Bool in
                user.uID == contact.id && user.story.count > 0
            })
            
            if index != nil
            {
                if AppModel.shared.STORY[AppModel.shared.USERS[index!].story.last!] != nil{
                    arrUserStoryData.append(AppModel.shared.USERS[index!])
                }
            }
        }
    
        
        for tempLocation in AppModel.shared.COURTS
        {
            let oldCoordinate = CLLocation(latitude: CLLocationDegrees(tempLocation.location.latitude), longitude: CLLocationDegrees(tempLocation.location.longitude))
            let newCoordinate = CLLocation(latitude: CLLocationDegrees(Preference.sharedInstance.getUserLatitude()), longitude: CLLocationDegrees(Preference.sharedInstance.getUserLongitude()))
            
            let distanceInMeters = oldCoordinate.distance(from: newCoordinate) // result is in meters
            
            if Preference.sharedInstance.getUserLatitude() != 0 && Preference.sharedInstance.getUserLongitude() != 0 &&  distanceInMeters <= CLLocationDistance(USERVALUE.NEAREST_DIFFERENCE)
            {
                for contact in tempLocation.players
                {
                    let index = AppModel.shared.USERS.index(where: { (user) -> Bool in
                        user.uID == contact && user.story.count > 0
                    })
                    
                    if index != nil
                    {
                        let index1 = arrUserStoryData.index(where: { (user) -> Bool in
                            user.uID == contact
                        })
                        if(index1 == nil){
                            if AppModel.shared.STORY[AppModel.shared.USERS[index!].story.last!] != nil{
                                arrUserStoryData.append(AppModel.shared.USERS[index!])
                            }
                        }
                    }
                }
            }
        }
        
        if arrUserStoryData.count > 1
        {
            arrUserStoryData.sort {
                let elapsed0 = AppModel.shared.STORY[$0.story.last!]?.date
                let elapsed1 = AppModel.shared.STORY[$1.story.last!]?.date
                if(elapsed0 == nil || elapsed1 == nil){
                    return false
                }
                else{
                    return elapsed0! > elapsed1!
                }
            }
        }
        collectionView.reloadData()
    }
    /*
    func onRemoveCourtData(_ not:Notification){
        if(not.object as! Int == -1){
            return
        }
        let location:LocationModel = AppModel.shared.COURTS[not.object as! Int].location
        
        for i in 0..<self.arrCourtData.count{
            let appModel:AppModel = self.arrCourtData[i]
            var locationModel:LocationModel!
            
            if(appModel is LocationModel){
                locationModel = (appModel as! LocationModel)
            }
            else{
                locationModel = (appModel as! CourtModel).location
            }
            if locationModel.id == location.id{
                let marker:GMSMarker = markers[i]
                marker.map = nil
                markers.remove(at: i)
                arrCourtData.remove(at: i)
                break;
            }
        }
        for i in 0..<self.markers.count{
            markers[i].zIndex = Int32(i)
        }
    }
*/
    // MARK: - Collectionview Delaget methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrUserStoryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : CustomUserStoryCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomUserStoryCVC", for: indexPath) as! CustomUserStoryCVC
        cell.userNameLbl.text = ""
        cell.profilePicBtn.setBackgroundImage(nil, for: .normal)
        
        
        let dict : UserModel = arrUserStoryData[indexPath.row]
        AppDelegate().sharedDelegate().setUserProfileImage(dict.uID, button: cell.profilePicBtn)
        
        cell.userNameLbl.text = dict.username
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
        let user : UserModel = arrUserStoryData[indexPath.row]

        if user.story.count > 0
        {
            let vc : DisplayStoryVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayStoryVC") as! DisplayStoryVC
            vc.arrUser = arrUserStoryData
            vc.mainIndex = indexPath.row
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            displayToast( "Story not found.")
        }
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrSearchCourtData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : customAddressTVC = searchTbl.dequeueReusableCell(withIdentifier: "customAddressTVC", for: indexPath) as! customAddressTVC
        
        let appModel : AppModel = arrSearchCourtData[indexPath.row]
        
        if(appModel is CourtModel)
        {
            cell.titleLbl.text = (appModel as! CourtModel).location.name
            cell.addressLbl.text = (appModel as! CourtModel).location.address
        }
        else
        {
            cell.titleLbl.text = (appModel as! LocationModel).name
            cell.addressLbl.text = (appModel as! LocationModel).address
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.view.endEditing(true)
        //print(indexPath.row)
        
        var lat : Float = 0.0
        var long : Float = 0.0
        
        let appModel : AppModel = arrSearchCourtData[indexPath.row]
            
        if(appModel is CourtModel)
        {
            lat = (appModel as! CourtModel).location.latitude
            long = (appModel as! CourtModel).location.longitude
            searchCourtTxt.text = (appModel as! CourtModel).location.name
        }
        else
        {
            lat = (appModel as! LocationModel).latitude
            long = (appModel as! LocationModel).longitude
            searchCourtTxt.text = (appModel as! LocationModel).name
        }
        setMarkerAtTop(appModel, index: -1)
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long), zoom: 15.0)
        courtMapView.camera = camera
        courtMapView.animate(to: camera)
        searchCourtTblView.isHidden = true
    }

    func updateNewLocationTOCourt(appModel : AppModel)
    {
        
    }
    
    // MARK: - Button click event
    @IBAction func clickToCreateNewGame(_ sender: Any)
    {
        self.view.endEditing(true)
        if isVerified() {
            let vc : CreateNewGameEventTrainingVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateNewGameEventTrainingVC") as! CreateNewGameEventTrainingVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func clickToContact(_ sender: Any)
    {
        self.view.endEditing(true)
        clickToCloseCheckContainerView(self)
        if isVerified() {
            let vc : ContactsVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func clickToUserProfile(_ sender: Any)
    {
        self.view.endEditing(true)
        isProfileDialog = true
        openUserProfileDialog()
    }
    
    @IBAction func clickToCheckup(_ sender: Any)
    {
        self.view.endEditing(true)
        if isVerified() {
            
        }
    }
    
    @IBAction func clickToAddYourStory(_ sender: Any)
    {
        self.view.endEditing(true)
        if isVerified()
        {
            if AppModel.shared.currentUser.story.count == 0
            {
                clickToCamera(self)
            }
            else
            {
                var tempArr : [UserModel] = [UserModel] ()
                tempArr.append(AppModel.shared.currentUser)
                tempArr.append(contentsOf: arrUserStoryData)
                let vc : DisplayStoryVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayStoryVC") as! DisplayStoryVC
                vc.arrUser = tempArr
                vc.mainIndex = 0
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func clickToCamera(_ sender: Any)
    {
        self.view.endEditing(true)
        if isVerified()
        {
            let vc : CaptureStoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CaptureStoryVC") as! CaptureStoryVC
            self.navigationController?.pushViewController(vc, animated: true)
            //StartRecording()
        }
    }
    
    @IBAction func clickToMessageNotification(_ sender: Any)
    {
        self.view.endEditing(true)
        if isVerified() {
            let vc : MessageNotificationVC = self.storyboard?.instantiateViewController(withIdentifier: "MessageNotificationVC") as! MessageNotificationVC
            vc.isMessageDisplay = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func clickToStory(_ sender: Any)
    {
        self.view.endEditing(true)
        if isVerified() {
            let vc : StoriesVC = self.storyboard?.instantiateViewController(withIdentifier: "StoriesVC") as! StoriesVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func clickToNewsFeed(_ sender: Any)
    {
        self.view.endEditing(true)
    }
    @IBAction func clickToFindInGooglePlacePicker(_ sender: Any)
    {
        self.searchCourtTblView.isHidden = true
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    
    // MARK: - Google MapView
    func createMapView()
    {
        myLatitude = Preference.sharedInstance.getUserLatitude()
        myLongitude = Preference.sharedInstance.getUserLongitude()
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(myLatitude as Float), longitude: CLLocationDegrees(myLongitude as Float), zoom: 13.0)
        courtMapView.camera = camera
        courtMapView.settings.myLocationButton = false
        courtMapView.isMyLocationEnabled = true
        
        // Creates a marker in the center of the map
        marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(myLatitude as Float), longitude: CLLocationDegrees(myLongitude as Float))
        marker.map = courtMapView
        marker.title = "You are here"
        marker.icon = UIImage(named: IMAGE.USER_LOCATION)
        marker.zIndex = -1
        courtMapView.animate(to: camera)
        
        AppDelegate().sharedDelegate().getCourtNearByMe()
        
        setUserCurrentLocation()
    }
    func refreshMarker(_ appModel:AppModel, marker:GMSMarker, index:Int)
    {
//        var lat : Float = 0.0
//        var long : Float = 0.0
//        let currentCoordinate = CLLocation(latitude: CLLocationDegrees(Preference.sharedInstance.getUserLatitude()), longitude: CLLocationDegrees(Preference.sharedInstance.getUserLongitude()))
//        var courtCoordinate = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
//        var distanceInMeters = currentCoordinate.distance(from: courtCoordinate) // result is in meters
        
        var locationModel:LocationModel!
        if(appModel is LocationModel){
            locationModel = (appModel as! LocationModel)
        }
        else{
            locationModel = (appModel as! CourtModel).location
        }
                var total_player:Int = 0
        let pinView: CustomPinView = marker.iconView as! CustomPinView
        
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(locationModel.latitude), longitude: CLLocationDegrees(locationModel.longitude))
        marker.iconView?.backgroundColor = UIColor.clear
        pinView.pinImg.isSelected = false
        pinView.totalCountBtn.isHidden = true
        pinView.pinImg.tintColor = UIColor.clear
        if (appModel is LocationModel){
//            lat = (appModel as! LocationModel).latitude
//            long = (appModel as! LocationModel).longitude
//            courtCoordinate = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
//            distanceInMeters = currentCoordinate.distance(from: courtCoordinate) // result is in meters
//
//            pinView.distanceLbl.text = String(Int(distanceInMeters*3.28084))
        }
        else
        {
//            lat = (appModel as! CourtModel).location.latitude
//            long = (appModel as! CourtModel).location.longitude
//
//            courtCoordinate = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
//            distanceInMeters = currentCoordinate.distance(from: courtCoordinate) // result is in meters
//
//            pinView.distanceLbl.text = String(Int(distanceInMeters*3.28084))
            
            let tempCourt : CourtModel = appModel as! CourtModel
            if tempCourt.players.count > 0 //checkid court
            {
                total_player = tempCourt.players.count
            }
            else
            {
                total_player = tempCourt.activity.count
                for tempActivity in tempCourt.activity
                {
                    let index1 = AppModel.shared.EVENTS.index(where: { (tempEvent) -> Bool in
                        tempEvent.id == tempActivity
                    })
                    if index1 != nil
                    {
                        if getDifferenceToCurrentTime(date: AppModel.shared.EVENTS[index1!].maxDate) < 0
                        {
                            total_player -= 1
                        }
                    }
                }
            }
            if (appModel as! CourtModel).players.count > 0
            {
                pinView.pinImg.isSelected = true
            }
        }
        if total_player == 0
        {
            pinView.totalCountBtn.isHidden = true
        }
        else
        {
            pinView.totalCountBtn.isHidden = false
            pinView.totalCountBtn.setTitle(String(total_player), for: UIControlState.normal)
        }
        marker.zIndex = Int32(index)
    }
    func addMarker(_ appModel:AppModel){
        let marker:GMSMarker = GMSMarker()
        var locationModel:LocationModel!
        if(appModel is LocationModel){
            locationModel = (appModel as! LocationModel)
        }
        else{
            locationModel = (appModel as! CourtModel).location
        }
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(locationModel.latitude), longitude: CLLocationDegrees(locationModel.longitude))
        marker.iconView =  UINib(nibName: "CustomPinView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomPinView
        markers.append(marker)
        refreshMarker(appModel, marker: marker,index: markers.count)
        marker.map = courtMapView
    }
    func setupCourtsOnMap()
    {
        if courtMapView == nil
        {
            return
        }
        if(Date().timeIntervalSince(methodStart) < 1){
            delay(2, closure: {
                self.setupCourtsOnMap()
            })
        }
        methodStart = Date()
        
        arrCourtData = [AppModel] ()
        for i in 0..<AppModel.shared.COURTS.count
        {
            arrCourtData.append(AppModel.shared.COURTS[i])
        }
        for locationModel in AppModel.shared.PRELOCATED_COURTS
        {
            let index = AppModel.shared.COURTS.index(where: { (tempCourt) -> Bool in
                tempCourt.location.id == locationModel.id
            })
            if(index == nil){
                arrCourtData.append(locationModel)
            }
        }

        self.setMarkersAtTop(nil)
        self.showCourtsOnMap()
        checkForCheckedIn()
    }
   
    func setMarkersAtTop(_ tempCourt:AppModel?){
        var tempLocationModel:[LocationModel] = [LocationModel]()
        var tempCourtModel:[CourtModel] = [CourtModel]()
        var tempActivityCourtModel:[CourtModel] = [CourtModel]()
        var tempCheckedInCourtModel:[CourtModel] = [CourtModel]()
        for i in 0..<self.arrCourtData.count{
            if(self.arrCourtData[i] is LocationModel){
                tempLocationModel.append(self.arrCourtData[i] as! LocationModel)
            }
            else{
                let court:CourtModel = self.arrCourtData[i] as! CourtModel
                if court.players.count > 0{
                    tempCheckedInCourtModel.append(court)
                }
                else if court.activity.count > 0 && anyValidActivity(court){
                    tempActivityCourtModel.append(court)
                }
                else{
                    tempCourtModel.append(court)
                }
            }
        }
        for i in 0..<tempCheckedInCourtModel.count{
            if(tempCheckedInCourtModel[i].location.id == AppModel.shared.currentUser.curr_court){
                tempCheckedInCourtModel.swapAt(i, tempCheckedInCourtModel.count-1)
                break;
            }
        }
        
        arrCourtData = [AppModel] ()
        for i in 0..<tempLocationModel.count{
            arrCourtData.append(tempLocationModel[i])
        }
        for i in 0..<tempCourtModel.count{
            arrCourtData.append(tempCourtModel[i])
        }
        for i in 0..<tempActivityCourtModel.count{
            arrCourtData.append(tempActivityCourtModel[i])
        }
        for i in 0..<tempCheckedInCourtModel.count{
            arrCourtData.append(tempCheckedInCourtModel[i])
        }
        if (tempCourt != nil){
            
            var index:Int = -1
            var tempLocation:LocationModel!
            if(tempCourt is LocationModel){
               tempLocation = tempCourt as! LocationModel
            }
            else{
                let tempC:CourtModel = tempCourt as! CourtModel
                tempLocation = tempC.location
            }
            for i in 0..<self.arrCourtData.count{
                if(self.arrCourtData[i] is LocationModel){
                    let tempLocation1:LocationModel = self.arrCourtData[i] as! LocationModel
                    if(tempLocation1.id == tempLocation.id){
                        index  = i
                        break
                    }
                }
                    
                else{
                    let court:CourtModel = self.arrCourtData[i] as! CourtModel
                    if(court.location.id == tempLocation.id){
                        index = 1
                        break
                    }
                }
            }
            if(index != -1){
                arrCourtData.remove(at: index)
            }
            arrCourtData.append(tempCourt!)
        }
        
    }
    
    func anyValidActivity(_ court:CourtModel) -> Bool{
        var total_activity:Int = court.activity.count
        for tempActivity in court.activity
        {
            let index = AppModel.shared.EVENTS.index(where: { (tempEvent) -> Bool in
                tempEvent.id == tempActivity
            })
            if index != nil
            {
                if getDifferenceToCurrentTime(date: AppModel.shared.EVENTS[index!].maxDate) < 0
                {
                    total_activity -= 1
                }
            }
        }
        return total_activity > 0 ? true : false
    }
    func setMarkerAtTop(_ tempCourt:AppModel, index:Int){
        
        var ind:Int = index
        var location:LocationModel!
        
        if(tempCourt is LocationModel){
            location = (tempCourt as! LocationModel)
        }
        else{
            location = (tempCourt as! CourtModel).location
        }
        
        if(index == -1){
            for i in 0..<self.arrCourtData.count{
                var locationModel:LocationModel!
                if(self.arrCourtData[i] is LocationModel){
                    locationModel = (self.arrCourtData[i] as! LocationModel)
                }
                else{
                    locationModel = (self.arrCourtData[i] as! CourtModel).location
                }
                if locationModel.id == location.id{
                    ind = i
                    break;
                }
            }
        }
        if(index == -1 || arrCourtData.count == 0){
            return
        }
        let top:AppModel = arrCourtData[arrCourtData.count-1]
        let topMarker:GMSMarker = markers[markers.count-1]
        let court:AppModel = arrCourtData[ind]
        let courtMarker:GMSMarker = markers[ind]
        arrCourtData[ind] = top
        markers[ind] = topMarker
        arrCourtData[arrCourtData.count-1] = court
        markers[markers.count-1] = courtMarker
        markers[markers.count-1].zIndex = Int32(markers.count - 1)
        markers[ind].zIndex = Int32(ind)
    }
    
    func showCourtsOnMap()
    {
        for i in 0..<self.arrCourtData.count
        {
            if(markers.count-1 >= i){
                self.refreshMarker(arrCourtData[i],marker:markers[i],index: i)
            }
            else{
                self.addMarker(arrCourtData[i])
            }
        }
        //remove markers
        while(markers.count > arrCourtData.count){
            let marker:GMSMarker = markers[markers.count-1]
            marker.map = nil
            markers.remove(at: markers.count - 1)
        }
        AppDelegate().sharedDelegate().setAllHandler()
        print("****** COURTS ***** %d", arrCourtData.count)
    }
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?  //first tap on Map Pin
    {
        if marker.zIndex == -1 {
            return UIView()
        }
        if isVerified() {
            
            let indexVal : Int = Int(marker.zIndex)
            if let appModel:AppModel = arrCourtData[indexVal]{
            
                var intGame = 0
                var intEvent = 0
                var intTraining = 0
                var location:LocationModel!
                
                infoWindow = UINib(nibName: "CustomPinInfoWindow", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomPinInfoWindow
                infoWindow.backgroundColor = UIColor.clear
                
                infoWindow.constraintWidthGameView.constant = 0
                infoWindow.gameView.isHidden = true
                infoWindow.constraintWidthWorldCupView.constant = 0
                infoWindow.worldCupView.isHidden = true
                infoWindow.constraintWidthTrainingView.constant = 0
                infoWindow.trainingView.isHidden = true
                infoWindow.pinContainerHeight.constant = 0
                infoWindow.pinContainerView.isHidden = true
                
                
                if(appModel is CourtModel)
                {
                    let courtModel:CourtModel = appModel as! CourtModel
                   
                    for event in courtModel.activity
                    {
                        let index = AppModel.shared.EVENTS.index(where: { (eventModel) -> Bool in
                            event == eventModel.id
                        })
                        if index != nil {
                            let eventModel : EventModel = AppModel.shared.EVENTS[index!]
                            
                            if getDifferenceToCurrentTime(date: eventModel.maxDate) < 0 //not showing old events
                            {
                                continue
                            }
                            if eventModel.type == 1
                            {
                                intGame += 1
                            }
                            else if eventModel.type == 2
                            {
                                intEvent += 1
                            }
                            else if eventModel.type == 3
                            {
                                intTraining += 1
                            }
                        }
                    }
                    
                    location = courtModel.location
                    
                }
                else
                {
                   location = appModel as! LocationModel
                }
                
                if intGame > 0 {
                    infoWindow.constraintWidthGameView.constant = 30
                    infoWindow.gameView.isHidden = false
                    infoWindow.gameScoreBtn.setTitle(String(format: "%d", intGame), for: UIControlState.normal)
                }
                
                if intEvent > 0 {
                    infoWindow.constraintWidthWorldCupView.constant = 30
                    infoWindow.worldCupView.isHidden = false
                    infoWindow.worldCupScoreBtn.setTitle(String(format: "%d", intEvent), for: UIControlState.normal)
                }
                
                if intTraining > 0 {
                    infoWindow.constraintWidthTrainingView.constant = 30
                    infoWindow.trainingView.isHidden = false
                    infoWindow.trainingScoreBtn.setTitle(String(format: "%d", intTraining), for: UIControlState.normal)
                }
                
                if intGame > 0 || intEvent > 0 || intTraining > 0
                {
                    infoWindow.pinContainerView.isHidden = false
                    infoWindow.pinContainerWidth.constant = infoWindow.constraintWidthGameView.constant + infoWindow.constraintWidthWorldCupView.constant + infoWindow.constraintWidthTrainingView.constant
                    infoWindow.pinContainerHeight.constant = 40
                }
                
    //            if location.image.count == 0 {
    //                infoWindow.constraintWidthProfilePic.constant = 0
    //                infoWindow.profilePicBtn.setBackgroundImage(nil, for: UIControlState.normal)
    //            }
    //            else
    //            {
    //                infoWindow.constraintWidthProfilePic.constant = 30
                    AppDelegate().sharedDelegate().setCourtImage(location.image, button: infoWindow.profilePicBtn)
    //            }
                
                infoWindow.pinTitleLbl.text = location.name
                infoWindow.pinAddressLbl.text = location.address
                
                var newFrame : CGRect = infoWindow.frame
                newFrame.size.height = 94 - 40 + infoWindow.pinContainerHeight.constant
                infoWindow.frame = newFrame
                
                //infoWindow.tag = indexVal
                
                return infoWindow
            }
        }
        return UIView()
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) // tap on info window
    {
        if marker.zIndex == -1 {
            return
        }
        if isVerified() {
            
            let index : Int = Int(marker.zIndex)
            if let appModel:AppModel = arrCourtData[index]{
               
                if (appModel is LocationModel) //redirect to court page
                {
                    let court : CourtModel = CourtModel.init(location: (appModel as! LocationModel), players: [], activity: [], comment: [], story: [String](), date: getCurrentDateInString(), type: 1, uID : AppModel.shared.currentUser.uID)
                    AppDelegate().sharedDelegate().onPrelocatedCourtTap(court)
                    let vc : CourtDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "CourtDetailVC") as! CourtDetailVC
                    vc.currCourtModel = court
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else
                {
                    let vc : CourtDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "CourtDetailVC") as! CourtDetailVC
                    vc.currCourtModel = (appModel as! CourtModel)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        //        place.placeID
        //        place.name
        //        place.formattedAddress
        //        place.coordinate.latitude
        //        place.coordinate.longitude
        //        place.openNowStatus
        
        
        
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
                        let name = placeNameTxt.text
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
                        
                        let location : LocationModel = LocationModel.init(id: id, name: name!, image: img_url, address: address, latitude: lat, longitude: long, isOpen: isOpen)
                        
                        let index = AppModel.shared.COURTS.index(where: { (tempCourt) -> Bool in
                            tempCourt.location.id == location.id
                        })
                        
                        if index == nil
                        {
                            let noAction = UIAlertAction (title: "NO", style: UIAlertActionStyle.cancel, handler: nil)
                            
                            let yesAction = UIAlertAction(title: "YES", style: .default) { (action) in
                                
                                location.name = placeNameTxt.text
                                let court : CourtModel = CourtModel.init(location: location, players: [], activity: [], comment: [], story: [], date: getCurrentDateInString(), type: 2, uID : AppModel.shared.currentUser.uID)
                                self.arrCourtData.append(court)
                                AppDelegate().sharedDelegate().onCreateCourt(court)
                                self.addMarker(court)
                            
                                let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long), zoom: 15.0)
                                self.courtMapView.camera = camera
                                self.courtMapView.animate(to: camera)
                            }
                            
                            
                            
                            alertConfirmation.addAction(noAction)
                            alertConfirmation.addAction(yesAction)
                            
                            self.present(alertConfirmation, animated: true, completion: nil)
                            
                        }
                        else
                        {
                            
                            for i in 0..<self.arrCourtData.count{
                                var locationModel:LocationModel!
                                if(self.arrCourtData[i] is LocationModel){
                                    locationModel = (self.arrCourtData[i] as! LocationModel)
                                }
                                else{
                                    locationModel = (self.arrCourtData[i] as! CourtModel).location
                                }
                                if locationModel.id == location.id{
                                    self.setMarkerAtTop(self.arrCourtData[i], index:i)
                                    break;
                                }
                            }
                            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long), zoom: 15.0)
                            self.courtMapView.camera = camera
                            self.courtMapView.animate(to: camera)
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
    
    //MARK:- user dialog
    func openUserProfileDialog()
    {
        if isCheckInDialogOpen == true {
            return
        }
        isCheckInDialogOpen = true
        checkUpTopPopupView.addCornerRadiusOfView(radius: 30)
        checkUpBottomPopupView.addCornerRadiusOfView(radius: 30)
        checkupCourtPicBtn.addCornerRadius(radius: checkupCourtPicBtn.frame.size.width/2)
        if isProfileDialog == true {
            checkUpBottomPopupView.isHidden = true
            checkUpPoupupUserBottomView.isHidden = true
            constraintHeightCheckUpPopupBottomView.constant = 0
            checkUpPopupProfileBtnView.isHidden = false
            constraintHeightCheckUpPopupView.constant = 290 - 60
            
        }
        else
        {
            
            checkUpBottomPopupView.isHidden = false
            checkUpPoupupUserBottomView.isHidden = false
            constraintHeightCheckUpPopupBottomView.constant = 60
            checkUpPopupProfileBtnView.isHidden = true
            constraintHeightCheckUpPopupView.constant = 290
            
        }
        setUserLoginDataToCheckupDialog()
        displaySubViewtoParentView(self.view, subview: checkupContainerView)
        
    }

    
    func setUserLoginDataToCheckupDialog()
    {
        if isProfileDialog == false
        {
            AppDelegate().sharedDelegate().setCourtImage(selectedCourt.location.image, button: checkupCourtPicBtn)
            checkupCourtNameLbl.text = selectedCourt.location.name
            checkupCourtLocationLbl.text = selectedCourt.location.address
            checkupCourtMemberLbl.text = ""
        }
        
        AppDelegate().sharedDelegate().setUserProfileImage(AppModel.shared.currentUser.uID, button: checkUpPopupProfilePicBtn)

        checkupNameLbl.text = AppModel.shared.currentUser.name
        checkupUsernameLbl.text = AppModel.shared.currentUser.username
        if(AppModel.shared.currentUser.age == 0){
            checkupAgeLbl.text =  "AGE : ";
        }
        else{
            checkupAgeLbl.text = String(format: "AGE : %d", AppModel.shared.currentUser.age)
        }
        
        checkupHeightLbl.text = String(format: "HEIGHT : %@", AppModel.shared.currentUser.height)
        checkupPositionLbl.text = String(format: "POSITION : %@", AppDelegate().sharedDelegate().getUserPosition(position: AppModel.shared.currentUser.position))
        checkupLocationLbl.text = String(format: "LOCATION : %@", AppModel.shared.currentUser.location.address)
        checkupCheckInLbl.text = String(format: "CHECK-INS: %d", AppModel.shared.currentUser.total_checkIn)
        
    }
    
    @IBAction func clickToCloseCheckContainerView(_ sender: Any)
    {
        checkupContainerView.removeFromSuperview()
        isCheckInDialogOpen = false
        isProfileDialog = false
    }
    
    
    @IBAction func clickToSetting(_ sender: Any)
    {
        clickToCloseCheckContainerView(self)
        let vc : EditProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToCheckInBtn(_ sender: UIView)
    {
        clickToCloseCheckContainerView(self)
        selectedCourt.players.append(AppModel.shared.currentUser.uID)
        
        let vc : CourtDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "CourtDetailVC") as! CourtDetailVC
        vc.currCourtModel = selectedCourt
        AppDelegate().sharedDelegate().onCheckedInCourt(selectedCourt)
        self.navigationController?.pushViewController(vc, animated: true)
        if sender != self.view
        {
            displayToast("You've successfully checked-in")
        }
        
    }
    
    
    // MARK: - UITextField Delegate
    
    func textFieldDidChange(noti : Notification)
    {
        let textField : UITextField = noti.object as! UITextField
        if textField == searchCourtTxt
        {
            arrSearchCourtData = [AppModel]()
            for i in 0..<arrCourtData.count
            {
                let appModel:AppModel = arrCourtData[i]
                if(appModel is CourtModel)
                {
                    if (appModel as! CourtModel).location.name.lowercased().contains((searchCourtTxt.text?.lowercased())!)
                    {
                        arrSearchCourtData.append(appModel)
                    }
                }
                else
                {
                    if (appModel as! LocationModel).name.lowercased().contains((searchCourtTxt.text?.lowercased())!)
                    {
                        arrSearchCourtData.append(appModel)
                    }
                }
            }
            if arrSearchCourtData.count > 0
            {
                searchCourtTblView.isHidden = false
                searchTbl.reloadData()
            }
            else
            {
                searchCourtTblView.isHidden = true
                searchTbl.reloadData()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
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

extension UIView {
    func captureScreen() -> UIImage? {
        self.backgroundColor = UIColor.white
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //        self.backgroundColor = UIColor.clear
        return image
    }
}


