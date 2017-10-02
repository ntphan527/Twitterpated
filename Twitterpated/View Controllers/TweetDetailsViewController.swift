//
//  TweetDetailsViewController.swift
//  Twitterpated
//
//  Created by Phan, Ngan on 9/30/17.
//  Copyright © 2017 Phan, Ngan. All rights reserved.
//

import UIKit

class TweetDetailsViewController: UIViewController {

    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var retweetUserLabel: UILabel!
    @IBOutlet weak var retweetedLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var favoriteCount: UILabel!
    
    @IBOutlet weak var replyImageButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    var tweet: Tweet!
    var replyButton: UIBarButtonItem!
    weak var newTweetDelegate: NewTweetViewControllerDelegate?
    var handleTweetUpdate: ((Tweet) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        replyButton = UIBarButtonItem(title: "Reply", style: .plain, target: self, action: #selector(TweetDetailsViewController.onReply))
        self.navigationItem.rightBarButtonItem = replyButton
        
        if tweet != nil {
            let user = tweet.user
            userNameLabel.text = user?.name
            
            if let userScreenName = user?.screenName {
                screenNameLabel.text = "@" + userScreenName
            }
            
            if let profileUrl = user?.profileUrl {
                ImageUtil.loadImage(imageUrl: profileUrl, loadImageView: profileImageView)
                profileImageView.layer.cornerRadius = 10.0
                profileImageView.clipsToBounds = true
            }
            statusLabel.text = tweet.text
            retweetCount.text = String(tweet.retweetCount)
            favoriteCount.text = String(tweet.favoriteCount)
            
            if let date = tweet.timeStamp {
                dateLabel.text = date.dateTimeDisplay()
            }
            
            if tweet.favorited > 0 {
                favoriteButton.alpha = 1.0
            } else {
                favoriteButton.alpha = 0.4
            }
            
            if tweet.retweeted > 0 {
                retweetButton.alpha = 1.0
            } else {
                retweetButton.alpha = 0.4
            }
            
            if let retweetUser = tweet.retweetedStatus?.user?.screenName {
                retweetUserLabel.text = retweetUser
                retweetUserLabel.isHidden = false
                retweetedLabel.isHidden = false
                retweetImageView.isHidden = false
            } else {
                retweetUserLabel.isHidden = true
                retweetedLabel.isHidden = true
                retweetImageView.isHidden = true
            }
        }
    }

    @objc func onReply() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let newTweetNC = mainStoryboard.instantiateViewController(withIdentifier: "NewTweetNavigationController") as? UINavigationController {
            if let newTweetVC = newTweetNC.topViewController as? NewTweetViewController {
                newTweetVC.replyTo = tweet
                newTweetVC.delegate = newTweetDelegate
                present(newTweetNC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onReplyImage(_ sender: Any) {
        onReply()
    }
    
    @IBAction func onRetweet(_ sender: Any) {
        if tweet.retweeted > 0 {
            return
        }
        
        TwitterClient.sharedInstance.retweet(id: tweet.id!, success: { (tweet: Tweet) in
            self.tweet.retweetCount = tweet.retweetCount
            self.tweet.retweeted = tweet.retweeted
            self.retweetButton.alpha = 1.0
            self.retweetCount.text = String(tweet.retweetCount)
            self.handleTweetUpdate?(self.tweet)
        }) { (error: Error) in
            print("errors on retweet: \(error.localizedDescription)")
        }
    }
    
    @IBAction func onFavorite(_ sender: Any) {
        if tweet.favorited > 0 {
            TwitterClient.sharedInstance.unfavorite(id: tweet.id!, success: { (tweet: Tweet) in
                self.tweet.favoriteCount = tweet.favoriteCount
                self.tweet.favorited = tweet.favorited
                self.favoriteButton.alpha = 0.4
                self.favoriteCount.text = String(tweet.favoriteCount)
                self.handleTweetUpdate?(self.tweet)
            }) { (error: Error) in
                print("errors on favorite: \(error.localizedDescription)")
            }
        } else {
            TwitterClient.sharedInstance.favorite(id: tweet.id!, success: { (tweet: Tweet) in
                self.tweet.favoriteCount = tweet.favoriteCount
                self.tweet.favorited = tweet.favorited
                self.favoriteButton.alpha = 1.0
                self.favoriteCount.text = String(tweet.favoriteCount)
                self.handleTweetUpdate?(self.tweet)
            }) { (error: Error) in
                print("errors on favorite: \(error.localizedDescription)")
            }
        }
    }
}
