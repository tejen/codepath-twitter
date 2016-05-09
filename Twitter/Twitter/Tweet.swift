//
//  Tweet.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/19/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

final class Tweet: NSObject {

    // MARK: - Properties
    var TweetID: NSNumber!
    var screenname: NSString?
    var author: NSString?
    var authorProfilePicURL: NSURL?

    var urls: [NSDictionary]?
    var media: [NSDictionary]?

    var text: NSString?
    var timestamp: NSDate?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0

    var precedingTweetID: Int?
    var precedingTweet: Tweet?

    var favorited: Bool {
        didSet {
            if favorited {
                favoritesCount += 1
                TwitterClient.sharedInstance.favorite(["id": TweetID], favorite: true)
            } else {
                favoritesCount -= 1
                TwitterClient.sharedInstance.favorite(["id": TweetID], favorite: false)
            }
        }
    }
    var retweeted: Bool {
        didSet {
            if retweeted {
                retweetCount += 1
                TwitterClient.sharedInstance.retweet(["id": TweetID], retweet: true) { (tweet, error) in
                    print("retweeted")
                }
            } else {
                retweetCount -= 1
                TwitterClient.sharedInstance.retweet(["id": TweetID], retweet: false) { (tweet, error) in
                    print("unretweeted")
                }
            }
        }
    }

    // MARK: - Lifecycle Methods
    init(dictionary: NSDictionary) {
        TweetID = dictionary["id"] as! NSNumber
        precedingTweetID = dictionary["in_reply_to_status_id"] as? Int

        urls = dictionary["entities"]?["urls"] as? [NSDictionary]
        media = dictionary["entities"]?["media"] as? [NSDictionary]
        screenname = dictionary["user"]!["screen_name"] as? String
        author = dictionary["user"]!["name"] as? String
        authorProfilePicURL = NSURL(string: (dictionary["user"]!["profile_image_url_https"] as! String).replace("normal.png", withString: "bigger.png"))!

        text = dictionary["text"] as? String

        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0

        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        favorited = (dictionary["favorited"] as? Bool) ?? false

        let timestampString = dictionary["created_at"] as? String

        if let timestampString = timestampString {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.dateFromString(timestampString)
        }
    }

    // MARK: - Public Helper Functions
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()

        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }

        return tweets
    }

}
