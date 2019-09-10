//
//  DisplayStoryVC.swift
//  Check-Up
//
//  Created by Amisha on 14/09/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import GoogleMobileAds
import Photos

class DisplayStoryVC: UIViewController, GADInterstitialDelegate {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var userLbl: UILabel!
    @IBOutlet weak var mediaImgBtn: UIButton!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var sendToBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    
    //var moviePlayer : MPMoviePlayerController?
    var moviePlayer : AVPlayer?
    let thumbnalImg : UIImage = UIImage()
    let playerViewController = AVPlayerViewController()
    
    var mainIndex : Int = 0
    var subIndex : Int = 0
    
    var arrUser : [UserModel]!
    var arrCourt : [CourtModel]!
    var selectedStory : StoryModel!
    var currentStory : StoryModel!
    
    var mediaTimer : Timer!
    var mediaTimer1 : Timer!
    
    var interstitial: GADInterstitial!
    
    var isBackAllow : Bool = true
    var isFirst : Bool = true
    var adDisplayCounter : Int = 0
    
    override func viewWillAppear(_ animated: Bool)
    {
        isBackAllow = true
        if isFirst == true
        {
            isFirst = false
            playMedia()
            interstitial = createAndLoadInterstitial()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        destroy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayerPlaybackStateChanged(noti:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        if arrCourt != nil
        {
            sendToBtn.isHidden = false
            deleteBtn.isHidden = false
            replyBtn.isHidden = true
            reportBtn.isHidden = true
        }
        
        userLbl.text = ""
        playerViewController.showsPlaybackControls = false
        playerViewController.view.frame = self.view.bounds
        
        if arrUser != nil && arrUser.count > mainIndex
        {
            subIndex = arrUser[mainIndex].story.count - 1
        }
        else if arrCourt != nil && arrCourt.count > mainIndex
        {
            subIndex = arrCourt[mainIndex].story.count - 1
        }
    }
    
    func destroy(){
        killProcess()
        AppDelegate().sharedDelegate().hideUserProfilePopup()
        DispatchQueue.main.async {
            removeLoader()
        }
    }
    func killProcess(){
        if mediaTimer != nil
        {
            mediaTimer.invalidate()
            mediaTimer = nil
        }
        if self.mediaTimer1 != nil
        {
            self.mediaTimer1.invalidate()
            self.mediaTimer1 = nil
        }
        if playerViewController != nil
        {
            playerViewController.player?.pause()
        }
    }
   
    //MARK: - Movie player
    func moviePlayerPlaybackStateChanged(noti : NSNotification)
    {
        DispatchQueue.main.async {
            removeLoader()
        }
        checkForPlayMedia()
    }
    
    //MARK:- Story
    func playMedia()
    {
        if selectedStory != nil
        {
            sendToBtn.isHidden = true
            deleteBtn.isHidden = true
            replyBtn.isHidden = true
            reportBtn.isHidden = true
            currentStory = selectedStory
        }
        else
        {
            if let tempStory = getStory()
            {
                if tempStory.uID == AppModel.shared.currentUser.uID
                {
                    sendToBtn.isHidden = false
                    deleteBtn.isHidden = false
                    replyBtn.isHidden = true
                    reportBtn.isHidden = true
                }
                else
                {
                    sendToBtn.isHidden = true
                    deleteBtn.isHidden = true
                    replyBtn.isHidden = false
                    reportBtn.isHidden = false
                }
                currentStory = tempStory
            }
            else
            {
                clickToCloseStory(self)
                return
            }
        }
        
        let strokeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.orange,
            NSForegroundColorAttributeName : UIColor.white,
            NSStrokeWidthAttributeName : -3.0,
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 40)
            ] as [String : Any]
        
        
        DispatchQueue.main.async {
            displayLoader()
        }
        
        if currentStory.type == 1 //image
        {
            if(checkForBlockUser()){
                return
            }
           
            mediaImgBtn.isHidden = false
            videoView.isHidden = true
            if let image = getImage(imageName: currentStory.local_url)
            {
                DispatchQueue.main.async {
                    removeLoader()
                }
                
                self.mediaImgBtn.setImage(image, for: UIControlState.normal)
                self.mediaImgBtn.setBackgroundImage(nil, for: UIControlState.normal)
                //self.mediaImgBtn.setBackgroundImage(image.toFitSize(self.mediaImgBtn.frame.size, method: MGImageResizeCrop), for: UIControlState.normal)
                self.killProcess()
                mediaTimer = Timer.scheduledTimer(timeInterval: TimeInterval(USERVALUE.STORY_DISPLAY_TIME), target: self, selector: #selector(self.checkForPlayMedia), userInfo: nil, repeats: false)
            }
            else
            {
                if currentStory.remote_url.count > 0
                {
                    mediaImgBtn.sd_setBackgroundImage(with: URL(string: currentStory.remote_url), for: UIControlState.normal, completed: { (image, error, SDImageCacheType, url) in
                        if error == nil{
                            if self.currentStory.local_url.count > 0
                            {
                                storeImageInDocumentDirectory(image: image!, imageName: self.currentStory.local_url)
                            }
                            self.mediaImgBtn.setImage(image, for: UIControlState.normal)
                            self.mediaImgBtn.setBackgroundImage(nil, for: UIControlState.normal)
//                            self.mediaImgBtn.setBackgroundImage(image?.toFitSize(self.mediaImgBtn.frame.size, method: MGImageResizeCrop), for: UIControlState.normal)
                        }
                        DispatchQueue.main.async {
                            removeLoader()
                        }
                        
                        
                        self.killProcess()
                        self.mediaTimer = Timer.scheduledTimer(timeInterval: TimeInterval(USERVALUE.STORY_DISPLAY_TIME), target: self, selector: #selector(self.checkForPlayMedia), userInfo: nil, repeats: false)
                    })
                }
                else
                {
                    DispatchQueue.main.async {
                        removeLoader()
                    }
                    self.checkForPlayMedia()
                }
            }
        }
        else // video
        {
            if(checkForBlockUser()){
                return
            }
            mediaImgBtn.isHidden = true
            videoView.isHidden = false
            var video_url : URL
            if let strUrl = getVideo(videoName: currentStory.local_url)
            {
                video_url = URL(fileURLWithPath: strUrl)
            }
            else if (currentStory.remote_url.count > 0)
            {
                video_url = URL(string: currentStory.remote_url)!
//                storeVideoInDocumentDirectory(videoUrl: video_url, videoName: currentStory.local_url)
            }
            else
            {
                DispatchQueue.main.async {
                    removeLoader()
                }
                self.checkForPlayMedia()
                return
            }
            
            moviePlayer = AVPlayer(url: video_url)
            if let player = moviePlayer
            {
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                }catch {
                    print(error)
                }
                playerViewController.player?.isMuted = false
                playerViewController.isActivityIndicatorHidden = true
                playerViewController.player = player
                videoView.addSubview(playerViewController.view)
                playerViewController.view.frame = videoView.frame
                playerViewController.player?.play()
                //print("Video View " + String(videoView.subviews.count))
                
                if getVideo(videoName: (self.currentStory.local_url)!) == nil
                {
                    storeVideoInDocumentDirectory(videoUrl: video_url, videoName: (self.currentStory.local_url)!)
                }
                
                var _:Any = player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 600), queue: DispatchQueue.main) {
                    [weak self] time in
                    
                    if player.currentItem?.status == AVPlayerItemStatus.readyToPlay {
                        DispatchQueue.main.async {
                            removeLoader()
                        }
                    }
                    else if player.currentItem?.status == AVPlayerItemStatus.failed{
                        self?.killProcess()
                        storeVideoInDocumentDirectory(videoUrl: URL(string: (self?.currentStory.remote_url)!)!, videoName: (self?.currentStory.local_url)!)
                         self?.mediaTimer1 = Timer.init(timeInterval: 3.0, target: self, selector: #selector(self?.playMedia), userInfo: nil, repeats: false)
                   }
                }
            }
            else
            {
                DispatchQueue.main.async {
                    removeLoader()
                }
            }
        }
    }
    
    func checkForBlockUser() -> Bool{
        if(arrUser != nil && AppDelegate().sharedDelegate().isBlockUser(arrUser[mainIndex].uID)){
            subIndex = -1
            displayToast("Unblock user to watch story.")
            DispatchQueue.main.async {
                removeLoader()
            }
            self.killProcess()
            self.mediaTimer = Timer.scheduledTimer(timeInterval: TimeInterval(USERVALUE.STORY_DISPLAY_TIME), target: self, selector: #selector(self.checkForPlayMedia), userInfo: nil, repeats: false)
            return true
        }
        return false
    }
    func getStory() -> StoryModel?
    {
        if arrUser != nil && arrUser.count > mainIndex
        {
            let tempUser = arrUser[mainIndex]
            userLbl.text = "  " + tempUser.name + "  "
            AppDelegate().sharedDelegate().hideUserProfilePopup()
            if subIndex >= 0 && tempUser.story.count > subIndex
            {
                let storyID = tempUser.story[subIndex]
                return AppModel.shared.STORY[storyID]
            }
        }
        
        if arrCourt != nil && arrCourt.count > mainIndex
        {
            let tempCourt = arrCourt[mainIndex]
            userLbl.text = "  " + tempCourt.location.name + "  "
            AppDelegate().sharedDelegate().hideUserProfilePopup()
            if subIndex >= 0 && tempCourt.story.count > subIndex
            {
                let storyID = tempCourt.story[subIndex]
                return AppModel.shared.STORY[storyID]
            }
        }
        
        return nil
    }
    func checkForPlayMedia(_ side:Int = 1)
    {
        if selectedStory != nil
        {
            clickToCloseStory(self)
            return
        }
        if(side == -1){
            if arrUser != nil && mainIndex >= 0
            {
                subIndex += 1
                
                if subIndex == arrUser[mainIndex].story.count
                {
                    AppDelegate().sharedDelegate().dismissReportVC()
                    mainIndex -= 1
                    adDisplayCounter += 1
                    if mainIndex == -1
                    {
                        clickToCloseStory(self)
                        return
                    }
                    else
                    {
                        subIndex = 0
                    }
                }
            }
            else if arrCourt != nil && mainIndex >= 0
            {
                subIndex += 1
                
                if subIndex == arrCourt[mainIndex].story.count
                {
                    AppDelegate().sharedDelegate().dismissReportVC()
                    mainIndex -= 1
                    adDisplayCounter += 1
                    if mainIndex == -1
                    {
                        clickToCloseStory(self)
                        return
                    }
                    else
                    {
                        subIndex = 0
                    }
                }
            }
        }
        else{
            if arrUser != nil && mainIndex < arrUser.count
            {
                subIndex -= 1
                
                if subIndex == -1
                {
                    AppDelegate().sharedDelegate().dismissReportVC()
                    mainIndex += 1
                    adDisplayCounter += 1
                    if arrUser.count <= mainIndex
                    {
                        clickToCloseStory(self)
                        return
                    }
                    else
                    {
                        subIndex = arrUser[mainIndex].story.count - 1
                    }
                }
            }
            else if arrCourt != nil && mainIndex < arrCourt.count
            {
                subIndex -= 1
                
                if subIndex == -1
                {
                    AppDelegate().sharedDelegate().dismissReportVC()
                    mainIndex += 1
                    adDisplayCounter += 1
                    if arrCourt.count <= mainIndex
                    {
                        clickToCloseStory(self)
                        return
                    }
                    else
                    {
                        subIndex = arrCourt[mainIndex].story.count - 1
                    }
                }
            }
        }
        
        
        userLbl.text = ""
        if currentStory.type == 1
        {
            mediaImgBtn.setBackgroundImage(nil, for: .normal)
        }
        else
        {
            playerViewController.player?.pause()
            playerViewController.view.removeFromSuperview()
        }
        
        if interstitial != nil && interstitial.isReady && (adDisplayCounter == 2)
        {
            adDisplayCounter = 0
            self.killProcess()
            AppDelegate().sharedDelegate().hideUserProfilePopup()
            interstitial.present(fromRootViewController: self)
        } else {
            playMedia()
        }
    }
/*
    playerViewController.player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        playerViewController.player?.removeObserver(self, forKeyPath: "status")
        
        if playerViewController.player?.currentItem?.status == AVPlayerItemStatus.readyToPlay {
            DispatchQueue.main.async {
                removeLoader()
            }
        }
        else{
            removeLoader()
            kill()
            AppDelegate().sharedDelegate().downloadVideo( URL(string: currentStory.remote_url)!, name: (self.currentStory.local_url)!)
            playMedia()
        }
    }
    */
    
    //MARK: - Ad
    func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: GOOGLE.INTERSTITIAL_AD_ID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        //print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        //print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        //print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        //print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        //print("interstitialDidDismissScreen")
        killProcess()
        interstitial = createAndLoadInterstitial()
        playMedia()
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        //print("interstitialWillLeaveApplication")
    }
    
    //MARK:- Button action
    
    @IBAction func onLeftBtnTap(_ sender: Any) {
        killProcess()
        checkForPlayMedia(-1)
    }
    
    @IBAction func onRightBtnTap(_ sender: Any) {
        killProcess()
        checkForPlayMedia()
    }
    
    @IBAction func onUserNameBtnTap(_ sender: Any) {
        // code here
        if arrUser != nil && mainIndex < arrUser.count
        {
            AppDelegate().sharedDelegate().setUserProfilePopup(selectedUser: arrUser[mainIndex], isStoryDisplay : false)
        }
    }
    
    @IBAction func clickToCloseStory(_ sender: Any)
    {
        AppDelegate().sharedDelegate().dismissReportVC()
        if isBackAllow == true
        {
            DispatchQueue.main.async {
                removeLoader()
            }
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func clickToSendTo(_ sender: Any)
    {
        isBackAllow = false
        let vc : SendMessageToVC = self.storyboard?.instantiateViewController(withIdentifier: "SendMessageToVC") as! SendMessageToVC
        vc.selectedStory = currentStory
        vc.thumbImage = thumbnalImg
        vc.screenFrom = "DisplayStoryVC"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToReply(_ sender: Any)
    {
        if arrUser == nil
        {
            return
        }
        let index = AppModel.shared.currentUser.contact.index { (contact) -> Bool in
            contact.id == arrUser[mainIndex].uID
        }
        
        if index != nil
        {
            isBackAllow = false
            if arrUser[mainIndex].uID != nil && arrUser[mainIndex].uID != ""
            {
                if AppDelegate().sharedDelegate().isBlockUser(arrUser[mainIndex].uID){
                    displayToast("Unblock for further proceed.")
                }
                else if(AppDelegate().sharedDelegate().isBlockMe(arrUser[mainIndex])){
                    displayToast("Opps, " + arrUser[mainIndex].name + " has blocked you.")
                }
                else{
                    AppDelegate().sharedDelegate().onChannelTap(connectUserId: arrUser[mainIndex].uID)
                }
            }
            else
            {
                displayToast( "Something wrong.")
            }
        }
        else
        {
            displayToast("This user hasn't in your friend list")
        }
    }
    
    
    @IBAction func clickToDelete(_ sender: Any)
    {
        killProcess()
        
        if arrCourt != nil
        {
            for i in 0..<AppModel.shared.currentUser.courts.count
            {
                let index = AppModel.shared.COURTS.index { (tempCourt) -> Bool in
                    
                    tempCourt.location.id == AppModel.shared.currentUser.courts[i]
                }
                
                if index != nil
                {
                    let index1 = AppModel.shared.COURTS[index!].story.index(where: { (tempStory) -> Bool in
                        tempStory == currentStory.id
                    })
                    
                    if index1 != nil
                    {
                        AppModel.shared.COURTS[index!].story.remove(at: index1!)
                        AppDelegate().sharedDelegate().courtRef.child(AppModel.shared.COURTS[index!].location.id).child("story").child(String(index1!)).removeValue()
                        checkForPlayMedia()
                    }
                }
            }
        }
        else if arrUser != nil
        {
            let index = AppModel.shared.currentUser.story.index(where: { (tempStory) -> Bool in
                tempStory == currentStory.id
            })
            
            if index != nil
            {
                AppModel.shared.currentUser.story.remove(at: index!)
                AppDelegate().sharedDelegate().updateCurrentUserData()
            }
            checkForPlayMedia()
        }
    }
    
    
    @IBAction func clickToReport(_ sender: Any)
    {
        if arrUser != nil && mainIndex < arrUser.count
        {
            if let selectedUser : UserModel  = arrUser[mainIndex]{
                AppDelegate().sharedDelegate().reportUser(selectedUser, subject:"Flag User Story", vc: self)
            }
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

extension AVPlayerViewController {
    /// Activity indicator contained nested inside the controller's view.
    var activityIndicator: UIActivityIndicatorView? {
        // Indicator is extracted by traversing the subviews of the controller's `view` property.
        // `AVPlayerViewController`'s view contains a private `AVLoadingIndicatorView` that
        // holds an instance of `UIActivityIndicatorView` as a subview.
        let nestedSubviews: [UIView] = view.subviews
            .flatMap { [$0] + $0.subviews }
            .flatMap { [$0] + $0.subviews }
            .flatMap { [$0] + $0.subviews }
        return nestedSubviews.filter { $0 is UIActivityIndicatorView }.first as? UIActivityIndicatorView
    }
    
    /// Indicating whether the built-in activity indicator is hidden or not.
    var isActivityIndicatorHidden: Bool {
        set {
            activityIndicator?.alpha = newValue ? 0 : 1
        }
        get {
            return activityIndicator?.alpha == 0
        }
    }
}
