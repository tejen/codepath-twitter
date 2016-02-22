//
//  TweetCell.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/22/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    @IBOutlet var authorNameLabel: UILabel!
    @IBOutlet var authorScreennameLabel: UILabel!
    @IBOutlet var profilePictureImageView: UIImageView!
    
    @IBOutlet var tweetContentsLabel: UILabel!
    
    var tweet: Tweet! {
        didSet {
            print("prof pic:");
            print(tweet.authorProfilePicURL);
            profilePictureImageView.setImageWithURL(tweet.authorProfilePicURL!);
            profilePictureImageView.layer.cornerRadius = 5;
            authorNameLabel.text = tweet.author as? String;
            authorScreennameLabel.text = "@" + (tweet.screenname as! String);
            
            tweetContentsLabel.text = tweet.text as? String;

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
