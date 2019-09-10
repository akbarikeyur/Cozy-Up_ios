//
//  UserModel.swift
//  Check-Up
//
//  Created by Amisha on 11/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import Foundation

class AppModel {
    
    static let shared = AppModel()
    
    var currentUser : UserModel!
    var USERS : [UserModel] = [UserModel] ()
    var EVENTS : [EventModel] = [EventModel] ()
    var COURTS : [CourtModel] = [CourtModel] () // checked in
    var PRELOCATED_COURTS : [LocationModel] =  [LocationModel] ()
    var INBOXLIST : [InboxListModel] = [InboxListModel] ()
    var UPLOADING_STORY_QUEUE : [String : String] = [String : String] () // id of story
    var COMMENT : [CommentModel] = [CommentModel] ()
    var STORY : [String : StoryModel] = [String : StoryModel] ()
    var CURRENT_CHECKIN_COURT : CourtModel!
    
    var BADGE_COUNT : Int = 0
    var isKeyboardOpen:Bool = false
    
    func getStoryArrOfDictionary(arr:[StoryModel]) -> [[String:Any]]{ // story
        
        let len:Int = arr.count
        var retArr:[[String:Any]] =  [[String:Any]] ()
        for i in 0..<len{
            retArr.append(arr[i].dictionary())
        }
        return retArr
    }

    func getContactArrOfDictionary(arr:[ContactModel]) -> [[String:Any]]{ // story
        
        let len:Int = arr.count
        var retArr:[[String:Any]] =  [[String:Any]] ()
        for i in 0..<len{
            retArr.append(arr[i].dictionary())
        }
        return retArr
    }
    
    func getCommentArrOfDictionary(arr:[CommentModel]) -> [[String:Any]]{ // story
        
        let len:Int = arr.count
        var retArr:[[String:Any]] =  [[String:Any]] ()
        for i in 0..<len{
            retArr.append(arr[i].dictionary())
        }
        return retArr
    }
    func validateUser(dict : [String : Any]) -> Bool{
        if let uID = dict["uID"] as? String, let email = dict["email"] as? String, let username = dict["username"] as? String, let name = dict["name"] as? String
        {
            if(uID != "" && email != "" && username != "" && name != "" ){
                return true
            }
        }
        return false
    }
    func validateLocation(dict : [String : Any]) -> Bool{
        if let id = dict["id"] as? String, let name = dict["name"] as? String, let latitude = dict["latitude"] as? Float, let longitude = dict["longitude"] as? Float
        {
            if(id != "" && name != "" && latitude != 0.0 && longitude != 0.0){
                return true
            }
        }
        return false
    }
    func validateEvent(dict : [String : Any]) -> Bool{
        if let id = dict["id"] as? String, let uID = dict["uID"] as? String,let location = dict["location"] as? [String:Any]
        {
            if(id != "" && uID != "" && validateLocation(dict: location)){
                return true
            }
        }
        return false
    }
    func validateCourt(dict : [String : Any]) -> Bool{
        if let location = dict["location"] as? [String:Any]
        {
            if(validateLocation(dict: location)){
                return true
            }
        }
        return false
    }
    func validateStory(dict : [String : Any]) -> Bool{
        if let id = dict["id"] as? String, let uID = dict["uID"] as? String
        {
            if(id != "" && uID != ""){
                return true
            }
        }
        return false
    }
    func validateInbox(dict : [String : Any]) -> Bool{
        if let id = dict["id"] as? String, let lastMessage = dict["lastMessage"] as? [String:Any]
        {
            if(id != "" && validateLastMessage(dict:lastMessage)){
                return true
            }
        }
        return false
    }
    func validateLastMessage(dict : [String : Any]) -> Bool{
        if let msgID = dict["msgID"] as? String, let key = dict["key"] as? String, let connectUserID = dict["connectUserID"] as? String
        {
            if(msgID != "" && key != "" && connectUserID != ""){
                return true
            }
        }
        return false
    }
}

class UserModel : AppModel
{
    //Create Profile
    var uID : String!
    var email : String!
    var password : String!
    var phoneNo:String!
    var phoneCode:String!
    var phoneId:String!
    var username : String!
    var name : String!
    var location : LocationModel!
    var height : String!
    var age : Int!
    var position : Int! // 1. positionPGBtn, 2. positionSGBtn, 3. positionSFBtn, 4. positionPFBtn, 5. positionCBtn
    var distance : Int!
    var local_pic_url : String!
    var remote_pic_url : String!
    var login_type : Int! // 1. email, 2. Facebook 3.Mobile
    var user_type : Int! // 1. user
    var courts : [String]! // checkedIn courts
    var last_seen : String!
    var story : [String]!
    var contact : [ContactModel]!
    var fcmToken : String!
    var badge : Int!
    var curr_court : String!
    var total_checkIn : Int!
    var blockUsers : [String]!
    
    init(uID:String, email : String, password : String, phoneNo : String,phoneCode : String,phoneId : String,username : String, name : String, location : LocationModel,height : String, age : Int, position : Int, distance : Int, local_pic_url : String, remote_pic_url : String, login_type : Int, user_type : Int, courts : [String], last_seen : String, story : [String], contact : [ContactModel], fcmToken : String, badge : Int, curr_court : String, total_checkIn : Int, blockUsers:[String])
    {
        self.uID = uID
        self.email = email
        self.password = password
        self.phoneNo = phoneNo
        self.phoneCode = phoneCode
        self.phoneId = phoneId
        self.username = username
        self.name = name
        self.location = location
        self.height = height
        self.age = age
        self.position = position
        self.distance = distance
        self.local_pic_url = local_pic_url
        self.remote_pic_url = remote_pic_url
        self.login_type = login_type
        self.user_type = user_type
        self.courts = courts
        self.last_seen = last_seen
        self.story = story
        self.contact = contact
        self.fcmToken = fcmToken
        self.badge = badge
        self.curr_court = curr_court
        self.total_checkIn = total_checkIn
        self.blockUsers = blockUsers
    }
    
    init(dict : [String : Any])
    {
        self.uID = dict["uID"] as! String
        self.email = dict["email"] as! String
        self.password = dict["password"] as! String
        self.phoneNo = dict["phoneNo"] as! String
        self.phoneCode = dict["phoneCode"] as! String
        self.phoneId = dict["phoneId"] as! String
        self.username = dict["username"] as! String
        self.name = dict["name"] as! String
        self.location = LocationModel.init(dict: dict["location"] as? [String : Any] ?? [String : Any]())
        self.height = dict["height"] as? String ?? ""
        self.age = dict["age"] as? Int ?? 0
        self.position = dict["position"] as! Int
        self.distance = dict["distance"] as! Int
        self.local_pic_url = dict["local_pic_url"] as! String
        self.remote_pic_url = dict["remote_pic_url"] as! String
        self.login_type = dict["login_type"] as! Int
        self.user_type = dict["user_type"] as! Int
        self.courts = dict["courts"] as? [String] ?? [String]()
        self.last_seen = dict["last_seen"] as! String
        self.story = dict["story"] as? [String] ?? [String]()
        
        self.contact = [ContactModel]()
        if let strArr = dict["contact"] as? [[String:Any]]{
            let len:Int = strArr.count
            for i in 0..<len{
                self.contact.append(ContactModel.init(dict: strArr[i]))
            }
        }
        
        self.fcmToken = dict["fcmToken"] as? String ?? ""
        self.badge = dict["badge"] as! Int
        self.curr_court = dict["curr_court"] as? String ?? ""
        self.total_checkIn = dict["total_checkIn"] as? Int ?? 0
        self.blockUsers = dict["blockUsers"] as? [String] ?? [String]()
    }
    
    func dictionary() -> [String:Any]{
        return ["uID":uID,"email":email,"password":password,"phoneNo" : phoneNo, "phoneCode" : phoneCode, "phoneId" : phoneId,"username":username,"name":name,"location":location.dictionary(),"height":height,"age":age,"position":position,"distance":distance,"local_pic_url":local_pic_url,"remote_pic_url":remote_pic_url,"login_type":login_type,"user_type":user_type, "courts":courts, "last_seen" : last_seen, "story" : story, "contact" : AppModel.shared.getContactArrOfDictionary(arr: contact), "fcmToken":fcmToken, "badge" : badge, "curr_court":curr_court, "total_checkIn":total_checkIn,  "blockUsers":blockUsers]
    }
    
    func dictionary(user : UserModel) -> [String:Any]{
        return ["uID":user.uID,"email":user.email,"password":user.password, "phoneNo" : phoneNo, "phoneCode" : phoneCode, "phoneId" : phoneId,"username":user.username,"name":user.name,"location":user.location.dictionary(),"height":user.height,"age":user.age,"position":user.position,"distance":user.distance,"local_pic_url":user.local_pic_url,"remote_pic_url":user.remote_pic_url,"login_type":user.login_type,"user_type":user.user_type, "courts":user.courts, "last_seen":user.last_seen, "story" : user.story, "contact" : AppModel.shared.getContactArrOfDictionary(arr: user.contact), "fcmToken":user.fcmToken, "badge" : user.badge, "curr_court":user.curr_court, "total_checkIn":user.total_checkIn, "blockUsers":blockUsers]
    }
}

class ContactModel: AppModel
{
    var id : String!
    var requestAction : Int! //1. Send Request, 2. Got Request, 3. Accept, 4. Reject
    
    init(id : String, requestAction : Int) {
        self.id = id
        self.requestAction = requestAction
    }
    
    init(dict : [String : Any]) {
        self.id = dict["id"] as! String
        self.requestAction = dict["requestAction"] as! Int
    }
    
    func dictionary() -> [String:Any]{
        return ["id":id, "requestAction":requestAction]
    }
}

class EventModel : AppModel
{
    var id:String!
    var uID:String!
    var type : Int! //1.Game, 2.Event, 3.Training
    var title : String!
    var location:LocationModel!
    var minDate : String!
    var maxDate : String!
    var players : [ContactModel]!
    var admissionType : Int!  //1.Free, 2.Fee
    var privacyType : Int!  //1.Public, 2.Privacy
    var description : String!
    var is_notify: Int!
    var is_start_notify: Int!
    var comment : [CommentModel]!
    
    init(id:String, uID:String, type:Int, title:String, location:LocationModel, minDate : String, maxDate : String, players : [ContactModel], admissionType : Int, privacyType : Int, description : String, is_notify:Int, is_start_notify:Int, comment : [CommentModel])
    {
        self.id = id;
        self.uID = uID;
        self.type = type
        self.title = title
        self.location = location
        self.minDate = minDate
        self.maxDate = maxDate
        self.players = players
        self.admissionType = admissionType
        self.privacyType = privacyType
        self.description = description
        self.is_notify = is_notify
        self.is_start_notify = is_start_notify
        self.comment = comment
    }
    
    init(dict : [String : Any])
    {
        self.id = dict["id"] as! String
        self.uID = dict["uID"] as! String
        self.type = dict["type"] as! Int
        self.title = dict["title"] as! String
        self.location = LocationModel.init(dict: dict["location"] as! [String : Any])
        self.minDate = dict["minDate"] as! String
        self.maxDate = dict["maxDate"] as! String
        
        self.players = [ContactModel] ()
        if let strArr = dict["players"] as? [[String:Any]]{
            let len:Int = strArr.count
            for i in 0..<len{
                self.players.append(ContactModel.init(dict: strArr[i]))
            }
        }
        
        self.admissionType = dict["admissionType"] as! Int
        self.privacyType = dict["privacyType"] as! Int
        self.description = dict["description"] as! String
        self.is_notify = dict["is_notify"] as? Int ?? 0
        self.is_start_notify = dict["is_start_notify"] as? Int ?? 0
        self.comment = [CommentModel]()
        if let strArr = dict["comment"] as? [[String:Any]]{
            let len:Int = strArr.count
            for i in 0..<len{
                self.comment.append(CommentModel.init(dict: strArr[i]))
            }
        }
    }
    
    func dictionary() -> [String:Any]{
        return ["id":id, "uID":uID, "type":type,"title":title,"location":location.dictionary(), "minDate":minDate,"maxDate":maxDate,"players":getContactArrOfDictionary(arr: players),"admissionType":admissionType,"privacyType":privacyType,"description":description, "is_notify":is_notify, "is_start_notify":is_start_notify, "comment":AppModel.shared.getCommentArrOfDictionary(arr: comment)]
    }
    
}


class CourtModel: AppModel
{
    var location:LocationModel!
    var players : [String]! // checkedIn members
    var activity : [String]! // array of event id
    var comment : [CommentModel]!
    var story : [String]!
    var date : String!
    var type : Int! //1. CheckIn, 2. Created Court
    var uID : String!
    
    init(location:LocationModel, players : [String], activity : [String], comment : [CommentModel], story : [String], date : String, type : Int, uID : String)
    {
        self.location = location
        self.players = players
        self.activity = activity
        self.comment = comment
        self.story = story
        self.date = date
        self.type = type
        self.uID = uID
    }
    
    init(dict : [String : Any])
    {
        self.location = LocationModel.init(dict: dict["location"] as! [String : Any]);
        self.players = dict["players"] as? [String] ?? [String]()
        self.activity = dict["activity"] as? [String] ?? [String]()
        
        self.comment = [CommentModel]()
        if let strArr = dict["comment"] as? [[String:Any]]{
            let len:Int = strArr.count
            for i in 0..<len{
                self.comment.append(CommentModel.init(dict: strArr[i]))
            }
        }
        
        self.story = dict["story"] as? [String] ?? [String]()
        self.date = dict["date"] as? String ?? ""
        self.type = dict["type"] as? Int ?? 0
        self.uID = dict["uID"] as? String ?? ""
    }
    
    func dictionary() -> [String:Any]{
        return ["location":location.dictionary(), "players":players,"activity":activity,"comment":AppModel.shared.getCommentArrOfDictionary(arr: comment), "story" : story, "date" : date, "type" : type, "uID" : uID]
    }
   
}

class CommentModel: AppModel
{
    var id : String!
    var comment_userID : String! //user who comments
    var text : String!
    var date : String!
    
    init(id:String, comment_userID:String, text : String, date : String) {
        self.id = id
        self.comment_userID = comment_userID
        self.text = text
        self.date = date
    }
    
    init(dict : [String : Any])
    {
        self.id = dict["id"] as! String
        self.comment_userID = dict["comment_userID"] as! String
        self.text = dict["text"] as? String ?? ""
        self.date = dict["date"] as? String ?? ""
    }
    
    func dictionary() -> [String:Any]{
        return ["id" : id, "comment_userID":comment_userID, "text":text, "date":date]
    }
}

class StoryModel: AppModel
{
    var id : String!
    var uID : String!
    var local_url : String!
    var remote_url : String!
    var thumb_local_url : String!
    var thumb_remote_url : String!
    var date : String!
    var description : String!
    var type : Int! //1. image, 2. video
    var error : String!
    
    init(id : String, uID : String, local_url : String, remote_url : String, thumb_local_url : String, thumb_remote_url : String, date : String, description : String, type : Int, error : String)
    {
        self.id = id
        self.uID = uID
        self.local_url = local_url
        self.remote_url = remote_url
        self.thumb_local_url = thumb_local_url
        self.thumb_remote_url = thumb_remote_url
        self.date = date
        self.description = description
        self.type = type
        self.error = error
    }
    
    init(dict : [String : Any])
    {
        self.id = dict["id"] as? String ?? ""
        self.uID = dict["uID"] as? String ?? ""
        self.local_url = dict["local_url"] as! String
        self.remote_url = dict["remote_url"] as! String
        self.thumb_local_url = dict["thumb_local_url"] as! String
        self.thumb_remote_url = dict["thumb_remote_url"] as! String
        self.date = dict["date"] as! String
        self.description = dict["description"] as! String
        self.type = dict["type"] as! Int
        self.error = dict["error"] as! String
    }
    
    func dictionary() -> [String : Any]
    {
        return ["id" : id, "uID" : uID, "local_url":local_url, "remote_url":remote_url, "thumb_local_url": thumb_local_url, "thumb_remote_url": thumb_remote_url, "date":date, "description":description, "type":type, "error" : error]
    }
}


class LocationModel: AppModel
{
    var id : String!
    var name : String!
    var image : String!
    var address : String!
    var latitude : Float!
    var longitude : Float!
    var isOpen : Bool!
    
    init(id:String, name:String,image:String,  address:String, latitude:Float, longitude : Float, isOpen:Bool)
    {
        self.id = id;
        self.name = name
        self.image = image
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.isOpen = isOpen
    }
    
    init(dict : [String : Any])
    {
        self.id = dict["id"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        self.image = dict["image"] as? String ?? ""
        self.address = dict["address"] as? String ?? ""
        self.latitude = dict["latitude"] as? Float ?? 0.0
        self.longitude = dict["longitude"] as? Float ?? 0.0
         self.isOpen = dict["isOpen"] as? Bool ?? true
    }
    
    func dictionary() -> [String:Any]{
        return ["id":id, "name":name, "image":image, "address":address,"latitude":latitude,"longitude":longitude,"isOpen":isOpen]
    }
}

class MessageModel: AppModel
{
    var msgID : String!
    var key : String!
    var connectUserID : String!
    var date : String!
    var text : String!
    var storyID : String!
    var status : Int! //1.Pending, 2.Send, 3.notify
    
    init(msgID:String, key : String, connectUserID:String,date:String,  text:String, storyID:String, status : Int)
    {
        self.msgID = msgID
        self.key = key
        self.connectUserID = connectUserID
        self.date = date
        self.text = text
        self.storyID = storyID
        self.status = status
    }
    
    init(dict : [String : Any])
    {
        self.msgID = dict["msgID"] as? String ?? ""
        self.key = dict["key"] as? String ?? ""
        self.connectUserID = dict["connectUserID"] as? String ?? ""
        self.date = dict["date"] as? String ?? ""
        self.text = dict["text"] as? String ?? ""
        self.storyID = dict["storyID"] as? String ?? ""
        self.status = dict["status"] as? Int ?? 0
    }
    
    func dictionary() -> [String:Any]{
        return ["msgID":msgID, "key":key, "connectUserID":connectUserID, "date":date, "text":text, "storyID":storyID, "status":status]
    }
}

class InboxListModel: AppModel
{
    var id : String!
    var badge1 : Int!
    var badge2 : Int!
    var lastMessage : MessageModel!
    
    init(id:String, badge1:Int, badge2:Int, lastMessage:MessageModel)
    {
        self.id = id;
        self.badge1 = badge1
        self.badge2 = badge2
        self.lastMessage = lastMessage
    }
    
    init(dict : [String : Any])
    {
        self.id = dict["id"] as? String ?? ""
        self.badge1 = dict["badge1"] as? Int ?? 0
        self.badge2 = dict["badge2"] as? Int ?? 0
        self.lastMessage = MessageModel.init(dict: dict["lastMessage"] as? [String : Any] ?? [String : Any]())
    }
    
    func dictionary() -> [String:Any]{
        return ["id":id, "badge1":badge1, "badge2":badge2, "lastMessage":lastMessage.dictionary()]
    }
}
