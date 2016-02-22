//
//  TwitterClient.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/19/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
 
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com"), consumerKey: "U04FBOTu0NpvIxZnxehbXjqE3", consumerSecret: "cT8OrcKsG3kXTC8QLYXmwm1iUECvVqc0VHnq8NhUAMpytm7Uh8");
    
    var loginSuccess: (() -> ())?;
    var loginFailure: ((NSError) -> ())?;
    
    func login(success: () -> (), failure: (NSError) -> ()){
        loginSuccess = success;
        loginFailure = failure;
        
        deauthorize();
        fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "twitterTejen://oauth")!, scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            print("Got token");
            
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token="+requestToken.token)!;
            UIApplication.sharedApplication().openURL(url);
            
            }) { (error: NSError!) -> Void in
                print("error: \(error.localizedDescription)");
                self.loginFailure?(error);
        }
    }
    
    func logout() {
        User.currentUser = nil;
        deauthorize();
        
        NSNotificationCenter.defaultCenter().postNotificationName(User.userDidLogoutNotification, object: nil);
    }
    
    func handleOpenUrl(url: NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query);
        
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) -> Void in
            self.currentAccount({ (user: User) -> () in
                    User.currentUser = user;
                    self.loginSuccess?();
                }, failure: { (error: NSError) -> () in
                    self.loginFailure?(error);
            });
            self.loginSuccess?();
        }) { (error: NSError!) -> Void in
            print("error: " + error.localizedDescription);
            self.loginFailure?(error);
        }
    }
    
    func currentAccount(success: (User) -> (), failure: (NSError) -> ()) {
        GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            let userDictionary = response as! NSDictionary;
            let user = User(dictionary: userDictionary);
            
            success(user);
            
            print(user.name);
            print(user.screenname);
            print(user.profileUrl);
            print(user.tagline);
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("error: \(error.localizedDescription)");
                failure(error);
        });
    }
    
    func homeTimeline(success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            let dictionaries = response as! [NSDictionary];
            let tweets = Tweet.tweetsWithArray(dictionaries);
            
            success(tweets)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error);
        })
    }
    
}
