//
//  DetailsViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/28/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TweetTableViewDelegate {
    
    var rootTweetID: NSNumber?;
    
    var tweet: Tweet?;
    var closeNavBarOnDisappear = false;
    
    var tweetChain = [Tweet]();
    var chainIsPopulated = false;
    
    var tweetComposedReply: Tweet?;
    
    var lastIndexPath: NSIndexPath?;

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 160.0;
        
        rootTweetID = tweet!.TweetID;
        
        NSNotificationCenter.defaultCenter().addObserverForName("DetailsTweetChainReady", object: nil, queue: NSOperationQueue.mainQueue()) { (NSNotification) -> Void in
            while(self.tweet != nil) {
                self.tweetChain.insert(self.tweet!, atIndex: 0);
                self.tweet = self.tweet!.precedingTweet;
            }
            self.chainIsPopulated = true;
            self.tableView.reloadData();
        };
        
        TwitterClient.sharedInstance.populatePreviousTweets(tweet!, completion: { () -> (Void) in
                NSNotificationCenter.defaultCenter().postNotificationName("DetailsTweetChainReady", object: nil);
            }
        );
        
        self.navigationController?.navigationBarHidden = false;
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        if(closeNavBarOnDisappear) {
            self.navigationController?.navigationBarHidden = true;
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        tableViewScrollToBottom(true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(chainIsPopulated == true) {
            return tweetChain.count;
        }
        
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellTweet = tweetChain[indexPath.row];
        if(cellTweet.TweetID == rootTweetID) {
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetExpandedCell", forIndexPath: indexPath) as! TweetExtendedCell;
            cell.indexPath = indexPath;
            cell.tweet = cellTweet;
            cell.delegate = self;
            lastIndexPath = indexPath;
            return cell;
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetCompactCell", forIndexPath: indexPath) as! TweetCompactCell;
            cell.indexPath = indexPath;
            cell.tweet = cellTweet;
            cell.delegate = self;
            return cell;
        }
    }
    
    var reloadedIndexPaths = [Int]();
    
    func reloadTableCellAtIndex(cell: UITableViewCell, indexPath: NSIndexPath) {
        if(reloadedIndexPaths.indexOf(indexPath.row) == nil) {
            reloadedIndexPaths.append(indexPath.row);
            try! tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic);
        }
    }
    
    func openProfile(userScreenname: NSString){
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle());
        let vc = storyboard.instantiateViewControllerWithIdentifier("ProfileViewNavigationController") as! UINavigationController;
        let pVc = vc.viewControllers.first as! ProfileViewController;
        pVc.userScreenname = userScreenname;
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
    func openCompose(vc: UIViewController) {
        self.presentViewController(vc, animated: true, completion: nil);
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 1 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated);
                self.tableView.cellForRowAtIndexPath(indexPath)?.layer.backgroundColor = UIColor(red: 1.0, green: 241/255.0, blue: 156/255.0, alpha: 1).CGColor;
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.tableView.cellForRowAtIndexPath(indexPath)?.layer.backgroundColor = UIColor.clearColor().CGColor;
                });
            }
            
        })
    }
    
}
