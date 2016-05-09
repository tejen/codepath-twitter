//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 3/1/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

final class ComposeViewController: UIViewController {

    // MARK: - Properties

    // MARK: Public Properties
    var replyToTweet: Tweet?

    // MARK: Private Properties
    private var charCountLabel: UILabel!
    private var tweetButton: UIButton!

    // MARK: - Constants
    let charCountLabelNormalTextColor = UIColor(red: 136/255.0, green: 146/255.0, blue: 158/255.0, alpha: 1)
    let charCountLabelDangerTextColor = UIColor(red: 234/255.0, green: 48/255.0, blue: 54/255.0, alpha: 1)
    let tweetButtonEnabledBackgroundColor = UIColor(red: 29/255.0, green: 161/255.0, blue: 243/255.0, alpha: 1)
    let tweetButtonDisabledAccentColor = UIColor(red: 240/255.0, green: 242/255.0, blue: 245/255.0, alpha: 1)
    let placeholderTextColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1)

    // MARK: - IBOutlets
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screennameLabel: UILabel!
    @IBOutlet var inputText: UITextView!
    @IBOutlet var replyScreennameLabel: UILabel!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        defer {
            disableSending()
        }

        profileImageView.setImageWithURL((User.currentUser?.profileUrl)!)
        profileImageView.layer.cornerRadius = 5

        inputText.delegate = self

        nameLabel.text = User.currentUser?.name as? String
        screennameLabel.text = "@" + (User.currentUser?.screenname as! String)

        let navigationBar = self.navigationController!.navigationBar
        let charCountFrame = CGRect(x: 20, y: 0, width: navigationBar.frame.width/2, height: navigationBar.frame.height)
        charCountLabel = UILabel(frame: charCountFrame)
        charCountLabel.textColor = charCountLabelNormalTextColor
        charCountLabel.text = "140"
        charCountLabel.frame = charCountFrame
        navigationBar.addSubview(charCountLabel)

        let toolbarView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        inputText.inputAccessoryView = toolbarView

        let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width
        tweetButton = UIButton(frame: CGRect(x: screenWidth - 60 - 10, y: 10, width: 60, height: 30))
        tweetButton.backgroundColor = tweetButtonEnabledBackgroundColor
        tweetButton.layer.cornerRadius = 5
        tweetButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        tweetButton.setTitle("Tweet", forState: .Normal)
        tweetButton.addTarget(self, action: #selector(onTweetButton), forControlEvents: .TouchDown)
        toolbarView.addSubview(tweetButton)

        guard let replyToTweet = replyToTweet else {
            print("not a reply")
            replyScreennameLabel.text = ""
            return
        }

        replyScreennameLabel.hidden = false
        replyScreennameLabel.text = "@" + (replyToTweet.screenname! as String) + ":"
    }

    // MARK: - IBActions
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Internal Methods
    func onTweetButton() {
        var composedText = inputText.text
        if replyToTweet == nil { // making a brand new tweet
            AppInfo.switchToProfileTab(true)
        } else { // replying to someone else's tweet!
            AppInfo.openTweetDetails(replyToTweet!)
            composedText = "@" + ((replyToTweet!.screenname!) as String) + ": " + composedText
        }

        TwitterClient.sharedInstance.publishTweet(composedText, replyToTweetID: replyToTweet?.TweetID) { newTweet in
            AppInfo.openTweetDetails(newTweet)
        }

        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Private Methods
    private func disableSending(invalid: Bool = false) {
        if invalid {
            charCountLabel.textColor = charCountLabelDangerTextColor
        }
        tweetButton.backgroundColor = UIColor.whiteColor()
        tweetButton.enabled = false
        tweetButton.setTitleColor(tweetButtonDisabledAccentColor, forState: .Normal)
        tweetButton.layer.borderWidth = 1
        tweetButton.layer.borderColor = tweetButtonDisabledAccentColor.CGColor
    }

    private func enableSending() {
        charCountLabel.textColor = charCountLabelNormalTextColor
        tweetButton.backgroundColor = tweetButtonEnabledBackgroundColor
        tweetButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        tweetButton.enabled = true
        tweetButton.layer.borderWidth = 0
    }

}

// MARK: - UITextViewDelegate
extension ComposeViewController: UITextViewDelegate {

    func textViewDidBeginEditing(textView: UITextView) {
        defer {
            textView.becomeFirstResponder()
        }

        guard textView.text == "What's happening?" else {
            return
        }

        textView.text = ""
        textView.textColor = UIColor.blackColor()
    }

    func textViewDidEndEditing(textView: UITextView) {
        defer {
            textView.resignFirstResponder()
        }

        guard textView.text == "" else {
            return
        }

        textView.text = "What's happening?"
        textView.textColor = placeholderTextColor
    }

    func textViewDidChange(textView: UITextView) {
        let charCount = textView.text.characters.count
        charCountLabel.text = String(140 - charCount)

        switch charCount {
        case Int.min...0:
            disableSending()
            break
        case 1...140:
            enableSending()
            break
        case 141...Int.max as ClosedInterval:
            disableSending(true)
            break
        default:
            break
        }

    }

}
