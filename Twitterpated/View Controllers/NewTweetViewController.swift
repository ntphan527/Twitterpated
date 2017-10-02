//
//  NewTweetViewController.swift
//  Twitterpated
//
//  Created by Phan, Ngan on 9/30/17.
//  Copyright © 2017 Phan, Ngan. All rights reserved.
//

import UIKit

protocol NewTweetViewControllerDelegate: class {
    func newTweet(newTweet: NewTweetViewController, tweet: Tweet)
}

class NewTweetViewController: UIViewController {
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var replyTo: Tweet?
    weak var delegate: NewTweetViewControllerDelegate?
    var limitLabel: UILabel!
    var limit = 140
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTweet(_ sender: Any) {
        TwitterClient.sharedInstance.tweet(status: tweetTextView.text, replyTo: replyTo, success: { (tweet: Tweet) in
            self.delegate?.newTweet(newTweet: self, tweet: tweet)
        }) { (error: Error) in
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        limitLabel = UILabel()
        limitLabel.text = String(limit)
        let limitBarButtonItem = UIBarButtonItem(customView: limitLabel)
        self.navigationItem.rightBarButtonItems?.append(limitBarButtonItem)
        
        if let user =  User.currentUser {
            usernameLabel.text = user.name
            screennameLabel.text = user.screenName
            if let profileUrl = user.profileUrl {
                ImageUtil.loadImage(imageUrl: profileUrl, loadImageView: profileImageView)
            }
            tweetTextView.becomeFirstResponder()
        }
        
        tweetTextView.delegate = self
    }
}

extension NewTweetViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        let limitText = numberOfChars <= limit
        
        if limitText {
            let countDown = limit - numberOfChars
            limitLabel.text = String(countDown)
        }
        
        return limitText
    }
}
