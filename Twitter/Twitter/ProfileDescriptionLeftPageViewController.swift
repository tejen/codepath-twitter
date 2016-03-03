//
//  ProfileDescriptionLeftPageViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 3/3/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class ProfileDescriptionLeftPageViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screennameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!

    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var followersCountLabel: UILabel!

    @IBOutlet var imageLockIcon: UIImageView!
    @IBOutlet var imageCogIcon: UIImageView!
    @IBOutlet var imageProfileOptions: UIImageView!
    
    var user: User! {
        didSet {
            configureViewController();
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserverForName("ProfileConfigureSubviews", object: nil, queue: NSOperationQueue.mainQueue()) { (NSNotification) -> Void in
            if(User.bufferUser != nil) {
                self.user = User.bufferUser;
            }
        };
    }
    
    override func viewWillAppear(animated: Bool) {
        if(User.bufferUser != nil) {
            user = User.bufferUser;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureViewController() {
        NSNotificationCenter.defaultCenter().postNotificationName("ProfileConfigureRightSubviews", object: nil);
        
        let name = user.name;
        let screenname = user.screenname;
        let protected = user.protected;
        let location = user.locationString;
        let followingCount = user.followingCount;
        let followersCount = user.followersCount;
        if(protected == nil) {
            imageLockIcon.hidden = true;
        }

        nameLabel.text = String(name!);

        screennameLabel.text = "@" + String(screenname!);
        locationLabel.text = String(location!);

        followersCountLabel.text = shortenNumber(Double(followersCount!));
        followingCountLabel.text = shortenNumber(Double(followingCount!));

        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("profileCogMenu"));
        imageCogIcon.userInteractionEnabled = true;
        imageCogIcon.addGestureRecognizer(tapGestureRecognizer);
        
        if(user.screenname != User.currentUser?.screenname) {
            imageProfileOptions.hidden = true;
            imageCogIcon.hidden = true;
        } else {
            imageProfileOptions.hidden = false;
            imageCogIcon.hidden = false;
        }
    }
    
    func shortenNumber(var number: Double) -> String {
        if(number > 999999999) {
            number = number/1000000000;
            return String(format: "%.1f", number) + "B";
        }
        if(number > 999999) {
            number = number/1000000;
            return String(format: "%.1f", number) + "M";
        }
        if(number > 9999) {
            number = number/1000;
            return String(format: "%.1f", number) + "K";
        }
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        return numberFormatter.stringFromNumber(number)!;
    }
    
    func profileCogMenu() {
        if(user != User.currentUser){
            return;
        }
        
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet);
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let deleteActionButton: UIAlertAction = UIAlertAction(title: "Sign Out", style: .Destructive)
            { action -> Void in
                TwitterClient.sharedInstance.logout();
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        
        self.presentViewController(actionSheetControllerIOS8, animated: true, completion: nil)
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
