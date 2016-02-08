//
//  TweetsTableViewCell.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/7/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class TweetsTableViewCell: UITableViewCell {
    

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var tweetContentText: UILabel!
    @IBOutlet weak var createdTime: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
