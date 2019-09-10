//
//  CaptureStoryVC.swift
//  Check-Up
//
//  Created by Amisha on 29/09/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import PEPhotoCropEditor
import AVFoundation
import AssetsLibrary
import IQKeyboardManagerSwift

class CaptureStoryVC: SwiftyCamViewController, SwiftyCamViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoEditorDelegate {

    @IBOutlet weak var captureButton: SwiftyRecordButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var flashLightBtn: UIButton!
    @IBOutlet weak var reverseCameraBtn: UIButton!
    
    var selectedStory : StoryModel!
    var photoEditor:PhotoEditorViewController!

    override func viewWillAppear(_ animated: Bool) {
        
        if Preference.sharedInstance.getDataFromPreference(key: "isBackScreen") != nil && (Preference.sharedInstance.getDataFromPreference(key: "isBackScreen") as! Bool) == true
        {
            Preference.sharedInstance.setDataToPreference(data: false as AnyObject, forKey: "isBackScreen")
            _ = self.navigationController?.popViewController(animated: false)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: session)


        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.cameraDelegate = self
            self.maximumVideoDuration = 20.0
            self.shouldUseDeviceOrientation = true
            self.allowAutoRotate = false
            self.audioEnabled = true
            self.captureButton.delegate = self
        }
    }
  
    func sessionWasInterrupted(_ notification: Notification) {
        print("session was interrupted")
        /*
        if (session == nil){
            return
        }
        for input in session.inputs{
            if let input1 = input as? AVCaptureDeviceInput{
                let input2:AVCaptureDeviceInput = input1 as! AVCaptureDeviceInput
                let device: AVCaptureDevice? = input2.device
                session.removeInput(input1)
                //if device?.hasMediaType(AVMediaTypeAudio) ?? false {
                    
                //}
            }
        }
 */
    }
    
    func sessionInterruptionEnded(_ notification: Notification) {
        //print("session interuption ended")
    }

    @IBAction func clickToFlashLight(_ sender: Any)
    {
        flashEnabled = !flashEnabled
        
        if flashEnabled == true {
            flashLightBtn.isSelected = true
        } else {
            flashLightBtn.isSelected = false
        }
    }
    
    @IBAction func clickToReverseCamera(_ sender: Any)
    {
        switchCamera()
    }
    
    //MARK : - Swift Cam Delegate
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        //print("Did Begin Recording")
        captureButton.growButton()
        UIView.animate(withDuration: 0.25, animations: {
            self.flashLightBtn.alpha = 0.0
            self.reverseCameraBtn.alpha = 0.0
        })
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        //print("Did finish Recording")
        captureButton.shrinkButton()
        UIView.animate(withDuration: 0.25, animations: {
            self.flashLightBtn.alpha = 1.0
            self.reverseCameraBtn.alpha = 1.0
        })
    }
    
    
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        if(captureButton.timer != nil){
           captureButton.timerFinished()
        }
        else{
            let focusView = UIImageView(image: UIImage.init(named: "focus"))
            focusView.center = point
            focusView.alpha = 0.0
            view.addSubview(focusView)
            
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
                focusView.alpha = 1.0
                focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            }, completion: { (success) in
                UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                    focusView.alpha = 0.0
                    focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
                }, completion: { (success) in
                    focusView.removeFromSuperview()
                })
            })
        }
        
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        //print(zoom)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        //print(camera)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        //print(error)
    }
    
    //get image
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        
        DispatchQueue.main.async {
            if(self.captureButton.timer != nil){
                self.captureButton.timerFinished()
            }
            else{
                self.openEditor(photo, url: nil)
            }
            
        }
    }
    
    func openEditor(_ image:UIImage? = nil , url:URL? = nil)
    {
        photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor.photoEditorDelegate = self
        photoEditor.image = image
        photoEditor.url = url
        //Colors for drawing and Text, If not set default values will be used
        //photoEditor.colors = [.red,.blue,.green]
        //Stickers that the user will choose from to add on the image
        for i in 1...9 {
            photoEditor.stickers.append(UIImage(named: i.description )!)
        }
        //To hide controls - array of enum control
        //photoEditor.hiddenControls = [.crop, .draw, .share]
        present(photoEditor, animated: true, completion: nil)
    }
    
    func doneEditing(image: UIImage) {
       
        let vc : SendStoryVC = self.storyboard?.instantiateViewController(withIdentifier: "SendStoryVC") as! SendStoryVC
        vc.url = photoEditor.url
        vc.thumbImage = image
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func canceledEditing() {
        //print("Canceled")
    }
    
    
    //get video
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL)
    {
        DispatchQueue.main.async {
            AppDelegate().sharedDelegate().isStoryFromGallary = false
            self.openEditor(nil, url: url)
        }
    }

    @IBAction func clickToCloseStory(_ sender: Any)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToSelectImageVideoFromGallery(_ sender: Any)
    {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = .photoLibrary
        imgPicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.present(imgPicker, animated: true, completion: {() -> Void in
        })
    }
    
    func imagePickerController(_ imgPicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Picking Image from Camera/ Library
        imgPicker.dismiss(animated: true, completion: {() -> Void in
        })
        
        if let selectedImage: UIImage = (info["UIImagePickerControllerOriginalImage"] as? UIImage)
        {
            let imgCompress: UIImage = compressImage(selectedImage, to: CGSize(width: CGFloat(IMAGESIZE.IMAGE_WIDTH), height: CGFloat(IMAGESIZE.IMAGE_HEIGHT)))
            openEditor(imgCompress, url: nil)
//            let controller = PECropViewController()
//            controller.delegate = self as PECropViewControllerDelegate
//            controller.image = selectedImage
//            controller.keepingCropAspectRatio = true
//            controller.toolbarHidden = true
//            let width: CGFloat? = selectedImage.size.width
//            let height: CGFloat? = selectedImage.size.height
//            let length: CGFloat = min(width!, height!)
//            controller.imageCropRect = CGRect(x: CGFloat((width! - length) / 2), y: CGFloat((height! - length) / 2), width: length, height: length)
//            let navigationController = UINavigationController(rootViewController: controller)
//            self.present(navigationController, animated: true, completion: { _ in })

        }
        else if let videoURL = info[UIImagePickerControllerMediaURL] as? URL
        {
            AppDelegate().sharedDelegate().isStoryFromGallary = true
            openEditor(nil, url: videoURL)
        }
        else{
            return
        }
        
        
    }
//    func cropViewController(_ controller: PECropViewController, didFinishCroppingImage croppedImage: UIImage) {
//        controller.dismiss(animated: true, completion: { _ in })
//
//        let imgCompress: UIImage = compressImage(croppedImage, to: CGSize(width: CGFloat(IMAGESIZE.IMAGE_WIDTH), height: CGFloat(IMAGESIZE.IMAGE_HEIGHT)))
//        openEditor(imgCompress, url: nil)
//    }
    
//    func cropViewControllerDidCancel(_ controller: PECropViewController) {
//        controller.dismiss(animated: true, completion: { _ in })
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    func convertVideoToLowQuailty(withInputURL inputURL: URL, outputURL: URL, handler: @escaping (_: AVAssetExportSession) -> Void)
//    {
//        try? FileManager.default.removeItem(at: outputURL)
//        let asset = AVURLAsset(url: inputURL, options: nil)
//        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetLowQuality)
//        exportSession?.outputURL = outputURL
//        exportSession?.outputFileType = AVFileTypeQuickTimeMovie
//        exportSession?.exportAsynchronously(completionHandler: {(_: Void) -> Void in
//            handler(exportSession!)
//        })
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
