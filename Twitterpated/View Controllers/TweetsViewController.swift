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

class TweetsViewController: UIViewController {

    @IBOutlet weak var tweetsTableView: UITableView!
    var tweets = [Tweet]()
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    
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
        
        TwitterClient.sharedInstance.homeTimeLine(lastId: lastId, success: { (tweets: [Tweet]) in
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
            print("gettweets works")
            for tweet in tweets {
                if tweet.id != TwitterClient.lastTweetId {
                    self.tweets.append(tweet)
                }
            }
            self.tweetsTableView.reloadData()
        }, failure: { (error: Error) in
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
        })
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
                }
            }
        }
        
    }
}

extension TweetsViewController: NewTweetViewControllerDelegate {
    func newTweet(newTweet: NewTweetViewController, tweet: Tweet) {
        tweets.insert(tweet, at: 0)
        tweetsTableView.reloadData()
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
