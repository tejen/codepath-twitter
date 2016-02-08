//
//  User.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/7/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "kCuurentUserKey";
let userDidLoginNotification = "userDidLoginNotification";
let userDidLogoutNotification = "userDidLogoutNotification";

class User: NSObject {
    var name: String?;
    var screenname: String?;
    var profileImageUrl: String?;
    var tagline: String?;
    var dictionary: NSDictionary;
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary;
        
        name = dictionary["name"] as? String;
        screenname = dictionary["screen_name"] as? String;
        profileImageUrl = dictionary["profile_image_url"] as? String;
        tagline = dictionary["description"] as? String;
    }
    
    func logout() {
        User.currentUser = nil;
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken();
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil);
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
            let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData;
                if data != nil {
                    do {
                        let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions());
                        _currentUser = User(dictionary: dictionary as! NSDictionary);
                    } catch _ {
        
                    }
                }
            }
            return _currentUser;
        }
        set(user) {
            _currentUser = user;
            
            if _currentUser != nil {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: NSJSONWritingOptions());
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey);
                } catch _ {
                    
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey);
            }
            NSUserDefaults.standardUserDefaults().synchronize();
        }
    }
}
