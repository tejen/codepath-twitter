//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/7/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tweets: [Tweet]?;
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self;
        tableView.delegate = self;
        
        // Do any additional setup after loading the view.
        
        tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
        TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets, error) -> () in
            self.tweets = tweets;
            self.tableView.reloadData();
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser!.logout();
        
    }
    
    func testTweets() {
        let tweet = tweets![0];
        print(tweet.user!.name);
//        Tweet.user.name
//        Tweet.user.screenname
//        Tweet.user.profileImageUrl
//        Tweet.text
//        Tweet.createdAtString
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = self.tweets {
            return tweets.count;
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath) as! TweetsTableViewCell;
        
        cell.profileImage.setImageWithURL(NSURL(string: tweets![indexPath.row].user!.profileImageUrl!)!);
        cell.userName.text = tweets![indexPath.row].user!.name!;
        cell.userHandle.text = tweets![indexPath.row].user!.screenname!;
        cell.tweetContentText.text = tweets![indexPath.row].text!;
        cell.createdTime.text = tweets![indexPath.row].createdAtString!;
        
        return cell;
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
