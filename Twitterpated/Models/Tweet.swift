//
//  Tweet.swift
//  Twitterpated
//
//  Created by Phan, Ngan on 9/29/17.
//  Copyright © 2017 Phan, Ngan. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var id: String?
    var text: String?
    var timeStamp: Date?
    var retweeted: Int = 0
    var retweetCount: Int = 0
    var favorited: Int = 0
    var favoriteCount: Int = 0
    var user: User?
    var retweetedStatus: Tweet?
    
    init(dictionary: NSDictionary) {
        id = dictionary["id_str"] as? String
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        retweeted = (dictionary["retweeted"] as? Int) ?? 0
        favoriteCount = (dictionary["favorite_count"] as? Int) ?? 0
        favorited = (dictionary["favorited"] as? Int) ?? 0
        
        if let timeStampString = dictionary["created_at"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timeStamp = formatter.date(from: timeStampString)
        }
        
        if let userData = dictionary["user"] as? NSDictionary {
            user = User(dictionary: userData)
        }
        
        if let retweetedDictionary = dictionary["retweeted_status"] as? NSDictionary {
            retweetedStatus = Tweet(dictionary: retweetedDictionary)
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        return tweets
    }
}
