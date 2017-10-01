//
//  TwitterClient.swift
//  Twitterpated
//
//  Created by Phan, Ngan on 9/29/17.
//  Copyright © 2017 Phan, Ngan. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {

    static let sharedInstance: TwitterClient = TwitterClient(baseURL: URL(string: "https://api.twitter.com"),
                                              consumerKey: "GrJMtheAo0YvxDSUmSFnPBqJI",
                                              consumerSecret: "Ay3izqd5KUWSMEzTsscZshNUFBhxyinePC429ZjCC82kPsJJ4C")
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterpated://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            guard let token = requestToken?.token else {
                return
            }
            print("requestToken: \(token)")
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token)")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }, failure: { (error: Error!) in
            print("error: \(error.localizedDescription)")
            self.loginFailure?(error)
        })
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NotificationCenter.default.post(name: NSNotification.Name(User.userDidLogoutNotification), object: nil)
    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) in
            print("accessToken: \(accessToken.token)")
            self.currentAccount(success: { (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error) in
                self.loginFailure?(error)
            })
        }, failure: { (error: Error!) in
            self.loginFailure?(error)
        })
    }
    
    static var lastTweetId = ""
    func homeTimeLine(lastId: String?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        var params: [String: Any?]!
        if lastId != nil && TwitterClient.lastTweetId != lastId {
            TwitterClient.lastTweetId = lastId!
            params = ["max_id": lastId]
        }
        get("1.1/statuses/home_timeline.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionaries = response as! [NSDictionary]
//            for dictionary in dictionaries {
//                print(dictionary)
//                print()
//            }
            
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func tweet(status: String?, replyTo: Tweet?, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        if status?.isEmpty ?? true {
            return
        }
        var params = ["status": status]
        
        if let replyTo = replyTo {
            params["in_reply_to_status_id"] = replyTo.id
            if let screenName = replyTo.user?.screenName {
                let replyToStatus = "@\(screenName) " + (status ?? "")
                params.updateValue(replyToStatus, forKey: "status")
            }
        }
        
        post("1.1/statuses/update.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            if let dictionary = response as? NSDictionary {
                let tweet = Tweet(dictionary: dictionary)
                success(tweet)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            print(error.localizedDescription)
            failure(error)
        }
    }
}
