//
//  GlobalConstant.swift
//  TeacupPuppies
//
//  Created by Amisha on 03/07/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import Foundation
import UIKit

struct VIEW
{
    static var ALERT = "customAlertView"
}

struct CORNER
{
    static var RADIUS_BUTTON = 5.0
    static var RADIUS_VIEW = 25.0
}

struct COLOR
{
    static var APP_COLOR = "F38945"
    static var WHITE = "FFFFFF"
    static var DARK_TEXT = "3C3739"
    static var LIGHT_TEXT = "afafaf"
}

struct SCREEN
{
    static var WIDTH = UIScreen.main.bounds.size.width
    static var HEIGHT = UIScreen.main.bounds.size.height
}

struct IMAGESIZE
{
    static var IMAGE_WIDTH     =  800
    static var IMAGE_HEIGHT    =  800
    static var IMAGE_QUALITY   =  0.7
}

struct IMAGE {
    static var USER_LOCATION = "pin_small_orange"
    static var GAMES_GRAY = "pin_games_gray"
    static var GAMES_GRAY_SMALL = "pin_games_gray_small"
    static var GAMES_ORANGE = "pin_games"
    static var GAMES_ORANGE_SMALL = "pin_games_small"
    
    static var TRAINER_GRAY = "pin_trainer_gray"
    static var TRAINER_GRAY_SMALL = "pin_trainer_gray_small"
    static var TRAINER_ORANGE = "pin_trainer"
    static var TRAINER_ORANGE_SMALL = "pin_trainer_small"
    
    static var WORLDCUP_ORANGE = "pin_worldcup"
    static var WORLDCUP_ORANGE_SMALL = "pin_worldcup_small"
    static var WORLDCUP_GRAY = "pin_worldcup_gray"
    static var WORLDCUP_GRAY_SMALL = "pin_worldcup_gray_small"
    
    
    static var COURT = "pin_court"
    static var PLACEHOLDER_BG = "img_placeholder"
    static var PLACEHOLDER_USER = "user_placeholder"
    
    
    
    
}

struct NOTIFICATION
{
    static var SHOW_PROFILE_SCREEN                  =  "SHOW_PROFILE_SCREEN"
    static var UPDATE_CURRENT_USER_LOCATION         =  "UPDATE_CURRENT_USER_LOCATION"
    static var UPDATE_BADGE_COUNT                   =  "UPDATE_BADGE_COUNT"
    static var UPDATE_REDIRECT_NEW_FRIEND_LIST      =  "UPDATE_REDIRECT_NEW_FRIEND_LIST"
    static var UPDATE_REDIRECT_EVENT_MAP            =  "UPDATE_REDIRECT_EVENT_MAP"
    static var CHECK_FOR_CHECKEDIN                  =  "CHECK_FOR_CHECKEDIN"
    
    static var ON_UPDATE_ALL_USER                 =  "ON_UPDATE_ALL_USER"
    
    static var ON_UPDATE_STORIES                    =  "ON_UPDATE_STORIES"
    
    static var ON_UPDATE_EVENTS                     =  "ON_UPDATE_EVENTS"
    
    static var ON_UPDATE_COURTS                     =  "ON_UPDATE_COURTS"
    
    static var ON_UPDATE_INBOX                    =  "ON_UPDATE_INBOX"
}

struct API
{
    static var NEAR_COURT_GYM   =   "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%f&type=court+gym&keyword=basketball+gym&key=" + GOOGLE.KEY
    static var NEAR_COURT   =   "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=5000&type=court&keyword=basketball&key=" + GOOGLE.KEY
    static var PLACE_DETAIL   = "https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=" + GOOGLE.KEY
    
    static var SEARCH_ADDRESS = "https://maps.googleapis.com/maps/api/geocode/json?address="
    static var GOOGLE_IMAGE = "https://maps.googleapis.com/maps/api/place/photo?photoreference=%@&sensor=false&maxheight=500&maxwidth=500&key=" + GOOGLE.KEY
}


struct USER
{
    static var AGE              =  20
    static var POSITION         =  1
    static var DISTANCE         =  10
    
    static var EMAIL_LOGIN      =  1
    static var FB_LOGIN         =  2
    static var MOBILE_LOGIN     =  3
    
    static var REGULAR_USER     =  1
}

struct GOOGLE
{
    //Live
    static var KEY = "AIzaSyDs009jNBbo1GtPybIidNVQhdqmwTiyQtU" // Checkup
    
    static var ADMOB = "ca-app-pub-4519888193823923~1775508227"
//    static var BANNER_AD_ID = "ca-app-pub-3940256099942544/6300978111"
//    static var INTERSTITIAL_AD_ID = "ca-app-pub-3940256099942544/1033173712"
    static var BANNER_AD_ID = "ca-app-pub-4519888193823923/6094484039"
    static var INTERSTITIAL_AD_ID = "ca-app-pub-4519888193823923/9538905022"
}

struct APP {
    static var URL = "https://itunes.apple.com/us/app/check-up/id1286254922?ls=1&mt=8"
    static var SHARE_URL = "http://check-up.webflow.io"
    static var REPORT_EMAIL = "checkupbasketball@gmail.com"
}

struct FORMAT {
    static var FCM_DATE = "MM/dd/yyyy"
    static var FCM_TIME = "HH:mm:ss"
    static var FCM_DATETIME = "MM/dd/yyyy HH:mm:ss"
    
    static var DISPLAY_DATE = "MM/dd/yyyy"
    static var DISPLAY_TIME = "hh:mm a"
    static var DISPLAY_DATETIME = "MM/dd/yyyy hh:mm a"
}

struct USERVALUE {
    static var DISTANCE_DIFFERENCE = 10 //miles
    static var NEAREST_DIFFERENCE = 48000.0 //meter
    static var CHECKIN_DIFFERENCE = 100.0 //meter
    static var LEAVING_DIFFERENCE = 150.0 //meter
    
    static var STORY_DISPLAY_TIME = 4
}

struct FOLDER {
    static var userPhoto = "userPhoto"
    static var userStory = "userStory"
    static var chatMedia = "chatMedia"
}

struct PUSH_NOTIFICATION {
    struct TYPE
    {
        static var FRIEND_REQUEST   =   "1"
        static var TODAY_EVENT      =   "2"
        static var CHAT_MESSAGE     =   "3"
        static var CHECKED_IN       =   "4"
        static var EVENT_INVITE     =   "5"
        static var EVENT_COMMENT    =   "6"
        static var COURT_COMMENT    =   "7"
        static var EVENT_JOIN     =   "8"
        static var EVENT_DECLINED     =   "9"
        static var EVENT_CANCELLED     =   "10"
        static var WANT_TO_CHECK_IN       =   "11"
    }
}

struct COREDATA {
    struct MESSAGE
    {
        static var TABLE_NAME = "Message"
        static var CHANNEL_ID = "channeld"
        static var msgID = "msgID"
        static var key = "key"
        static var connectUserID = "connectUserID"
        static var date = "date"
        static var text = "text"
        static var storyID = "storyID"
        static var status = "status"
    }
    struct STORY
    {
        static var TABLE_NAME = "Story"
        static var id = "id"
        static var uID = "uID"
        static var local_url = "local_url"
        static var remote_url = "remote_url"
        static var thumb_local_url = "thumb_local_url"
        static var thumb_remote_url = "thumb_remote_url"
        static var date = "date"
        static var description = "description"
        static var type = "type"
        static var error = "error"
    }
    struct USER
    {
        static var TABLE_NAME = "User"
        static var uID = "uID"
        static var name = "name"
        static var local_pic_url = "local_pic_url"
        static var remote_pic_url = "remote_pic_url"
        static var last_seen = "last_seen"
    }
}

