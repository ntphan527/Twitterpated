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
        
        if let user =  User.currentUser {
            usernameLabel.text = user.name
            screennameLabel.text = user.screenName
            if let profileUrl = user.profileUrl {
                ImageUtil.loadImage(imageUrl: profileUrl, loadImageView: profileImageView)
            }
            tweetTextView.becomeFirstResponder()
        }
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
