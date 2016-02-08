//
//  User.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/7/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

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
}
