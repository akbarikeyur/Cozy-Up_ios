//
//  Utility.swift
//  TeacupPuppies
//
//  Created by Amisha on 03/07/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit
import AVFoundation

class Utility: NSObject {
    
}

//MARK: - Local save
func getDirectoryPath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func storeImageInDocumentDirectory(image : UIImage, imageName : String)
{
    let imgName = imageName + ".png"
    let fileManager = FileManager.default
    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgName)
    //print(paths)
    let imageData = UIImagePNGRepresentation(image)
    fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
}

func getImage(imageName : String) -> UIImage?
{
    let imgName = imageName + ".png"
    let fileManager = FileManager.default
    let imagePAth = (getDirectoryPath() as NSString).appendingPathComponent(imgName)
    if fileManager.fileExists(atPath: imagePAth){
        return UIImage(contentsOfFile: imagePAth)!
    }else{
        return nil
    }
}

func deleteImage(fromDirectory imageName: String) -> Bool {
    if imageName.count == 0 {
        return true
    }
    let imgName = imageName + (".png")
    let fileManager = FileManager.default
    
    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgName)
    
    if fileManager.fileExists(atPath: paths){
        try! fileManager.removeItem(atPath: paths)
        return true
    }else{
        print("Something wronge.")
        return false
    }
}

func storeVideoInDocumentDirectory(videoUrl : URL, videoName : String)
{
    let video_name = videoName + ".mp4"
    let fileManager = FileManager.default
    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(video_name)
    //print(paths)
    let videoData = try? Data(contentsOf: videoUrl)
    fileManager.createFile(atPath: paths as String, contents: videoData, attributes: nil)
}

func getVideo(videoName : String) -> String?
{
    let video_name = videoName + ".mp4"
    let fileManager = FileManager.default
    let videoPAth = (getDirectoryPath() as NSString).appendingPathComponent(video_name)
    if fileManager.fileExists(atPath: videoPAth){
        return videoPAth
    }else{
        return nil
    }
}

func deleteVideo(fromDirectory videoName: String) -> Bool {
    if videoName.count == 0 {
        return true
    }
    let video_Name = videoName + (".mp4")
    let fileManager = FileManager.default
    
    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(video_Name)
    
    if fileManager.fileExists(atPath: paths){
        try! fileManager.removeItem(atPath: paths)
        return true
    }else{
        print("Something wronge.")
        return false
    }
}


//MARK:- Image
public func compressImage(_ image: UIImage, to toSize: CGSize) -> UIImage {
    var actualHeight: Float = Float(image.size.height)
    var actualWidth: Float = Float(image.size.width)
    let maxHeight: Float = Float(toSize.height)
    //600.0;
    let maxWidth: Float = Float(toSize.width)
    //800.0;
    var imgRatio: Float = actualWidth / actualHeight
    let maxRatio: Float = maxWidth / maxHeight
    //50 percent compression
    if actualHeight > maxHeight || actualWidth > maxWidth {
        if imgRatio < maxRatio {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight
            actualWidth = imgRatio * actualWidth
            actualHeight = maxHeight
        }
        else if imgRatio > maxRatio {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth
            actualHeight = imgRatio * actualHeight
            actualWidth = maxWidth
        }
        else {
            actualHeight = maxHeight
            actualWidth = maxWidth
        }
    }
    let rect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(actualWidth), height: CGFloat(actualHeight))
    UIGraphicsBeginImageContext(rect.size)
    image.draw(in: rect)
    let img: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
    let imageData1: Data? = UIImageJPEGRepresentation(img!, CGFloat(IMAGESIZE.IMAGE_QUALITY))
    UIGraphicsEndImageContext()
    return UIImage(data: imageData1!)!
}

func generateThumbImage(VideoName : String) -> String
{
    let imgName = VideoName + ".mp4"
    let videoPAth = (getDirectoryPath() as NSString).appendingPathComponent(imgName)
    
    
    let asset = AVURLAsset(url: URL(fileURLWithPath: videoPAth))
    let imgGenerator = AVAssetImageGenerator(asset: asset)
    
    let fileName : String = getCurrentTimeStampValue()
    let cgImage : CGImage!
    do {
        cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 60), actualTime: nil)
        let thumbnail : UIImage = UIImage.init(cgImage: cgImage)
        storeImageInDocumentDirectory(image: thumbnail, imageName: fileName)
        return fileName
    } catch _ as NSError {
        return ""
    }
}

func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
    //Calculate the size of the rotated view's containing box for our drawing space
    let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
    let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
    rotatedViewBox.transform = t
    let rotatedSize: CGSize = rotatedViewBox.frame.size
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize)
    let bitmap: CGContext = UIGraphicsGetCurrentContext()!
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
    //Rotate the image context
    bitmap.rotate(by: (degrees * CGFloat.pi / 180))
    //Now, draw the rotated/scaled image into the context
    bitmap.scaleBy(x: 1.0, y: -1.0)
    bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
}
func imageWithColor(color:UIColor) -> UIImage
{
    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    UIGraphicsBeginImageContext(rect.size)
    let context: CGContext? = UIGraphicsGetCurrentContext()
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}

//MARK:- video
func compressLocalVideo(_ videoName : String, completionHandler : @escaping (_ session:AVAssetExportSession) ->())
{
    let videoUrl : URL = URL(fileURLWithPath : getVideo(videoName: videoName)!)
    let urlAsset = AVURLAsset(url: videoUrl)
    //print("\n\nInput Path :" + videoUrl.absoluteString)
    
    let videoPAth = (getDirectoryPath() as NSString).appendingPathComponent(getCurrentTimeStampValue() + ".mp4")
    let output_url = URL(fileURLWithPath : videoPAth)
    
    //print("Output Path : " + (output_url.absoluteString))
    
    if let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset640x480)
    {
        exportSession.outputURL = output_url
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            completionHandler(exportSession)
        }
    }
}



//MARK:- App function
func sortUsers(_ arr:[UserModel]) -> [UserModel]{
    if arr.count > 1
    {
        return arr.sorted(by: { (user1, user2) -> Bool in
            user1.username < user2.username
        })
    }
    return arr
}
func isTodayEvent(event:EventModel) -> Bool
{
    let strEventDate : String = event.maxDate
    let eventDate : Date = getDateTimeFromFCM(strEventDate)
    
    let calendar = NSCalendar.current
    
    let eventComponents = calendar.dateComponents([.day, .month, .year], from: eventDate)
    let todayComponents = calendar.dateComponents([.day, .month, .year], from: getCurrentDate())
    
    if eventComponents.day == todayComponents.day && eventComponents.month == todayComponents.month && eventComponents.year == todayComponents.year
    {
        return true
    }
    return false
}

func isPastEvent(event:EventModel) -> Bool
{
    let strEventDate : String = event.maxDate
    let eventDate : Date = getDateTimeFromFCM(strEventDate)
    
    let calendar = NSCalendar.current
    // Replace the hour (time) of both dates with 00:00
    let date1 = calendar.startOfDay(for: eventDate)
    let date2 = calendar.startOfDay(for: getCurrentDate())
    
    let components = calendar.dateComponents([.hour], from: date1, to: date2)
    if components.hour! > 24
    {
        return true
    }
    return false
}
func isEventExpired(event:EventModel) -> Bool
{
    let strEventDate : String = event.maxDate
    let eventDate : Date = getDateTimeFromFCM(strEventDate)
    
    let calendar = NSCalendar.current
    // Replace the hour (time) of both dates with 00:00
    let date1 = calendar.startOfDay(for: eventDate)
    let date2 = calendar.startOfDay(for: getCurrentDate())
    
    let components = calendar.dateComponents([.hour], from: date1, to: date2)
    if components.hour! > 0
    {
        return true
    }
    return false
}

func isPastStory(story:StoryModel) -> Bool
{
    let storyDate : Date = getDateTimeFromFCM(story.date)
    
    let calendar = NSCalendar.current
    
    // Replace the hour (time) of both dates with 00:00
    let date1 = calendar.startOfDay(for: storyDate)
    let date2 = calendar.startOfDay(for: getCurrentDate())
    
    let components = calendar.dateComponents([.hour], from: date1, to: date2)
    if components.hour! > 24
    {
        return true
    }
    return false
}

func isPastCourt(strDate:String) -> Bool
{
    let storyDate : Date = getDateTimeFromFCM(strDate)
    let calendar = NSCalendar.current
    
    // Replace the hour (time) of both dates with 00:00
    let date1 = calendar.startOfDay(for: storyDate)
    let date2 = calendar.startOfDay(for: getCurrentDate())
    
    let components = calendar.dateComponents([.hour], from: date1, to: date2)
    if components.hour! > 24
    {
        return true
    }
    return false
}


//MARK: - UIColor from Hex
func colorWithHexString(_ stringToConvert:String, alpha:CGFloat) -> UIColor {
    
    var cString:String = stringToConvert.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: alpha
    )
}

func colorFromHex(hex : String) -> UIColor
{
    return colorWithHexString(hex, alpha: 1.0)
}

func colorFromHex(hex : String, alpha:CGFloat) -> UIColor
{
    return colorWithHexString(hex, alpha: alpha)
}

//MARK: - UI Func

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func displayLoader()
{
    AppDelegate().sharedDelegate().displayActivityLoader()
}

func removeLoader()
{
    AppDelegate().sharedDelegate().removeActivityLoader()
}
func displaySubViewtoParentView(_ parentview: UIView! , subview: UIView!)
{
    subview.translatesAutoresizingMaskIntoConstraints = false
    parentview.addSubview(subview);
    parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: parentview, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
    parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: parentview, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
    parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: parentview, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
    parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: parentview, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    parentview.layoutIfNeeded()
    
}

func displayToast(_ message:String)
{
    if(AppModel.shared.isKeyboardOpen){
        UIApplication.shared.windows.last!.makeToast(message)
    }
    else{
        AppDelegate().sharedDelegate().window?.makeToast(message)
    }
}

func displayErrorAlertView(title : String, message : String)
{
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(okayAction)
    AppDelegate().sharedDelegate().window?.rootViewController?.present(alertController, animated: true, completion: nil)
}


func setButtonImageColor(button:UIButton, color:String)
{
    let tintedImage = button.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    button.setImage(tintedImage, for: .normal)
    button.tintColor = colorFromHex(hex: color)
}



//MARK:- Date/Time

func getCurrentTimeStampValue() -> String
{
    return String(format: "%0.0f", Date.timeIntervalSinceReferenceDate*1000)
}

func sendDateToFCM(_ date : Date) -> String
{
    let dateFormmat = DateFormatter()
    dateFormmat.dateFormat = FORMAT.FCM_DATE
    dateFormmat.timeZone = TimeZone(identifier: "UTC")
    return dateFormmat.string(from: date)
}

func sendDateTimeToFCM(_ date : Date) -> String
{
    let dateFormmat = DateFormatter()
    dateFormmat.dateFormat = FORMAT.FCM_DATETIME
    dateFormmat.timeZone = TimeZone(identifier: "UTC")
    return dateFormmat.string(from: date)
}

func getDateStringFromFCM(_ strDate : String) -> String
{
    var dateFormmat = DateFormatter()
    dateFormmat.dateFormat = FORMAT.FCM_DATE
    dateFormmat.timeZone = TimeZone(identifier: "UTC")
    
    let date : Date = dateFormmat.date(from: strDate)!
    dateFormmat = DateFormatter()
    dateFormmat.dateFormat = FORMAT.DISPLAY_DATE
    dateFormmat.timeZone = TimeZone.current
    return dateFormmat.string(from: date)
}

func getTimeStringFromFCM(_ strDate : String) -> String
{
    var dateFormmat = DateFormatter()
    dateFormmat.dateFormat = FORMAT.FCM_DATETIME
    dateFormmat.timeZone = TimeZone(identifier: "UTC")
    
    let date : Date = dateFormmat.date(from: strDate)!
    dateFormmat = DateFormatter()
    dateFormmat.dateFormat = FORMAT.DISPLAY_TIME
    dateFormmat.timeZone = TimeZone.current
    return dateFormmat.string(from: date)
}

func getDateTimeStringFromFCM(_ strDate : String) -> String
{
    let date : Date = getDateTimeFromFCM(strDate)
    var dateFormmat = DateFormatter()
    dateFormmat = DateFormatter()
    dateFormmat.dateFormat = FORMAT.DISPLAY_DATETIME
    dateFormmat.timeZone = TimeZone.current
    return dateFormmat.string(from: date)
}

func getDateTimeFromFCM(_ strDate : String) -> Date
{
    let dateFormmat = DateFormatter()
    dateFormmat.dateFormat = FORMAT.FCM_DATETIME
    dateFormmat.timeZone = TimeZone(identifier: "UTC")
    return dateFormmat.date(from: strDate)!
}

func getFormatedDateStringFromFCM(_ currFormat : String, newFormat : String, date : String) -> String
{
    var dateFormmat = DateFormatter()
    dateFormmat.dateFormat = currFormat
    dateFormmat.timeZone = TimeZone(identifier: "UTC")
    
    let date : Date = dateFormmat.date(from: date)!
    dateFormmat = DateFormatter()
    dateFormmat.dateFormat = newFormat
    dateFormmat.timeZone = TimeZone.current
    return dateFormmat.string(from: date)
}

func getEventUTCDate(_ strDate:String) -> String
{
    var dateFormmat = DateFormatter()
    dateFormmat.dateFormat = FORMAT.FCM_DATETIME
    dateFormmat.timeZone = TimeZone(identifier: "UTC")
    
    let date : Date = dateFormmat.date(from: strDate)!
    dateFormmat = DateFormatter()
    dateFormmat.dateFormat = FORMAT.FCM_DATE
    dateFormmat.timeZone = TimeZone(identifier: "UTC")
    return dateFormmat.string(from: date)
}

func getCurrentDateInString() -> String
{
    let dateFormat = DateFormatter()
    dateFormat.timeZone = TimeZone(identifier: "UTC")
    dateFormat.dateFormat = FORMAT.FCM_DATETIME
    
    return dateFormat.string(from: getCurrentDate())
}

func getCurrentDateInLocalDate() -> Date
{
    let dateFormat = DateFormatter()
    dateFormat.timeZone = TimeZone(identifier: "UTC")
    dateFormat.dateFormat = FORMAT.FCM_DATETIME
    
    return dateFormat.date(from: getCurrentDateInString())!
}


func isSameDate(firstDate : String, secondDate : String) -> Bool
{
    let date1 : String = getFormatedDateStringFromFCM(FORMAT.FCM_DATETIME, newFormat: FORMAT.FCM_DATE, date: firstDate)
    let date2 : String = getFormatedDateStringFromFCM(FORMAT.FCM_DATETIME, newFormat: FORMAT.FCM_DATE, date: secondDate)
    
    if date1 == date2
    {
        return true
    }
    return false
}

func getCurrentDate() -> Date
{
    return Date()
}

func getDifferenceFromCurrentTime(date : String) -> Int
{
    let newDate : Date = getDateTimeFromFCM(date)
    let currentDate : Date = getCurrentDate()
    let interval = currentDate.timeIntervalSince(newDate)
    return Int(interval)
}

func getDifferenceToCurrentTime(date : String) -> Int
{
    let newDate : Date = getDateTimeFromFCM(date)
    let currentDate : Date = getCurrentDate()
    let interval = newDate.timeIntervalSince(currentDate)
    return Int(interval)
}

func getDifferenceFromCurrentTimeInHourInDays(date : String) -> String
{
    let interval : Int = Int(getDifferenceFromCurrentTime(date: date))
    
    let second : Int = interval
    let minutes : Int = interval/60
    let hours : Int = interval/(60*60)
    let days : Int = interval/(60*60*24)
    let week : Int = interval/(60*60*24*7)
    let months : Int = interval/(60*60*24*30)
    let years : Int = interval/(60*60*24*30*12)
    
    var timeAgo : String = ""
    if  second < 60
    {
        timeAgo = (second < 3) ? "Just Now" : (String(second) + "s")
    }
    else if minutes < 60
    {
        timeAgo = String(minutes) + "m"
    }
    else if hours < 60
    {
        timeAgo = String(hours) + "h"
    }
    else if days < 30
    {
        timeAgo = String(days) + " "  + ((days > 1) ? "days" : "day")
    }
    else if week < 4
    {
        timeAgo = String(week) + " "  + ((week > 1) ? "weeks" : "week")
    }
    else if months < 12
    {
        timeAgo = String(months) + " "  + ((months > 1) ? "months" : "month")
    }
    else
    {
        timeAgo = String(years) + " "  + ((years > 1) ? "years" : "year")
    }
    
    if second > 3 {
        timeAgo = timeAgo + " ago"
    }
    return timeAgo
}

func getdayDifferenceFromCurrentDay(_ strDate : String) -> String
{
    let calendar = NSCalendar.current
    let date1 = calendar.startOfDay(for: getDateTimeFromFCM(strDate))
    let date2 = calendar.startOfDay(for: getCurrentDate())
    
    let components = calendar.dateComponents([.day], from: date1, to: date2)
    
    var timeAgo : String = ""
    if components.day == 0
    {
        timeAgo = "TODAY"
    }
    else if components.day == 1
    {
        timeAgo = "YESTERDAY"
    }
    else
    {
        timeAgo = getFormatedDateStringFromFCM(FORMAT.FCM_DATETIME, newFormat: FORMAT.DISPLAY_DATE, date: strDate)
    }
    
    return timeAgo
}



//MARK: - Encode Decode
func getAsciiUtf8EncodedString(_ stringToEncode: String) -> String {
    let data: Data? = stringToEncode.data(using: String.Encoding.nonLossyASCII)
    let Value = String(data: data!, encoding: String.Encoding.utf8)
    return Value ?? ""
}

func getAsciiUtf8DecodedString(_ stringToDecode: String) -> String
{
    let strToDecode = stringToDecode.replacingOccurrences(of: "\\n", with: "")
    let data: Data? = strToDecode.data(using: String.Encoding.utf8)
    let Value = String(data: data!, encoding: String.Encoding.nonLossyASCII)
    if Value == nil {
        return stringToDecode
    }
    return Value ?? ""
}

//MARK: - UITextField Method
extension UITextField
{
    func addPadding(padding: CGFloat)
    {
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: padding, height: self.frame.height)
        
        self.leftView = leftView
        self.leftViewMode = .always
    }
    
    func addViewCornerRadius(radius: CGFloat)
    {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func applyBorder(width: CGFloat, borderColor: UIColor)
    {
        self.layer.borderWidth = width
        self.layer.borderColor = borderColor.cgColor
    }
    
    func setPlaceHolderColor(color:UIColor)
    {
        self.setValue(color, forKeyPath: "_placeholderLabel.textColor")
    }
}




//MARK: - UILable Method
extension UILabel
{
    func addCornerRadiusForLabel(radius: CGFloat)
    {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func applyBorderForLabel(width: CGFloat, borderColor: UIColor)
    {
        self.layer.borderWidth = width
        self.layer.borderColor = borderColor.cgColor
    }
    
    func getLableHeight() -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        
        return label.frame.height
    }
}

//MARK: - UITextView Method
extension UITextView
{
    func addCornerRadiusForTextView(radius: CGFloat)
    {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func applyBorderForTextView(width: CGFloat, borderColor: UIColor)
    {
        self.layer.borderWidth = width
        self.layer.borderColor = borderColor.cgColor
    }
    
//    func getTextViewHeightWidth(txtWidth:Float) -> CGFloat{
//        
//        let sizeThatFitsTextView:CGSize = self.sizeThatFits(CGSize(width: txtWidth, height: MAXFLOAT))
//        return sizeThatFitsTextView.height
//    }
    
}

//MARK: - UIButton Method
extension UIButton
{
    func addCornerRadius(radius: CGFloat)
    {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func applyBorder(width: CGFloat, borderColor: UIColor)
    {
        self.layer.borderWidth = width
        self.layer.borderColor = borderColor.cgColor
    }
}

//MARK: - UIView Method
extension UIView
{
    func addCornerRadiusOfView(radius: CGFloat)
    {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func applyBorderOfView(width: CGFloat, borderColor: UIColor)
    {
        self.layer.borderWidth = width
        self.layer.borderColor = borderColor.cgColor
    }
}

//MARK: - String Method
extension String
{
    var isValidEmail: Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    
    var encodeString : String
    {
        return getAsciiUtf8EncodedString(self)
    }
    
    var decodeString : String
    {
        return getAsciiUtf8DecodedString(self)
    }
}
