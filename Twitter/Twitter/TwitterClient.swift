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
    
}
