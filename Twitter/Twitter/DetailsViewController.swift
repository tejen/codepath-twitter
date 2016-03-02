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
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        if(closeNavBarOnDisappear) {
            self.navigationController?.navigationBarHidden = true;
        }
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
            return cell;
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell;
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
        let vc = storyboard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController;
        vc.userScreenname = userScreenname;
        self.presentViewController(vc, animated: true, completion: nil);
    }

}
