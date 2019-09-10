//
//  Preference.swift
//  Check-Up
//
//  Created by Amisha on 13/08/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class Preference: NSObject {

    static let sharedInstance = Preference()
    
    let IS_USER_LOGIN_KEY       =   "IS_USER_LOGIN"
    let USER_DATA_KEY           =   "USER_DATA"
    let USER_ID_KEY             =   "USER_ID"
    let USER_LATITUDE_KEY       =   "USER_LATITUDE"
    let USER_LONGITUDE_KEY      =   "USER_LONGITUDE"
    
    func setDataToPreference(data: AnyObject, forKey key: String)
    {
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getDataFromPreference(key: String) -> AnyObject?
    {
        return UserDefaults.standard.object(forKey: key) as AnyObject?
    }
    
    func removeDataFromPreference(key: String)
    {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    //MARK: - User login boolean
    func setIsUserLogin(isUserLogin: Bool)
    {
        setDataToPreference(data: isUserLogin as AnyObject, forKey: IS_USER_LOGIN_KEY)
    }
    
    func isUserLogin() -> Bool
    {
        let isUserLogin = getDataFromPreference(key: IS_USER_LOGIN_KEY)
        return isUserLogin == nil ? false:(isUserLogin as! Bool)
    }
    
    //MARK: - Login User Data
    func setUserLoginData(dict: [String : Any])
    {
        setDataToPreference(data: dict as AnyObject, forKey: USER_DATA_KEY)
        setIsUserLogin(isUserLogin: true)
    }
    
    func getUserLoginData() -> [String : Any]?
    {
        if let dict : [String : Any] = getDataFromPreference(key: USER_DATA_KEY) as? [String : Any] {
            return dict
        }
        return nil
    }
    
    func setUserLocation(latitude : Float, longitude : Float)
    {
        setDataToPreference(data: latitude as AnyObject, forKey: USER_LATITUDE_KEY)
        setDataToPreference(data: longitude as AnyObject, forKey: USER_LONGITUDE_KEY)
    }
    
    func getUserLatitude() -> Float
    {
        if let latitude = getDataFromPreference(key: USER_LATITUDE_KEY) {
            return latitude as! Float
        }
        return 0
    }
    
    func getUserLongitude() -> Float
    {
        if let longitude = getDataFromPreference(key: USER_LONGITUDE_KEY) {
            return longitude as! Float
        }
        return 0
        
    }
    
    func removeUserDefaultValues()
    {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
}
