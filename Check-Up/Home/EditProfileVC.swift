//
//  EditProfileVC.swift
//  Check-Up
//
//  Created by Amisha on 25/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import PEPhotoCropEditor
import Alamofire
import FirebaseAuth
import GooglePlacePicker

class EditProfileVC: UIViewController, customPopUpDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PECropViewControllerDelegate, GMSPlacePickerViewControllerDelegate,UITextFieldDelegate {

    @IBOutlet var profilePicBtn: UIButton!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var userNameTxt: UITextField!
    @IBOutlet var nameTxt: UITextField!
    @IBOutlet var locationLbl: UILabel!
    @IBOutlet var heightTxt: UITextField!
    @IBOutlet var ageTxt: UITextField!
    @IBOutlet var positionPGBtn: UIButton!
    @IBOutlet var positionSGBtn: UIButton!
    @IBOutlet var positionSFBtn: UIButton!
    @IBOutlet var positionPFBtn: UIButton!
    @IBOutlet var positionCBtn: UIButton!
    @IBOutlet var distanceSlider: UISlider!
    @IBOutlet var distanceLbl: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var deleteProfileBtn: UIButton!
    
    var profileImage : UIImage!
    var CustomPopUp: customPopUp!
    var positionVal : Int!
    var arrLocationData = [AnyObject]()
    var selectedLocation : LocationModel!
    var isHideBackBtn : Bool = false
    var tempCurrUserModel:UserModel!
    
    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            removeLoader()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tempCurrUserModel = UserModel.init(dict: AppModel.shared.currentUser.dictionary())
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(displayUserData), name: NSNotification.Name(rawValue: NOTIFICATION.ON_UPDATE_ALL_USER), object: nil)
        
        //print(AppModel.shared.currentUser.dictionary())
        setUIDesigning()
        backBtn.isHidden = isHideBackBtn
    }

    func setUIDesigning()
    {
        profilePicBtn.addCornerRadius(radius: profilePicBtn.frame.size.width/2)
        
        positionPGBtn.isSelected = false
        positionSGBtn.isSelected = false
        positionSFBtn.isSelected = false
        positionPFBtn.isSelected = false
        positionCBtn.isSelected = false
        
        logoutBtn.addCornerRadius(radius: 5.0)
        logoutBtn.applyBorder(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        
        deleteProfileBtn.addCornerRadius(radius: deleteProfileBtn.frame.size.width/2)
        displayUserData()
    }
    
        
    func displayUserData()
    {
        /*["uID": kEpu9P4meaT18n94aN0EZ1UVBqH2, "name": test, "email": testyear17@gmail.com, "local_pic_url": 525299150, "age": 25, "username": testyear17, "latitude": 21.1702, "height": 5, "location": Surat, Gujarat, India, "position": 3, "password": qqqqqq, "distance": 40, "remote_pic_url": , "login_type": 1, "user_type": 1, "longitude": 72.8311]*/
        
        //1. positionPGBtn, 2. positionSGBtn, 3. positionSFBtn, 4. positionPFBtn, 5. positionCBtn
        
        if profilePicBtn == nil
        {
            return
        }
        
        AppDelegate().sharedDelegate().setUserProfileImage(AppModel.shared.currentUser.uID, button: profilePicBtn)
        
        userNameTxt.text = AppModel.shared.currentUser.username
        nameTxt.text = AppModel.shared.currentUser.name
        locationLbl.text = AppModel.shared.currentUser.location.address
        heightTxt.text = AppModel.shared.currentUser.height
        if(AppModel.shared.currentUser.age == 0){
            ageTxt.text =  "";
        }
        else{
            ageTxt.text = String(format: "%d", AppModel.shared.currentUser.age)
        }
        
        
        switch AppModel.shared.currentUser.position {
            case 1:
                positionPGBtn.isSelected = true
                break
            case 2:
                positionSGBtn.isSelected = true
                break
            case 3:
                positionSFBtn.isSelected = true
                break
            case 4:
                positionPFBtn.isSelected = true
                break
            case 5:
                positionCBtn.isSelected = true
                break
            default:
                break
        }
        
        positionVal = AppModel.shared.currentUser.position
        distanceSlider.value = Float(AppModel.shared.currentUser.distance)
        distanceLbl.text = String(format: "%0.0f mi", distanceSlider.value)
        
        selectedLocation = AppModel.shared.currentUser.location
        
        emailTxt.text = AppModel.shared.currentUser.email
        
    }
    
    @IBAction func clickToBack(_ sender: Any)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToUserProfilePic(_ sender: Any)
    {
        self.view.endEditing(true)
        openCustomPopup()
        
    }
    
    @IBAction func clickToSelectPosition(_ sender: UIButton) {
        
        positionPGBtn.isSelected = false
        positionSGBtn.isSelected = false
        positionSFBtn.isSelected = false
        positionPFBtn.isSelected = false
        positionCBtn.isSelected = false
        switch sender {
        case positionPGBtn:
            positionPGBtn.isSelected = true
            positionVal = 1
            break
        case positionSGBtn:
            positionSGBtn.isSelected = true
            positionVal = 2
            break
        case positionSFBtn:
            positionSFBtn.isSelected = true
            positionVal = 3
            break
        case positionPFBtn:
            positionPFBtn.isSelected = true
            positionVal = 4
            break
        case positionCBtn:
            positionCBtn.isSelected = true
            positionVal = 5
            break
        default:
            break
        }
    }
    
    @IBAction func clickToSelectLocation(_ sender: UIButton) {
        self.view.endEditing(true)
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    @IBAction func clickToChangeDistance(_ sender: Any)
    {
        distanceLbl.text = String(format: "%0.0f mi", distanceSlider.value)
    }
    
    @IBAction func clickToLogout(_ sender: Any)
    {
        let alertConfirmation = UIAlertController(title: "CheckUp", message: "Are you sure want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        let noAction = UIAlertAction (title: "NO", style: UIAlertActionStyle.cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "YES", style: .default) { (action) in
            
            AppDelegate().sharedDelegate().logout()
        }
        alertConfirmation.addAction(noAction)
        alertConfirmation.addAction(yesAction)
        
        self.present(alertConfirmation, animated: true, completion: nil)
    }
    
    @IBAction func clickToDeleteProfile(_ sender: Any)
    {
        self.view.endEditing(true)
        
        let alertConfirmation = UIAlertController(title: "CheckUp", message: "Are you sure want to delete your account?", preferredStyle: UIAlertControllerStyle.alert)
        let noAction = UIAlertAction (title: "NO", style: UIAlertActionStyle.cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "YES", style: .default) { (action) in

            Auth.auth().currentUser?.delete(completion: { (error) in
                if error != nil
                {
                    displayToast( (error?.localizedDescription)!)
                }
                else
                {
                    displayToast("Account deleted successfully.")
                    AppDelegate().sharedDelegate().logout()
                }
            })
        }
        alertConfirmation.addAction(noAction)
        alertConfirmation.addAction(yesAction)
        
        self.present(alertConfirmation, animated: true, completion: nil)
    }
    
    
    @IBAction func clickToUpdate(_ sender: Any)
    {
        if userNameTxt.text?.count == 0 {
            displayToast( "Please enter username.")
        }
        else if nameTxt.text?.count == 0 {
            displayToast("Please enter name.")
        }
//        else if locationLbl.text?.count == 0 {
//            displayToast(view: self.view, message: "Please enter location.")
//        }
//        else if heightTxt.text?.count == 0 {
//            displayToast(view: self.view, message: "Please enter height.")
//        }
//        else if ageTxt.text?.count == 0 {
//            displayToast(view: self.view, message: "Please enter age.")
//        }
        else if emailTxt.text?.count == 0 {
            displayToast( "Please enter email.")
        }
        else
        {
            var imageName = ""
            if profileImage != nil
            {
                imageName = getCurrentTimeStampValue()
                storeImageInDocumentDirectory(image: profileImage, imageName: imageName)
            }
            
            tempCurrUserModel.username = userNameTxt.text
            tempCurrUserModel.name = nameTxt.text
            tempCurrUserModel.location = selectedLocation
            tempCurrUserModel.height = heightTxt.text
            tempCurrUserModel.age = ageTxt.text! == "" ? 0 : Int(ageTxt.text!)!
            tempCurrUserModel.position = positionVal
            tempCurrUserModel.distance = Int(distanceSlider.value)
            if imageName.count > 0
            {
                tempCurrUserModel.local_pic_url = imageName
                tempCurrUserModel.remote_pic_url = ""
            }
            
            
            displayLoader()
            if emailTxt.text != tempCurrUserModel.email
            {
                changeEmailAddress()
            }
            else if (passwordTxt.text?.count)! > 0
            {
                changePassword()
            }
            else
            {
                continueToEditProfile()
            }
        }
    }
    
    func continueToEditProfile()
    {
        tempCurrUserModel.email = emailTxt.text
        AppModel.shared.currentUser = tempCurrUserModel
        AppDelegate().sharedDelegate().updateCurrentUserData()
        displayToast( "Profile updated successfully")
        _ = self.navigationController?.popViewController(animated: true)
        
        AppDelegate().sharedDelegate().getCourtNearByMe()
        removeLoader()
    }
    
    func changeEmailAddress()
    {
        if emailTxt.text != tempCurrUserModel.email
        {
            Auth.auth().currentUser?.updateEmail(to: emailTxt.text!, completion: { (error) in
                if (error != nil)
                {
                    removeLoader()
                    displayToast( "Please relogin and try again.")
                }
                else
                {
                    if (self.passwordTxt.text?.count)! > 0
                    {
                        self.changePassword()
                    }
                    else
                    {
                        self.continueToEditProfile()
                    }
                    
                }
            })
        }

    }
    
    func changePassword()
    {
        if (passwordTxt.text?.count)! > 0
        {
            Auth.auth().currentUser?.updatePassword(to: passwordTxt.text!, completion: { (error) in
                if (error != nil)
                {
                    removeLoader()
                    displayToast((error?.localizedDescription)!)
                }
                else
                {
                    self.continueToEditProfile()
                }
            })
        }
    }
    
    //MARK:- textfield delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == userNameTxt && (string == " ") {
            displayToast("Space not allowed.")
            return false
        }
        return true
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
        //imgPicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
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
        let selectedImage: UIImage? = (info["UIImagePickerControllerOriginalImage"] as? UIImage)
        if selectedImage == nil {
            return
        }
        let controller = PECropViewController()
        controller.delegate = self as PECropViewControllerDelegate
        controller.image = selectedImage
        controller.keepingCropAspectRatio = true
        controller.toolbarHidden = true
        let width: CGFloat? = selectedImage?.size.width
        let height: CGFloat? = selectedImage?.size.height
        let length: CGFloat = min(width!, height!)
        controller.imageCropRect = CGRect(x: CGFloat((width! - length) / 2), y: CGFloat((height! - length) / 2), width: length, height: length)
        let navigationController = UINavigationController(rootViewController: controller)
        self.present(navigationController, animated: true, completion: { _ in })
    }
    
    func cropViewController(_ controller: PECropViewController, didFinishCroppingImage croppedImage: UIImage) {
        controller.dismiss(animated: true, completion: { _ in })
        // Adjusting Image Orientation
        let imgCompress: UIImage? = compressImage(croppedImage, to: CGSize(width: CGFloat(IMAGESIZE.IMAGE_WIDTH), height: CGFloat(IMAGESIZE.IMAGE_HEIGHT)))
        profilePicBtn.setBackgroundImage(croppedImage, for: .normal)
        profileImage = imgCompress!
    }
    
    func cropViewControllerDidCancel(_ controller: PECropViewController) {
        controller.dismiss(animated: true, completion: { _ in })
    }

    
    //MARK: - Google Place Picker
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        if place.formattedAddress == nil
        {
            displayToast( "We can not find your location. Please select again.")
        }
        else
        {
            self.selectedLocation = LocationModel.init(id: "", name: "", image: "", address: place.formattedAddress!, latitude: Float(place.coordinate.latitude), longitude: Float(place.coordinate.longitude), isOpen: true)
            self.locationLbl.text = self.selectedLocation.address
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
