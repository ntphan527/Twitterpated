//
//  TweetCell.swift
//  Twitterpated
//
//  Created by Phan, Ngan on 9/30/17.
//  Copyright © 2017 Phan, Ngan. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var retweetUserLabel: UILabel!
    @IBOutlet weak var retweetedLabel: UILabel!
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoritedButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func onReply(_ sender: Any) {
    }
    
    @IBAction func onReTweet(_ sender: Any) {
    }
    
    @IBAction func onFavorite(_ sender: Any) {
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        profileImageView.layer.cornerRadius = 10.0
        profileImageView.clipsToBounds = true
    }

}
