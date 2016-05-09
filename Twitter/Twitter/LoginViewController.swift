//
//  LoginViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/19/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

final class LoginViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet var logoVerticalConstraint: NSLayoutConstraint!
    @IBOutlet var logoMovedToTopConstraint: NSLayoutConstraint!

    @IBOutlet var logoHeightOriginalConstraint: NSLayoutConstraint!
    @IBOutlet var logoHeightSmallerConstraint: NSLayoutConstraint!

    @IBOutlet var WelcomeLabel: UILabel!
    @IBOutlet var SubtitleLabel: UILabel!
    @IBOutlet var ButtonContainerView: UIView!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        ButtonContainerView.layer.cornerRadius = 5

        [ButtonContainerView, WelcomeLabel, SubtitleLabel].forEach { $0.alpha = 0 }

        UIApplication.sharedApplication().statusBarStyle = .LightContent

        NSNotificationCenter.defaultCenter().addObserverForName(AppInfo.notifications.ReturnToSplash, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        logoVerticalConstraint.active = false
        logoMovedToTopConstraint.active = true

        logoHeightOriginalConstraint.active = false
        logoHeightSmallerConstraint.active = true

        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()

            [self.ButtonContainerView, self.WelcomeLabel, self.SubtitleLabel].forEach {
                $0.alpha = 1
                $0.frame = CGRectOffset($0.frame, 0, -20)
            }
        }
    }

    // MARK: - IBActions
    @IBAction func onLoginButton(sender: AnyObject) {
        TwitterClient.sharedInstance.login({
            print("Logged in")
            self.dismissViewControllerAnimated(true, completion: nil)
        }, failure: { error in
            fatalError(error.localizedDescription)
        })
    }

}
