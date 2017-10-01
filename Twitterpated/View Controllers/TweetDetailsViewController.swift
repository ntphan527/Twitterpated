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
    
    var tweet: Tweet!
    var replyButton: UIBarButtonItem!
    weak var newTweetDelegate: NewTweetViewControllerDelegate?
    
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
