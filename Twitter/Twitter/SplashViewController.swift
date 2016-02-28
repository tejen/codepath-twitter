//
//  SplashViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/22/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController, TwitterLoginLoungeDelegate {

    @IBOutlet var LogoHeightOriginalConstraint: NSLayoutConstraint!
    @IBOutlet var LogoHeightLargeConstraint: NSLayoutConstraint!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TwitterClient.sharedInstance.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        LogoHeightLargeConstraint.active = false;
        LogoHeightOriginalConstraint.active = true;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        if(!appDelegate.splashInterludePersist) {
            delay(1.0) { () -> () in
                self.continueLogin();
            }
        }
    }
    
    func goToLogin() {
        self.performSegueWithIdentifier("toLogin", sender: self);
    }
    
    func continueToApp() {
        LogoHeightOriginalConstraint.active = false;
        LogoHeightLargeConstraint.active = true;
        
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded();
        }
        self.performSegueWithIdentifier("toTabbedView", sender: self);
    }
    
    func continueLogin() {
        appDelegate.splashInterludePersist = false;
        if(User.currentUser == nil) {
            self.goToLogin();
        } else {
            self.continueToApp();
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
