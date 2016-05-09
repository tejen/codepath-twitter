//
//  TwitterClient.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/19/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

final class TwitterClient: BDBOAuth1SessionManager {

    // MARK: Constants
    static let sharedInstance = TwitterClient(
        baseURL: NSURL(string: "https://api.twitter.com"),
        consumerKey: "U04FBOTu0NpvIxZnxehbXjqE3",
        consumerSecret: "cT8OrcKsG3kXTC8QLYXmwm1iUECvVqc0VHnq8NhUAMpytm7Uh8"
    )

    // MARK: Private Properties
    var loginSuccess: (() -> ())?
    var loginFailure: ((NSError) -> ())?

    var buffer: Tweet?
    var bufferComplete: (() -> ())?

    var attemptingLogin = false {
        didSet {
            if attemptingLogin {
                delegate?.doNotContinueLogin()
            }
        }
    }

    weak var delegate: TwitterLoginLoungeDelegate? {
        didSet {
            if attemptingLogin {
                delegate!.doNotContinueLogin()
            }
        }
    }

    // MARK: - Private Methods
    func login(success: () -> (), failure: (NSError) -> ()) {
        loginSuccess = success
        loginFailure = failure

        deauthorize()
        fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "twitterTejen://oauth")!, scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token="+requestToken.token)!
            UIApplication.sharedApplication().openURL(url)
        }, failure: { (error: NSError!) -> Void in
                print("API Error: \(error.localizedDescription)")
                self.loginFailure!(error) // can force. value was set earlier on in login().
        })
    }

    func logout() {
        User.currentUser = nil
        deauthorize()

        NSNotificationCenter.defaultCenter().postNotificationName(AppInfo.notifications.UserDidLogout, object: nil)
    }

    func handleOpenUrl(url: NSURL) {
        attemptingLogin = true

        let requestToken = BDBOAuth1Credential(queryString: url.query)

        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) -> Void in
            self.currentAccount({ user in
                User.currentUser = user
                self.loginSuccess?()
                self.attemptingLogin = false
                self.delegate?.continueLogin()
            }, failure: { error in
                self.loginFailure?(error)
            })
            self.loginSuccess?()
        }, failure: { (error: NSError!) -> Void in
            print("error: " + error.localizedDescription)
            self.loginFailure?(error)
        })
    }

    func currentAccount(success: (User) -> (), failure: (NSError) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            print("error: \(error.localizedDescription)")
            failure(error)
        })
    }

    func homeTimeline(maxId: Int? = nil, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        var params = ["count": 10]
        if maxId != nil {
            params["max_id"] = maxId
        }

        // dummy api to overcome rate limit problems:
        // https://tejen.net/sub/codepath/twitter/#home_timeline.json
        get("1.1/statuses/home_timeline.json", parameters: params, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            success(tweets)
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        })
    }

    func user_timeline(user: User, maxId: Int? = nil, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        var params = ["count": 10]
        params["user_id"] = user.id!
        if maxId != nil {
            params["max_id"] = maxId
        }

        get("1.1/statuses/user_timeline.json", parameters: params, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            success(tweets)
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        })
    }

    func favorite(params: NSDictionary?, favorite: Bool, completion: (tweet: Tweet?, error: NSError?) -> (Void) = {_, _ in }) {
        let endpoint = favorite ? "create" : "destroy"
        post("1.1/favorites/\(endpoint).json", parameters: params, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
        }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
            completion(tweet: nil, error: error)
        })
    }

    func retweet(params: NSDictionary?, retweet: Bool, completion: (tweet: Tweet?, error: NSError?) -> (Void) = {_, _ in }) {
        let tweetID = params!["id"] as! Int
        let endpoint = retweet ? "retweet" : "unretweet"
        post("1.1/statuses/\(endpoint)/\(tweetID).json", parameters: params, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
        }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
            completion(tweet: nil, error: error)
        })
    }

    func populateTweetByID(TweetID: Int, completion: ((tweet: Tweet?, error: NSError?) -> (Void))? = nil) {
        get("1.1/statuses/show.json?id=\(TweetID)", parameters: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            completion?(tweet: tweet, error: nil)
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            completion?(tweet: nil, error: error)
        })
    }

    func populatePreviousTweets(tweet: Tweet, completion: (()->())? = nil) {
        bufferComplete = completion ?? bufferComplete

        print("populating previous tweet for: \(tweet.TweetID)")

        guard tweet.precedingTweetID != nil else { // base case
            print("chain complete")
            self.buffer = nil
            self.bufferComplete?()
            return
        }

        buffer = tweet
        populateTweetByID(tweet.precedingTweetID!) { (tweet, error) -> (Void) in
            self.buffer?.precedingTweet = tweet
            self.populatePreviousTweets(tweet!)
        }
    }

    func publishTweet(text: String, replyToTweetID: NSNumber? = 0, success: (Tweet) -> ()) {
        // Warning: this'll create a live tweet with the given text on behalf of the current user!
        guard text.characters.count > 0 else {
            return
        }
        let params = ["status": text, "in_reply_to_status_id": Int(replyToTweetID!)]
        post("1.1/statuses/update.json", parameters: params, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
        })
    }

    func getUserByScreenname(screenname: NSString, success: (User) -> (), failure: ((NSError) -> ())? = nil) {
        get("1.1/users/lookup.json?screen_name=" + String(screenname), parameters: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let userDictionary = response as! [NSDictionary]
            let user = User(dictionary: userDictionary[0])
            success(user)
        }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
            print("error: \(error.localizedDescription)")
            failure?(error)
        })
    }

    func get(endpoint: String, parameters: NSDictionary?, success: ((operation: NSURLSessionDataTask, response: AnyObject?) -> ()), failure: ((operation: NSURLSessionDataTask?, error: NSError) -> ())? = nil) {
        GET(endpoint, parameters: parameters, success: success, failure: failure)
    }

    func post(endpoint: String, parameters: NSDictionary?, success: ((operation: NSURLSessionDataTask, response: AnyObject?) -> ()), failure: ((operation: NSURLSessionDataTask?, error: NSError) -> ())? = nil) {
        POST(endpoint, parameters: parameters, success: success, failure: failure)
    }

}
