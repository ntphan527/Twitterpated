//
//  MenuViewController.swift
//  Twitterpated
//
//  Created by Phan, Ngan on 10/6/17.
//  Copyright © 2017 Phan, Ngan. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuTableView: UITableView!
    private var profileTweetsViewController: TweetsViewController!
    private var homeTweetsViewController: TweetsViewController!
    private var mentionsTweetsViewController: TweetsViewController!
    
    var viewControllers: [UIViewController] = []
    var hamburgerViewController: HamburgerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileTweetsNC = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController") as! UINavigationController
        profileTweetsViewController = profileTweetsNC.topViewController as! TweetsViewController
        profileTweetsViewController.channel = .PROFILE
        
        let homeTweetsNC = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController") as! UINavigationController
        homeTweetsViewController = homeTweetsNC.topViewController as! TweetsViewController
        homeTweetsViewController.channel = .HOME
        
        let mentionsTweetsNC = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController") as! UINavigationController
        mentionsTweetsViewController = mentionsTweetsNC.topViewController as! TweetsViewController
        mentionsTweetsViewController.channel = .MENTIONS
        
        viewControllers.append(profileTweetsNC)
        viewControllers.append(homeTweetsNC)
        viewControllers.append(mentionsTweetsNC)
        
        hamburgerViewController.contentViewController = homeTweetsNC
        
        menuTableView.rowHeight = floor(view.frame.height/3)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as? MenuCell else {
            return UITableViewCell()
        }
        
        let titles = ["Profile", "Timeline", "Mentions"]
        cell.pageNameLabel.text = titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        hamburgerViewController.contentViewController = viewControllers[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}
