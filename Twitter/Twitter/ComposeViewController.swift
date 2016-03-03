//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 3/1/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screennameLabel: UILabel!
    @IBOutlet var inputText: UITextView!
    @IBOutlet var replyScreennameLabel: UILabel!
    
    var charCountLabel: UILabel!;
    var tweetButton: UIButton!;
    
    var replyToTweet: Tweet?;
    
    let charCountLabelNormalTextColor = UIColor(red: 136/255.0, green: 146/255.0, blue: 158/255.0, alpha: 1);
    let tweetButtonEnabledBackgroundColor = UIColor(red: 29/255.0, green: 161/255.0, blue: 243/255.0, alpha: 1);
    let tweetButtonDisabledAccentColor = UIColor(red: 240/255.0, green: 242/255.0, blue: 245/255.0, alpha: 1);
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profileImageView.setImageWithURL((User.currentUser?.profileUrl)!);
        profileImageView.layer.cornerRadius = 5;
        
        inputText.delegate = self;
        
        nameLabel.text = User.currentUser?.name as! String;
        screennameLabel.text = "@" + (User.currentUser?.screenname as! String);
        
        let navigationBar = self.navigationController!.navigationBar;
        let charCountFrame = CGRect(x: 20, y: 0, width: navigationBar.frame.width/2, height: navigationBar.frame.height);
        charCountLabel = UILabel(frame: charCountFrame);
        charCountLabel.textColor = charCountLabelNormalTextColor;
        charCountLabel.text = "160";
        charCountLabel.frame = charCountFrame;
        navigationBar.addSubview(charCountLabel);
        
        let toolbarView = UIView(frame: CGRectMake(0, 0, 10, 50));
        inputText.inputAccessoryView = toolbarView;
        
        let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width;
        tweetButton = UIButton(frame: CGRect(x: screenWidth - 60 - 10, y: 10, width: 60, height: 30));
        tweetButton.backgroundColor = tweetButtonEnabledBackgroundColor;
        tweetButton.layer.cornerRadius = 5;
        tweetButton.titleLabel?.font = UIFont.systemFontOfSize(14.0);
        tweetButton.setTitle("Tweet", forState: .Normal);
        tweetButton.addTarget(self, action: "onTweetButton", forControlEvents: .TouchDown);
        toolbarView.addSubview(tweetButton);
        
        if(replyToTweet == nil) {
            print("not a reply");
            replyScreennameLabel.text = "";
        } else {
            replyScreennameLabel.hidden = false;
            replyScreennameLabel.text = "@" + (replyToTweet!.screenname! as String) + ":";
        }
        
        disableSending();
    }
    
    func onTweetButton() {
        var composedText = inputText.text;
        if(replyToTweet == nil) { // making a brand new tweet
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            appDelegate.switchToProfileTab(true);
        } else { // replying to someone else's tweet!
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            appDelegate.openTweetDetails(replyToTweet!);
            composedText = "@" + ((replyToTweet!.screenname!) as String) + ": " + composedText;
        }
        
        TwitterClient.sharedInstance.publishTweet(composedText, replyToTweetID: replyToTweet?.TweetID) { (newTweet: Tweet) -> () in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            appDelegate.openTweetDetails(newTweet);
        }
        
        dismissViewControllerAnimated(true, completion: nil);
    }

    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if(textView.text == "What's happening?") {
            textView.text = "";
            textView.textColor = UIColor.blackColor();
        }
        textView.becomeFirstResponder();
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if(textView.text == "") {
            textView.text = "What's happening?";
            textView.textColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1);
        }
        textView.resignFirstResponder();
    }
    
    func disableSending(invalid: Bool = false) {
        if(invalid) {
            charCountLabel.textColor = UIColor(red: 234/255.0, green: 48/255.0, blue: 54/255.0, alpha: 1);
        }
        tweetButton.backgroundColor = UIColor.whiteColor();
        tweetButton.enabled = false;
        tweetButton.setTitleColor(tweetButtonDisabledAccentColor, forState: .Normal);
        tweetButton.layer.borderWidth = 1;
        tweetButton.layer.borderColor = tweetButtonDisabledAccentColor.CGColor;
    }
    
    func enableSending() {
        charCountLabel.textColor = charCountLabelNormalTextColor;
        tweetButton.backgroundColor = tweetButtonEnabledBackgroundColor;
        tweetButton.setTitleColor(UIColor.whiteColor(), forState: .Normal);
        tweetButton.enabled = true;
        tweetButton.layer.borderWidth = 0;
    }
    
    func textViewDidChange(textView: UITextView) {
        let charCount = textView.text.characters.count;
        charCountLabel.text = String(160 - charCount);
        if(charCount == 0) {
            disableSending();
        }
        else if(charCount >= 160) {
            disableSending(true);
        } else {
            enableSending();
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
