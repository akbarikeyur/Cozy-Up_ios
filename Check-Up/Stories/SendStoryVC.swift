//
//  SendStoryVC.swift
//  Check-Up
//
//  Created by Amisha on 17/09/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class SendStoryVC: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var thumbImage : UIImage!
    var url : URL?
    var player: AVPlayer?
    var playerController : AVPlayerViewController?
    
    var videoName : String = ""
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.player?.pause()
            self.player = nil
            removeLoader()
            AppDelegate().sharedDelegate().window?.isUserInteractionEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if(url != nil){
            
            videoName = getCurrentTimeStampValue()
            storeVideoInDocumentDirectory(videoUrl: url!, videoName: videoName)
            displayLoader()
            AppDelegate().sharedDelegate().window?.isUserInteractionEnabled = false
            displayToast("Compressing video...")
            compressLocalVideo(videoName, completionHandler: { (expSession) in
                removeLoader()
                AppDelegate().sharedDelegate().window?.isUserInteractionEnabled = true
                if(expSession != nil && expSession.outputURL != nil){
                    storeVideoInDocumentDirectory(videoUrl: expSession.outputURL!, videoName: self.videoName)
                }
            })
            self.setvideo(url:url!)
        }
        self.setImageView(image: thumbImage!)
    }
    
    func setImageView(image: UIImage) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
    }
    
    func setvideo(url: URL) {
        
        player = AVPlayer(url: url)
        playerController = AVPlayerViewController()
        
        guard player != nil && playerController != nil else {
            return
        }
        playerController!.showsPlaybackControls = false
        
        playerController!.player = player!
        self.addChildViewController(playerController!)
        videoView.addSubview(playerController!.view)
        playerController!.view.frame = videoView.frame
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
    }
    
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: kCMTimeZero)
            self.player!.play()
        }
    }
    
    @IBAction func clickToBack(_ sender: Any)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToCloseStory(_ sender: Any)
    {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func clickToDownload(_ sender: Any)
    {
        if(url == nil){
            let rect = CGRect(x: 0, y: 0, width: thumbImage.size.width, height: thumbImage.size.height)
            
            UIGraphicsBeginImageContextWithOptions(thumbImage.size, true, 0)
            let context = UIGraphicsGetCurrentContext()
            
            context!.setFillColor(UIColor.white.cgColor)
            context!.fill(rect)
            
            thumbImage.draw(in: rect, blendMode: .normal, alpha: 1)
            let wd = thumbImage.size.width * 0.60
            let ht =  ( wd * 198 ) / 696
            UIImage(named: "watermark_logo")?.draw(in: CGRect(x: (thumbImage.size.width-wd)/2, y: 10, width: wd, height: ht), blendMode: .normal, alpha: 0.5)
            
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIImageWriteToSavedPhotosAlbum(result!, nil, nil, nil)
            displayToast("Story downloaded successfully")
        }
        else{
            let urlVideo = URL(string : getVideo(videoName: videoName)!)
           
            displayLoader()
            Utility_Objective_C.overlayWatermark(thumbImage, video: urlVideo, videoName: getCurrentTimeStampValue(), isWaterMark: true, isStoryFromGallary:AppDelegate().sharedDelegate().isStoryFromGallary, withCompletionHandler: { (url) in
                DispatchQueue.main.async {
                    print(url!)
                    removeLoader()
                    displayToast("Story downloaded successfully")
                }

            }, errorHandler: { (error) in
                DispatchQueue.main.async {
                    print(error!)
                    removeLoader()
                    displayToast(error!)
                }
            })
            
        }
    }
    
    @IBAction func clickToSendMessage(_ sender: Any)
    {
        
    }
    
    @IBAction func clickToSendTo(_ sender: Any)
    {
        let vc : SendMessageToVC = self.storyboard?.instantiateViewController(withIdentifier: "SendMessageToVC") as! SendMessageToVC
        vc.selectedStory = nil
        vc.url = url
        vc.thumbImage = thumbImage
        vc.videoName = videoName
        self.navigationController?.pushViewController(vc, animated: true)
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
