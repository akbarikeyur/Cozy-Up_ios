//
//  StoriesVC.swift
//  Check-Up
//
//  Created by Amisha on 13/09/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import GoogleMobileAds
import CoreLocation

class StoriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var userProfilePicBtn: UIButton!
    @IBOutlet weak var myStoryView: UIView!
    @IBOutlet weak var userStoryBtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userDurationLbl: UILabel!
    @IBOutlet weak var constraintHeightMyStoryView: NSLayoutConstraint!
    @IBOutlet weak var courtTblView: UITableView!
    @IBOutlet weak var playerCollectionView: UICollectionView!
    @IBOutlet weak var playerTblView: UITableView!
    @IBOutlet weak var courtStoryView: UIView!
    @IBOutlet weak var constraintHeightCourtTblView : NSLayoutConstraint!
    @IBOutlet weak var playerCollView: UIView!
    @IBOutlet weak var constraintHeightPlayerCollectionView : NSLayoutConstraint!
    @IBOutlet weak var playerStoryView: UIView!
    @IBOutlet weak var constraintHeightPlayerStoryView: NSLayoutConstraint!
    @IBOutlet weak var noStoryFoundLbl: UILabel!
    @IBOutlet weak var bannerAdView: UIView!
    @IBOutlet weak var constraintHeightAdView: NSLayoutConstraint!
    @IBOutlet weak var unreadNotificationBtn: UIButton!
    
    var arrCourt : [CourtModel] = [CourtModel] ()
    var arrCourtUser : [UserModel] = [UserModel] ()
    var arrFriends : [UserModel] = [UserModel] ()
    
    var screenFrom : String!
    
    override func viewWillAppear(_ animated: Bool) {
        onUpadteBadgeCount()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onUpadteBadgeCount), name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_BADGE_COUNT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(redirectToNewFriendList(noti:)), name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_REDIRECT_NEW_FRIEND_LIST), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setCourtStoryData), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setCourtStoryData), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_STORIES), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setCourtStoryData), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_COURTS), object: nil)
        
        setUIDesigning()
        
    }
    
    func setUIDesigning()
    {
        
        userProfilePicBtn.addCornerRadius(radius: userProfilePicBtn.frame.size.width/2)
        userStoryBtn.addCornerRadius(radius: userStoryBtn.frame.size.width/2)
        
        courtTblView.backgroundColor = UIColor.clear
        courtTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        courtTblView.tableFooterView = UIView(frame: CGRect.zero)
        courtTblView.register(UINib.init(nibName: "CustomContactTVC", bundle: nil), forCellReuseIdentifier: "CustomContactTVC")
        
        playerTblView.backgroundColor = UIColor.clear
        playerTblView.separatorStyle = UITableViewCellSeparatorStyle.none
        playerTblView.tableFooterView = UIView(frame: CGRect.zero)
        playerTblView.register(UINib.init(nibName: "CustomContactTVC", bundle: nil), forCellReuseIdentifier: "CustomContactTVC")
        
        playerCollectionView.delegate = self
        playerCollectionView.dataSource = self
        playerCollectionView.register(UINib.init(nibName: "CustomUserStoryCVC", bundle: nil), forCellWithReuseIdentifier: "CustomUserStoryCVC")
        
        setupBannerView()
        
        setCourtStoryData()
    }
    
    func redirectToNewFriendList(noti:NSNotification)
    {
        let vc : ContactsVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsVC
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    func setupBannerView()
    {
        let bannerView: GADBannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = GOOGLE.BANNER_AD_ID
        bannerView.rootViewController = self
        bannerAdView.addSubview(bannerView)
        bannerView.load(GADRequest())
        constraintHeightAdView.constant = 50
    }
    
    func setCourtStoryData()
    {
        if courtTblView == nil
        {
            return
        }
        
        AppDelegate().sharedDelegate().setUserProfileImage(AppModel.shared.currentUser.uID, button: userProfilePicBtn)
        
        if AppModel.shared.currentUser.story.count > 0 && AppModel.shared.STORY[AppModel.shared.currentUser.story.last!] != nil {
            userNameLbl.text = "My Story"
            AppDelegate().sharedDelegate().setUserProfileImage(AppModel.shared.currentUser.uID, button: userStoryBtn)
            
            userDurationLbl.text = getDifferenceFromCurrentTimeInHourInDays(date: (AppModel.shared.STORY[AppModel.shared.currentUser.story.last!]?.date)!)
            constraintHeightMyStoryView.constant = 70
            myStoryView.isHidden = false
        }
        else
        {
            constraintHeightMyStoryView.constant = 0
            myStoryView.isHidden = true
        }
        
        //court story
        arrCourt = [CourtModel] ()
        
        for tempCourt in AppModel.shared.COURTS
        {
            if tempCourt.story.count > 0 && AppModel.shared.STORY[tempCourt.story.last!] != nil
            {
                let oldCoordinate = CLLocation(latitude: CLLocationDegrees(tempCourt.location.latitude), longitude: CLLocationDegrees(tempCourt.location.longitude))
                let newCoordinate = CLLocation(latitude: CLLocationDegrees(Preference.sharedInstance.getUserLatitude()), longitude: CLLocationDegrees(Preference.sharedInstance.getUserLongitude()))
                
                let distanceInMeters = oldCoordinate.distance(from: newCoordinate) // result is in meters
                
                if Preference.sharedInstance.getUserLatitude() != 0 && Preference.sharedInstance.getUserLongitude() != 0 && distanceInMeters <= CLLocationDistance(USERVALUE.NEAREST_DIFFERENCE)
                {
                    arrCourt.append(tempCourt)
                }
            }
        }
        
        //court user
        arrCourtUser = [UserModel]()
        
        for tempCourt in AppModel.shared.COURTS
        {
            if tempCourt.players.count == 0
            {
                continue
            }
//            let oldCoordinate = CLLocation(latitude: CLLocationDegrees(tempCourt.location.latitude), longitude: CLLocationDegrees(tempCourt.location.longitude))
//            let newCoordinate = CLLocation(latitude: CLLocationDegrees(Preference.sharedInstance.getUserLatitude()), longitude: CLLocationDegrees(Preference.sharedInstance.getUserLongitude()))
//
//            let distanceInMeters = oldCoordinate.distance(from: newCoordinate) // result is in meters
//
//            if distanceInMeters <= CLLocationDistance(USERVALUE.NEAREST_DIFFERENCE)
//            {
                let player : [String] = tempCourt.players
                for j in 0..<player.count
                {
                    let index = AppModel.shared.USERS.index(where: { (user) -> Bool in
                        user.uID == player[j]
                    })
                    if index != nil
                    {
                        arrCourtUser.append(AppModel.shared.USERS[index!])
                    }
                }
//            }
        }
        
        
        //friends
        arrFriends = [UserModel] ()
        for i in 0..<AppModel.shared.USERS.count
        {
            let index = AppModel.shared.currentUser.contact.index(where: { (contact) -> Bool in
                contact.id == AppModel.shared.USERS[i].uID
            })
            if index != nil {
                if AppModel.shared.USERS[i].story.count > 0 && AppModel.shared.STORY[AppModel.shared.USERS[i].story.last!] != nil {
                    arrFriends.append(AppModel.shared.USERS[i])
                }
            }
        }

        if arrFriends.count > 1
        {
            arrFriends.sort {
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
        setTableviewHeight()
    }
    
    func setTableviewHeight()
    {
        var isStoryAvailable : Bool = false
        
        
        if AppModel.shared.currentUser.story.count > 0 && AppModel.shared.STORY[AppModel.shared.currentUser.story.last!] != nil
        {
            constraintHeightMyStoryView.constant = 70
            myStoryView.isHidden = false
            isStoryAvailable = true
        }
        else
        {
            constraintHeightMyStoryView.constant = 0
            myStoryView.isHidden = true
        }
        
        courtTblView.reloadData()
        if arrCourt.count > 0
        {
            courtStoryView.isHidden = false
            constraintHeightCourtTblView.constant = courtTblView.contentSize.height + 40
            if isStoryAvailable == false
            {
                isStoryAvailable = true
            }
        }
        else
        {
            courtStoryView.isHidden = true
            constraintHeightCourtTblView.constant = 0
            
        }
        
        playerCollectionView.reloadData()
        if arrCourtUser.count > 0
        {
            playerCollView.isHidden = false
            constraintHeightPlayerCollectionView.constant = 125
            if isStoryAvailable == false
            {
                isStoryAvailable = true
            }
        }
        else
        {
            playerCollView.isHidden = true
            constraintHeightPlayerCollectionView.constant = 0
        }
        
        playerTblView.reloadData()
        if arrFriends.count > 0
        {
            playerStoryView.isHidden = false
            constraintHeightPlayerStoryView.constant = playerTblView.contentSize.height + 40
            if isStoryAvailable == false
            {
                isStoryAvailable = true
            }
        }
        else
        {
            playerStoryView.isHidden = true
            constraintHeightPlayerStoryView.constant = 0
        }
        
        noStoryFoundLbl.isHidden = isStoryAvailable
    }


    @IBAction func clickToUserProfilePic(_ sender: Any)
    {
        AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: AppModel.shared.currentUser)
    }
    
    @IBAction func clickToHome(_ sender: Any)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func clickToMessageNotification(_ sender: Any)
    {
        if screenFrom != nil && screenFrom == "MessageNotificationVC"
        {
            _ = self.navigationController?.popViewController(animated: true)
        }
        else
        {
            let vc : MessageNotificationVC = self.storyboard?.instantiateViewController(withIdentifier: "MessageNotificationVC") as! MessageNotificationVC
            vc.screenFrom = "StoriesVC"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func clickToOpenMyStory(_ sender: Any)
    {
        if AppModel.shared.currentUser.story.count > 0  && AppModel.shared.STORY[AppModel.shared.currentUser.story.last!] != nil
        {
            let vc : DisplayStoryVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayStoryVC") as! DisplayStoryVC
            vc.arrUser = [AppModel.shared.currentUser]
            vc.mainIndex = 0
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        displayToast("Story not found.")
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == courtTblView
        {
            return arrCourt.count
        }
        else if tableView == playerTblView
        {
            return arrFriends.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = ((tableView == courtTblView) ? courtTblView : playerTblView).dequeueReusableCell(withIdentifier: "CustomContactTVC", for: indexPath) as! CustomContactTVC
        
        if tableView == courtTblView {
            let court : CourtModel = arrCourt[indexPath.row]
            AppDelegate().sharedDelegate().setCourtImage(court.location.image, button: cell.userProfilePicBtn)
            cell.titleLbl.text = court.location.name
            cell.subTitleLbl.text = ""
            if(court.story.count > 0){
                if let story = AppModel.shared.STORY[court.story.last!]{
                    cell.subTitleLbl.text = getDifferenceFromCurrentTimeInHourInDays(date: story.date)
                }
            }
            
            if indexPath.row == (arrCourt.count-1) {
                cell.seperatorImgView.isHidden = true
            }
            else
            {
                cell.seperatorImgView.isHidden = false
            }
        }
        else
        {
            let user : UserModel = arrFriends[indexPath.row]
            AppDelegate().sharedDelegate().setUserProfileImage(user.uID, button: cell.userProfilePicBtn)
            
            cell.titleLbl.text = user.username
            cell.subTitleLbl.text = getDifferenceFromCurrentTimeInHourInDays(date: (AppModel.shared.STORY[user.story.last!]?.date)!)
            
            if indexPath.row == (arrCourt.count-1) {
                cell.seperatorImgView.isHidden = true
            }
            else
            {
                cell.seperatorImgView.isHidden = false
            }
            
            cell.userProfilePicBtn.isUserInteractionEnabled = true
            cell.userProfilePicBtn.tag = indexPath.row
            cell.userProfilePicBtn.addTarget(self, action: #selector(clickToRecentUser(_:)), for: UIControlEvents.touchUpInside)
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == courtTblView
        {
            let vc : DisplayStoryVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayStoryVC") as! DisplayStoryVC
            vc.arrCourt = arrCourt
            vc.mainIndex = indexPath.row
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            let vc : DisplayStoryVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayStoryVC") as! DisplayStoryVC
            vc.arrUser = arrFriends
            vc.mainIndex = indexPath.row
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    @IBAction func clickToRecentUser(_ sender: UIButton)
    {
        AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: arrFriends[sender.tag])
    }
    // MARK: - Collectionview Delaget methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrCourtUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : CustomUserStoryCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomUserStoryCVC", for: indexPath) as! CustomUserStoryCVC
        
        let user : UserModel = arrCourtUser[indexPath.row]
        
        AppDelegate().sharedDelegate().setUserProfileImage(user.uID, button: cell.profilePicBtn)
        
        cell.userNameLbl.text = user.username
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let user : UserModel = arrCourtUser[indexPath.row]
        if user.story.count > 0 && AppModel.shared.STORY[user.story.last!] != nil
        {
            let vc : DisplayStoryVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayStoryVC") as! DisplayStoryVC
            vc.arrUser = arrCourtUser
            vc.mainIndex = indexPath.row
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            displayToast("Story not found.")
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
