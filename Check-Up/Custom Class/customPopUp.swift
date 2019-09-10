//
//  customPopUp.swift
//  WhereAreYou
//
//  Created by WeeTech MAC on 13/02/17.
//  Copyright © 2017 WeeTech MAC. All rights reserved.
//

import UIKit

@objc protocol customPopUpDelegate
{
    @objc optional func closeToClick()
    @objc optional func captureCameraImage()
    @objc optional func selectGalleryImage()
    @objc optional func removeImage()
}

class customPopUp: UIViewController {

    var delegate:customPopUpDelegate?
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupTitleLbl: UILabel!
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var cameraLbl: UILabel!
    @IBOutlet weak var constraintWidthCameraView: NSLayoutConstraint!
    
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var galleryBtn: UIButton!
    @IBOutlet weak var galleryLbl: UILabel!
    @IBOutlet weak var constraintWidthGalleryView: NSLayoutConstraint!
    
    @IBOutlet weak var removeView: UIView!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var removeLbl: UILabel!
    @IBOutlet weak var constraintWidthRemoveImageView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUIDesigning()
    }

    func setUIDesigning()
    {
        popupView.layer.cornerRadius = 10.0
        popupView.layer.masksToBounds = true
        
        popupTitleLbl.text = NSLocalizedString("select_image", comment: "")
        cameraLbl.text = NSLocalizedString("capture_camera", comment: "")
        galleryLbl.text = NSLocalizedString("select_from_gallery", comment: "")
        removeLbl.text = NSLocalizedString("remove_image", comment: "")
    }
    
    
    @IBAction func clickToClosePopup(_ sender: UIButton)
    {
        delegate?.closeToClick!()
    }
    
    @IBAction func clickToCamera(_ sender: UIButton)
    {
        delegate?.captureCameraImage!()
    }
    
    @IBAction func clickToGallery(_ sender: UIButton)
    {
        delegate?.selectGalleryImage!()
    }
    
    @IBAction func clickToRemoveImage(_ sender: UIButton)
    {
        delegate?.removeImage!()
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
