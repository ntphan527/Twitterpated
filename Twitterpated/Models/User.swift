//
//  User.swift
//  Twitterpated
//
//  Created by Phan, Ngan on 9/29/17.
//  Copyright © 2017 Phan, Ngan. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var screenName: String?
    var profileUrl: URL?
    var backgroundUrl: URL?
    var bannerUrl: URL?
    var tagLine: String?
    var followingCount: Int?
    var followersCount: Int?
    var statusesCount: Int?
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        if let urlString = dictionary["profile_image_url_https"] as? String {
            let url = urlString.replacingOccurrences(of: "_normal", with: "")
            profileUrl = URL(string: url)
        }
        
        if let url = dictionary["profile_background_image_url_https"] as? String {
            backgroundUrl = URL(string: url)
        }
        
        if let url = dictionary["profile_banner_url"] as? String {
            bannerUrl = URL(string: url)
        }
        
        tagLine = dictionary["description"] as? String
        followersCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int
        statusesCount = dictionary["statuses_count"] as? Int
    }
    
    static var userDidLogoutNotification = "UserDidLogout"
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                if let userData = defaults.object(forKey: "currentUserData") as? Data {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            let defaults = UserDefaults.standard
            if let user = user {
                let userData = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(userData, forKey: "currentUserData")
            } else {
                defaults.removeObject(forKey: "currentUserData")
            }
            defaults.synchronize()
        }
    }
}
