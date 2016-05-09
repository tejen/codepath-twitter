//
//  TweetTableViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 5/9/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class TweetTableViewController: UIViewController {

    // MARK: - Properties

    // MARK: Private Properties
    private var refreshControl: UIRefreshControl!
    private var loadingMoreView: InfiniteScrollActivityView?
    private var isMoreDataLoading = false
    private var reloadedIndexPaths = [Int]()
    private var tweets: [Tweet]? {
        didSet {
            if tweets?.count > 0 {
                lastTweetId = tweets![tweets!.endIndex - 1].TweetID as Int
            }
        }
    }

    // MARK: Public Properties
    var tableView: UITableView!
    var lastTweetId: Int?

    // MARK: - Lifecycle Methods
    func configureViewController() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0

        reloadData()

        // Set up Pull To Refresh loading indicator
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullRefresh), forControlEvents: .ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        // Set up Infinite Scroll loading indicator
        let frame = CGRect(
            x: 0,
            y: tableView.contentSize.height,
            width: tableView.bounds.size.width,
            height: InfiniteScrollActivityView.defaultHeight
        )
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
    }

    // MARK: - Internal Methods
    func reloadCompletion(append: Bool = false) -> (([Tweet]) -> ()) {
        var completion = { (tweets: [Tweet]) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }

        if append {
            completion = { (tweets: [Tweet]) -> () in
                var cleaned = tweets
                if tweets.count > 0 {
                    cleaned.removeAtIndex(0) // api param "max_id" is inclusive
                }
                if cleaned.count > 0 {
                    self.tweets?.appendContentsOf(cleaned)
                    self.isMoreDataLoading = false
                    self.loadingMoreView!.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        } else {
            lastTweetId = nil
        }

        return completion
    }

    func pullRefresh() {
        lastTweetId = nil
        reloadData()
    }

    func reloadData(append: Bool = false) {
        // must be overidden by subclasses (ie. HomeViewController, ProfileViewController, etc...)
        fatalError("reloadData() called without being overridden by specific view controller subclass.")
    }

    func tableViewScrollToBottom(animated: Bool) {
        delay(0.1) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections-1)

            if numberOfRows > 1 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
                self.tableView.cellForRowAtIndexPath(indexPath)?.layer.backgroundColor = UIColor(red: 1.0, green: 241/255.0, blue: 156/255.0, alpha: 1).CGColor
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.tableView.cellForRowAtIndexPath(indexPath)?.layer.backgroundColor = UIColor.clearColor().CGColor
                })
            }
        }
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "toDetails" else {
            return // no preprocessing needed
        }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem

        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let tweet = tweets![indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailsViewController
        detailViewController.tweet = tweet
    }

}

// MARK: - TweetTableViewDelegate
extension TweetTableViewController: TweetTableViewDelegate {

    func reloadTableCellAtIndexPath(cell: UITableViewCell, indexPath: NSIndexPath) {
        guard reloadedIndexPaths.indexOf(indexPath.row) == nil else {
            return // already reloaded
        }
        reloadedIndexPaths.append(indexPath.row)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    func openProfile(userScreenname: NSString) {
        let vc = AppInfo.storyboard.instantiateViewControllerWithIdentifier("ProfileViewNavigationController") as! UINavigationController
        let pVc = vc.viewControllers.first as! ProfileViewController
        pVc.userScreenname = userScreenname
        self.presentViewController(vc, animated: true, completion: nil)
    }

    func openCompose(vc: UIViewController) {
        self.presentViewController(vc, animated: true, completion: nil)
    }

}

// MARK: - UIScrollViewDelegate
extension TweetTableViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isMoreDataLoading && tweets?.count > 0 {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height

            // When the user has scrolled past the threshold, start requesting
            if scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging {
                isMoreDataLoading = true
                reloadData(true)
            }
        }
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TweetTableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delay(0.2) {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCompactCell", forIndexPath: indexPath) as! TweetCompactCell
        cell.indexPath = indexPath
        cell.tweet = tweets![indexPath.row]
        cell.delegate = self
        return cell
    }

}
