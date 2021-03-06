//
//  ProfileHeaderView.swift
//  Twitterpated
//
//  Created by Phan, Ngan on 10/8/17.
//  Copyright © 2017 Phan, Ngan. All rights reserved.
//

import UIKit

class ProfileHeaderView: UIView {

    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userScreenname: UILabel!
    @IBOutlet weak var userDescription: UILabel!
    
    override func awakeFromNib() {
        profileImageView.layer.cornerRadius = 35
    }
}
