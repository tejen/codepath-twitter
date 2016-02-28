//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/28/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, TweetTableViewDelegate {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var profileImageSuperview: UIView!
    @IBOutlet var screennameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var followersCountLabel: UILabel!
    
    @IBOutlet var imageCogIcon: UIImageView!
    
    @IBOutlet var shadowEffectView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!;
    var isMoreDataLoading = false;
    var loadingMoreView: InfiniteScrollActivityView?;
    
    var lastTweetId: Int?;
    
    var tweets: [Tweet]? {
        didSet {
            if(tweets?.count > 0) {
                lastTweetId = tweets![tweets!.endIndex - 1].TweetID as Int;
            }
        }
    };
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let profileImageUrl = User.currentUser?.profileUrl;
        let backgroundImageUrl = User.currentUser?.backgroundImageURL;
        
        let name = User.currentUser?.name;
        let screenname = User.currentUser?.screenname;
        let protected = User.currentUser?.protected;
        let location = User.currentUser?.locationString;
        let followingCount = User.currentUser?.followingCount;
        let followersCount = User.currentUser?.followersCount;
        
        profileImageView.setImageWithURL(profileImageUrl!);
        backgroundImageView.setImageWithURL(NSURL(string: backgroundImageUrl!)!);
        profileImageView.clipsToBounds = true;
        profileImageView.layer.cornerRadius = 5;
        profileImageSuperview.layer.cornerRadius = 5;
        
        screennameLabel.text = "@" + String(screenname!);
        locationLabel.text = String(location!);
        
        followersCountLabel.text = shortenNumber(823900000);
        followingCountLabel.text = shortenNumber(2240);
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("profileCogMenu"));
        imageCogIcon.userInteractionEnabled = true;
        imageCogIcon.addGestureRecognizer(tapGestureRecognizer);
        
        let gradientLayer = CAGradientLayer();
        gradientLayer.frame = shadowEffectView.bounds;
        let topColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor as CGColorRef;
        let bottomColor = UIColor(white: 0, alpha: 0.0).CGColor as CGColorRef;
        gradientLayer.colors = [topColor, bottomColor];
        gradientLayer.locations = [0.0, 1.0];
        self.shadowEffectView.layer.addSublayer(gradientLayer);
        
        // table
        
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 160.0;

        reloadData();
        
        
        // Set up Pull To Refresh loading indicator
        refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: "reloadData:", forControlEvents: UIControlEvents.ValueChanged);
        refreshControl.layer.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0).CGColor as! CGColorRef;
        tableView.insertSubview(refreshControl, atIndex: 0);
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
        loadingMoreView = InfiniteScrollActivityView(frame: frame);
        loadingMoreView!.hidden = true;
        loadingMoreView!.layer.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0).CGColor as! CGColorRef;
        tableView.addSubview(loadingMoreView!);
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func profileCogMenu() {
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet);
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)

        let deleteActionButton: UIAlertAction = UIAlertAction(title: "Sign Out", style: .Destructive)
            { action -> Void in
                TwitterClient.sharedInstance.logout();
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        
        self.presentViewController(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    func shortenNumber(var number: Double) -> String {
        if(number > 999999999) {
            number = number/1000000000;
            return String(format: "%.1f", number) + "B";
        }
        if(number > 999999) {
            number = number/1000000;
            return String(format: "%.1f", number) + "M";
        }
        if(number > 9999) {
            number = number/1000;
            return String(format: "%.1f", number) + "K";
        }
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        return numberFormatter.stringFromNumber(number)!;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tweets == nil) {
            return 0;
        } else {
            return tweets!.count;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell;
        cell.indexPath = indexPath;
        cell.tweet = tweets![indexPath.row];
        cell.delegate = self;
        return cell;
    }
    
    var reloadedIndexPaths = [Int]();
    
    func reloadTableCellAtIndex(cell: TweetCell, indexPath: NSIndexPath) {
        if(reloadedIndexPaths.indexOf(indexPath.row) == nil) {
            reloadedIndexPaths.append(indexPath.row);
            try! tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic);
        }
    }
    
    func reloadData(append: Bool = false) {
        var completion = { (tweets: [Tweet]) -> () in
            self.tweets = tweets;
            self.tableView.reloadData();
            self.refreshControl.endRefreshing()
        };
        
        if(append) {
            completion = { (tweets: [Tweet]) -> () in
                var cleaned = tweets;
                if(tweets.count > 1) {
                    cleaned.removeAtIndex(0); // api param "max_id" is inclusive
                }
                self.tweets?.appendContentsOf(cleaned); // api param "max_id" is inclusive);
                self.isMoreDataLoading = false
                self.loadingMoreView!.stopAnimating()
                self.tableView.reloadData();
            };
        } else {
            lastTweetId = nil;
        }
        
        TwitterClient.sharedInstance.myTweets(lastTweetId, success: completion, failure: { (error: NSError) -> () in
            print(error.localizedDescription);
        });
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading && tweets?.count > 0) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height;
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                reloadData(true);
                // ... Code to load more results ...
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
