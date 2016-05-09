//
//  User.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/19/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

final class User: NSObject {

    // MARK: Private Properties
    var id: Int?

    var name: NSString?
    var screenname: NSString?
    var profileUrl: NSURL?
    var tagline: NSString?
    var backgroundImageURL: String?
    var hasBannerImage = true

    var followersCount: Int?
    var followingCount: Int?

    var locationString: NSString?
    var protected: Bool?

    var dictionary: NSDictionary?

    // MARK: Public Properties
    static var _currentUser: User?
    static var bufferUser: User?

    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                let userData = defaults.objectForKey("currentUser") as? NSData

                if let userData = userData {
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(userData, options: []) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user

            let defaults = NSUserDefaults.standardUserDefaults()

            if let user = user {
                let data = try! NSJSONSerialization.dataWithJSONObject(user.dictionary!, options: [])
                defaults.setObject(data, forKey: "currentUser")
            } else {
                defaults.setObject(nil, forKey: "currentUser")
            }

            defaults.synchronize()
        }
    }

    // MARK: - Lifecycle Methods
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary

        id = dictionary["id"] as? Int

        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String

        backgroundImageURL = dictionary["profile_banner_url"] as? String
        if backgroundImageURL != nil {
            backgroundImageURL?.appendContentsOf("/600x200")
        } else {
            backgroundImageURL = dictionary["profile_background_image_url_https"] as? String
            hasBannerImage = false
        }
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        profileUrl = NSURL(string: profileUrlString!.replace("normal.png", withString: "bigger.png"))

        followersCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int

        locationString = dictionary["location"] as? String

        protected = dictionary["protected"] as? Bool

        tagline = dictionary["description"] as? String
    }

}
