//
//  TweetCell.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/22/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class TweetExtendedCell: UITableViewCell {
    
    @IBOutlet var authorNameLabel: UILabel!
    @IBOutlet var authorScreennameLabel: UILabel!
    @IBOutlet var profilePictureImageView: UIImageView!
    
    @IBOutlet var tweetContentsLabel: UILabel!
    @IBOutlet var tweetAgeLabel: UILabel!
    
    @IBOutlet var retweetButton: DOFavoriteButton!
    @IBOutlet var favoriteButton: DOFavoriteButton!
    
    @IBOutlet var retweetCountLabel: UILabel!
    @IBOutlet var favoriteCountLabel: UILabel!
    
    @IBOutlet var mediaImageVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet var mediaImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var mediaImageView: UIImageView!
    
    var tweetID: NSNumber?;
    
    weak var delegate: TweetTableViewDelegate?;
    
    var indexPath: NSIndexPath!;
    
    var tweet: Tweet! {
        didSet {
            tweetID = tweet.TweetID;
            profilePictureImageView.setImageWithURL(tweet.authorProfilePicURL!);
            profilePictureImageView.layer.cornerRadius = 5;
            profilePictureImageView.clipsToBounds = true;
            authorNameLabel.text = tweet.author as? String;
            authorScreennameLabel.text = "@" + (tweet.screenname as! String);
            
            tweetContentsLabel.text = tweet.text as? String;
            tweetAgeLabel.text = Tweet.localizedTimestamp(tweet.timestamp!);
            
            let urls = tweet.urls;
            let media = tweet.media;
            
            retweetCountLabel.text = String(tweet.retweetCount);
            
            favoriteCountLabel.text = String(tweet.favoritesCount);
            
            retweetButton.selected = tweet.retweeted;
            favoriteButton.selected = tweet.favorited;
            
            mediaImageView.image = nil;
            
            var displayUrls = [String]();
            
            if let urls = urls {
                for url in urls {
                    let urltext = url["url"] as! String;
                    tweetContentsLabel.text = tweetContentsLabel.text?.replace(urltext, withString: "");
                    
                    let displayurl = url["display_url"] as! String;
                    displayUrls.append(displayurl);
                }
            }
            
            if let media = media {
                for medium in media {
                    let urltext = medium["url"] as! String;
                    tweetContentsLabel.text = tweetContentsLabel.text?.replace(urltext, withString: "");
                    if((medium["type"] as? String) == "photo") {
                        mediaImageVerticalSpacingConstraint.constant = 16;
                        let mediaurl = medium["media_url_https"] as! String;
                        mediaImageView.alpha = 1;
                        
                        mediaImageHeightConstraint.active = false;
                        
                        mediaImageView.layer.cornerRadius = 5;
                        mediaImageView.clipsToBounds = true;
                        mediaImageView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: mediaurl)!), placeholderImage: nil, success: { (r: NSURLRequest, u: NSHTTPURLResponse?, i: UIImage) -> Void in
                            // success
                            self.mediaImageView.image = i;
                            self.delegate?.reloadTableCellAtIndex(self, indexPath: self.indexPath);
                            }, failure: { (r: NSURLRequest, u: NSHTTPURLResponse?, e: NSError) -> Void in
                                // error
                        });
                    }
                }
            }
            
            if(displayUrls.count > 0){
                let content = tweetContentsLabel.text ?? "";
                
                let urlText = " " + displayUrls.joinWithSeparator(" ");
                
                let text = NSMutableAttributedString(string: content);
                text.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(20.0, weight: UIFontWeightLight), range: NSRange(location: 0, length: content.characters.count));
                
                let links = NSMutableAttributedString(string: urlText);
                links.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(20.0, weight: UIFontWeightLight), range: NSRange(location: 0, length: urlText.characters.count));
                links.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 36/255.0, green: 144/255.0, blue: 212/255.0, alpha: 1), range: NSRange(location: 0, length: urlText.characters.count));
                
                text.appendAttributedString(links);
                
                let style = NSMutableParagraphStyle();
                style.lineSpacing = 5;
                style.lineBreakMode = .ByCharWrapping;
                text.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: text.string.characters.count));
                
                tweetContentsLabel.attributedText = text;
            }
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("openProfile"));
            authorNameLabel.userInteractionEnabled = true;
            authorNameLabel.addGestureRecognizer(tapGestureRecognizer);
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
    
    
    @IBAction func onReplyButton(sender: DOFavoriteButton) {
        sender.select();
        print("reply");
    }
    
    @IBAction func onRetweetButton(sender: DOFavoriteButton) {
        if(sender.selected) {
            // deselect
            sender.deselect();
            tweet.retweeted = false;
            retweetCountLabel.text = String(tweet.retweetCount) ?? "";
        } else {
            // select with animation
            sender.select();
            tweet.retweeted = true;
            retweetCountLabel.text = String(tweet.retweetCount) ?? "";
        }
    }
    
    @IBAction func onFavoriteButton(sender: DOFavoriteButton) {
        if(sender.selected) {
            // deselect
            sender.deselect();
            tweet.favorited = false;
            favoriteCountLabel.text = String(tweet.favoritesCount) ?? "";
        } else {
            // select with animation
            sender.select();
            tweet.favorited = true;
            favoriteCountLabel.text = String(tweet.favoritesCount) ?? "";
        }
    }
    
    func openProfile(){
        self.delegate!.openProfile(tweet.screenname!);
    }
    
}