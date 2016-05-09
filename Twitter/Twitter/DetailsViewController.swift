//
//  DetailsViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/28/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

final class DetailsViewController: TweetTableViewController {

    // MARK: - Properties

    // MARK: Public Properties
    var tweet: Tweet?
    var closeNavBarOnDisappear = false

    // MARK: Private Properties
    private var rootTweetID: NSNumber?

    private var tweetChain = [Tweet]()
    private var chainIsPopulated = false {
        didSet {
            if tweetChain.count > 1 {
                self.title = "Conversation"
            } else {
                self.title = "Tweet"
            }
        }
    }

    private var tweetComposedReply: Tweet?

    private var lastIndexPath: NSIndexPath?

    // MARK: - IBOutlets
    @IBOutlet var tableViewOutlet: UITableView! {
        didSet {
            tableView = tableViewOutlet
        }
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0

        rootTweetID = tweet!.TweetID

        NSNotificationCenter.defaultCenter().addObserverForName(AppInfo.notifications.DetailsTweetChainReady, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            while(self.tweet != nil) {
                self.tweetChain.insert(self.tweet!, atIndex: 0)
                self.tweet = self.tweet!.precedingTweet
            }
            self.chainIsPopulated = true
            self.tableView.reloadData()
        }

        TwitterClient.sharedInstance.populatePreviousTweets(tweet!, completion: { _ in
            NSNotificationCenter.defaultCenter().postNotificationName(AppInfo.notifications.DetailsTweetChainReady, object: nil)
        })
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if closeNavBarOnDisappear {
            self.navigationController?.navigationBarHidden = true
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.navigationBarHidden = false
        tableViewScrollToBottom(true)
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DetailsViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chainIsPopulated ? tweetChain.count : 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellTweet = tweetChain[indexPath.row]

        var cellType = "TweetCompactCell"
        if cellTweet.TweetID == rootTweetID {
            cellType = "TweetExpandedCell"
            lastIndexPath = indexPath
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(cellType, forIndexPath: indexPath) as! TweetCell
        cell.indexPath = indexPath
        cell.tweet = cellTweet
        cell.delegate = self
        return cell
    }

}
