//
//  TwitterClient.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/7/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterConsumerKey = "U04FBOTu0NpvIxZnxehbXjqE3";
let twitterConsumerSecret = "cT8OrcKsG3kXTC8QLYXmwm1iUECvVqc0VHnq8NhUAMpytm7Uh8";
let twitterBaseURL = NSURL(string: "https://api.twitter.com");

class TwitterClient: BDBOAuth1SessionManager {

    var loginCompletion: ((user: User?, error: NSError?) -> ())?;
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(
                baseURL: twitterBaseURL,
                consumerKey: twitterConsumerKey,
                consumerSecret: twitterConsumerSecret
            );
        }
        
        return Static.instance;
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        
        loginCompletion = completion;
        
        
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken();
        
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitter://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            print("Got the request token");
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)");
            UIApplication.sharedApplication().openURL(authURL!);
            }) { (error: NSError!) -> Void in
                print("Failed to get request token");
                self.loginCompletion?(user: nil, error: error);
        }
    }
    
    func openURL(url: NSURL){
        
        TwitterClient.sharedInstance.fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query)!, success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("Got the access token!");
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken);
            
        TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: NSURLSessionDataTask, response: AnyObject) -> Void in
                
                
            var user = User(dictionary: response as! NSDictionary);
            self.loginCompletion?(user: user, error: nil);
            
//                var tweets = Tweet.tweetsWithArray(response as! [NSDictionary]);
            
                }, failure: { (operation:NSURLSessionDataTask?, error: NSError) -> Void in
                    print("error getting current user");
                    self.loginCompletion?(user: nil, error: error);
            })
            
            }) { (error: NSError!) -> Void in
                print("Failed to receive access token");
                self.loginCompletion?(user: nil, error: error);
        }
    }
    
}
