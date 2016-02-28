//
//  LoginViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/19/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    @IBOutlet var logoVerticalConstraint: NSLayoutConstraint!
    @IBOutlet var logoMovedToTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var logoHeightOriginalConstraint: NSLayoutConstraint!
    @IBOutlet var logoHeightSmallerConstraint: NSLayoutConstraint!
    
    @IBOutlet var WelcomeLabel: UILabel!
    @IBOutlet var SubtitleLabel: UILabel!
    @IBOutlet var ButtonContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ButtonContainerView.layer.cornerRadius = 5;
        
        ButtonContainerView.alpha = 0;
        WelcomeLabel.alpha = 0;
        SubtitleLabel.alpha = 0;
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent;

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLoginButton(sender: AnyObject) {
        TwitterClient.sharedInstance.login({ () -> () in
            print("Logged in");
            self.dismissViewControllerAnimated(true) { () -> Void in
            }
        }) { (error: NSError) -> () in
            print(error);
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        logoVerticalConstraint.active = false;
        logoMovedToTopConstraint.active = true;
        
        logoHeightOriginalConstraint.active = false;
        logoHeightSmallerConstraint.active = true;

        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded();
            
            self.ButtonContainerView.alpha = 1;
            self.WelcomeLabel.alpha = 1;
            self.SubtitleLabel.alpha = 1;
            
            self.ButtonContainerView.frame = CGRectOffset(self.ButtonContainerView.frame, 0, -20);
            self.WelcomeLabel.frame = CGRectOffset(self.WelcomeLabel.frame, 0, -20);
            self.SubtitleLabel.frame = CGRectOffset(self.SubtitleLabel.frame, 0, -20);
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
