//
//  TweetsViewController.swift
//  Twitterpated
//
//  Created by Phan, Ngan on 9/30/17.
//  Copyright © 2017 Phan, Ngan. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import MBProgressHUD

enum Channel {
    case HOME
    case PROFILE
    case MENTIONS
}

class TweetsViewController: UIViewController {

    @IBOutlet weak var tweetsTableView: UITableView!
    var tweets = [Tweet]()
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    private var viewActionHandler: ((UIRefreshControl?, String?) -> ())!
    private var profileUser: User!
    
    var channel: Channel! {
        didSet(oldValue) {
            switch channel {
            case .HOME:
                self.title = "Home"
                viewActionHandler = getHomeTimeLine(refreshControl:lastId:)
            case .PROFILE:
                if profileUser != nil {
                    self.title = profileUser.name
                } else {
                    self.title = User.currentUser?.name
                }
                viewActionHandler = getUserTimeLine(refreshControl:lastId:)
            case .MENTIONS:
                self.title = "Mentions"
                viewActionHandler = getMentionsTimeLine(refreshControl:lastId:)
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // autoresize table cell height
        tweetsTableView.estimatedRowHeight = 170
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        
        // add refresh control to table view
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tweetsTableView.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height, width: tweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tweetsTableView.addSubview(loadingMoreView!)
        
        var insets = tweetsTableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tweetsTableView.contentInset = insets
        
        // get Tweets
        getTweets(refreshControl: nil, lastId: nil)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        tweetsTableView.contentInset.bottom = 50
//        print("contentInset: \(tweetsTableView.contentInset)")
//    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
    }
    
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl) {
        print("refresh works")
        getTweets(refreshControl: refreshControl, lastId: nil)
    }
    
    fileprivate func getTweets(refreshControl: UIRefreshControl?, lastId: String?) {
        if refreshControl == nil && !self.isMoreDataLoading {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        viewActionHandler(refreshControl, lastId)
    }
    
    private func getHomeTimeLine(refreshControl: UIRefreshControl?, lastId: String?) {
        TwitterClient.sharedInstance.homeTimeLine(lastId: lastId, success: { (tweets: [Tweet]) in
            self.onLoadingSuccess(tweets: tweets, refreshControl: refreshControl)
        }, failure: { (error: Error) in
            self.onLoadingFailure(error: error, refreshControl: refreshControl)
        })
    }
    
    private func getUserTimeLine(refreshControl: UIRefreshControl?, lastId: String?) {
        var userSreenname: String!
        if let user = profileUser {
            userSreenname = user.screenName
        }
        
        TwitterClient.sharedInstance.userTimeLine(lastId: lastId, screenname: userSreenname, success: { (tweets: [Tweet]) in
            self.onLoadingSuccess(tweets: tweets, refreshControl: refreshControl)
        }, failure: { (error: Error) in
            self.onLoadingFailure(error: error, refreshControl: refreshControl)
        })
    }
    
    private func getMentionsTimeLine(refreshControl: UIRefreshControl?, lastId: String?) {
        TwitterClient.sharedInstance.mentionsTimeLine(lastId: lastId, success: { (tweets: [Tweet]) in
            self.onLoadingSuccess(tweets: tweets, refreshControl: refreshControl)
        }, failure: { (error: Error) in
            self.onLoadingFailure(error: error, refreshControl: refreshControl)
        })
    }
    
    private func onLoadingSuccess(tweets: [Tweet], refreshControl: UIRefreshControl?) {
        if self.isMoreDataLoading {
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
        } else {
            if let refreshControl = refreshControl {
                self.tweets = tweets
                refreshControl.endRefreshing()
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
        print("gettweets works")
        if refreshControl == nil {
            for tweet in tweets {
                if tweet.id != TwitterClient.lastTweetId {
                    self.tweets.append(tweet)
                }
            }
        }
        
        self.tweetsTableView.reloadData()
    }
    
    private func onLoadingFailure(error: Error, refreshControl: UIRefreshControl?) {
        print(error.localizedDescription)
        if self.isMoreDataLoading {
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
        } else {
            if let refreshControl = refreshControl {
                refreshControl.endRefreshing()
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewTweetNavigationControllerSegue" {
            guard let destinationNC = segue.destination as? UINavigationController else {
                return
            }
            guard let newTweetVC = destinationNC.topViewController as? NewTweetViewController else {
                return
            }
            newTweetVC.delegate = self
        } else if segue.identifier == "TweetDetailsViewControllerSegue" {
            guard let tweetDetailsVC = segue.destination as? TweetDetailsViewController else {
                return
            }
            if let tweetCell = sender as? TweetCell {
                if let indexPath = tweetsTableView.indexPath(for: tweetCell) {
                    tweetDetailsVC.tweet = tweets[indexPath.row]
                    tweetDetailsVC.newTweetDelegate = self
                    tweetDetailsVC.handleTweetUpdate = {(tweet: Tweet) -> () in
                        for (index, element) in self.tweets.enumerated() {
                            if element.id == tweet.id {
                                self.tweets[index] = tweet
                                //self.tweetsTableView.reloadData()
                                self.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                            }
                        }
                    }
                }
            }
        }
        
    }
}

extension TweetsViewController: NewTweetViewControllerDelegate {
    func newTweet(newTweet: NewTweetViewController, tweet: Tweet) {
        tweets.insert(tweet, at: 0)
        self.tweetsTableView.reloadData()
    }
}

extension TweetsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tweetsTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tweetsTableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height, width: tweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                if !tweets.isEmpty {
                    if let lastTweet = tweets.last {
                        getTweets(refreshControl: nil, lastId: lastTweet.id)
                    }
                } else {
                    getTweets(refreshControl: nil, lastId: nil)
                }
            }
        }
    }
}

extension TweetsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TweetCell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as? TweetCell else {
            return UITableViewCell()
        }
        let tweet = tweets[indexPath.row]
        let user = tweets[indexPath.row].user
        let retweetedUser = tweets[indexPath.row].retweetedStatus?.user
        
        if tweet.favorited > 0 {
            cell.favoritedButton.alpha = 1
        } else {
            cell.favoritedButton.alpha = 0.4
        }
        
        if tweet.retweeted > 0 {
            cell.retweetButton.alpha = 1
        } else {
            cell.retweetButton.alpha = 0.4
        }
        
        cell.statusLabel.text = tweet.text
        cell.userNameLabel.text = user?.name
        
        if let date = tweet.timeStamp {
            cell.timeLabel.text = date.timeAgoDisplay()
        }
        
        if let userScreenName = user?.screenName {
            cell.userScreenNameLabel.text = "@" + userScreenName
        }
        
        if let retweetedUserScreenName = retweetedUser?.screenName {
            cell.retweetUserLabel.text = retweetedUserScreenName
            cell.retweetUserLabel.isHidden = false
            cell.retweetedLabel.isHidden = false
            cell.retweetImageView.isHidden = false
        } else {
            cell.retweetUserLabel.isHidden = true
            cell.retweetedLabel.isHidden = true
            cell.retweetImageView.isHidden = true
        }
        if let profileImage = user?.profileUrl {
            ImageUtil.loadImage(imageUrl: profileImage, loadImageView: cell.profileImageView)
        }
        
        cell.handleOnReTweet = {
            if tweet.retweeted > 0 {
                return
            }
            
            TwitterClient.sharedInstance.retweet(id: tweet.id!, success: { (tweetResponse: Tweet) in
                tweet.retweetCount = tweetResponse.retweetCount
                tweet.retweeted = tweetResponse.retweeted
                self.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }) { (error: Error) in
                print("errors on retweet: \(error.localizedDescription)")
            }
        }
        
        cell.handleOnFavorite = {
            if tweet.favorited > 0 {
                TwitterClient.sharedInstance.unfavorite(id: tweet.id!, success: { (tweetResponse: Tweet) in
                    tweet.favoriteCount = tweetResponse.favoriteCount
                    tweet.favorited = tweetResponse.favorited
                    self.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }) { (error: Error) in
                    print("errors on favorite: \(error.localizedDescription)")
                }
            } else {
                TwitterClient.sharedInstance.favorite(id: tweet.id!, success: { (tweetResponse: Tweet) in
                    tweet.favoriteCount = tweetResponse.favoriteCount
                    tweet.favorited = tweetResponse.favorited
                    self.tweetsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }) { (error: Error) in
                    print("errors on favorite: \(error.localizedDescription)")
                }
            }
        }
        
        cell.handleOnReply = {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let newTweetNC = mainStoryboard.instantiateViewController(withIdentifier: "NewTweetNavigationController") as? UINavigationController {
                if let newTweetVC = newTweetNC.topViewController as? NewTweetViewController {
                    newTweetVC.replyTo = tweet
                    newTweetVC.delegate = self
                    self.present(newTweetNC, animated: true, completion: nil)
                }
            }
        }
        
        cell.handleOnTap = {
            if self.channel != .PROFILE {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let profileUserNC = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController") as! UINavigationController
                let profileUserViewController = profileUserNC.topViewController as! TweetsViewController
                profileUserViewController.profileUser = user
                profileUserViewController.channel = .PROFILE
                let backBarButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.popUserProfile))
                profileUserViewController.navigationItem.leftBarButtonItem = backBarButton
                self.navigationController?.pushViewController(profileUserViewController, animated: true)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if channel != .PROFILE {
            return nil
        }
        
        let headerView = Bundle.main.loadNibNamed("ProfileHeaderView", owner: nil, options: nil)?.first as! ProfileHeaderView
        
//        tableView.contentInset.top = 245
    
        var user = User.currentUser
        if let profileUser = profileUser {
            user = profileUser
        }
        
        if let bannerUrl = user?.bannerUrl {
            ImageUtil.loadImage(imageUrl: bannerUrl, loadImageView: headerView.bannerImageView)
        }
        
        if let profileUrl = user?.profileUrl {
            ImageUtil.loadImage(imageUrl: profileUrl, loadImageView: headerView.profileImageView)
        }
        
        if let followersCount = user?.followersCount {
            headerView.followersLabel.text = String(describing: followersCount)
        }
        
        if let followingCount = user?.followingCount {
            headerView.followingLabel.text = String(describing: followingCount)
        }
        
        if let statusesCount = user?.statusesCount {
            headerView.tweetsLabel.text = String(describing: statusesCount)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if channel != .PROFILE {
            print("contentinset: \(tableView.contentInset)")
            return CGFloat.leastNonzeroMagnitude
        }
        return 245
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func popUserProfile() {
        navigationController?.popViewController(animated: true)
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
//        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff)s"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff)m"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff)h"
        }
//        else if weekAgo < self {
//            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
//            return "\(diff)d"
//        }
        
        return dateOnlyDisplay()
        //        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        //        return "\(diff) weeks ago"
    }
    
    func dateTimeDisplay() -> String {
        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
        dateFormatter.dateFormat = "MM/dd/yy, h:mm a"
        dateFormatter.timeZone = TimeZone.current
        let timeStamp = dateFormatter.string(from: self)
        return timeStamp
    }
    
    func dateOnlyDisplay() -> String {
        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
        dateFormatter.dateFormat = "MM/dd/yy"
        dateFormatter.timeZone = TimeZone.current
        let timeStamp = dateFormatter.string(from: self)
        return timeStamp
    }
}
