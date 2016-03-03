//
//  ProfileDescriptionRightPageViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 3/3/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class ProfileDescriptionRightPageViewController: UIViewController {

    @IBOutlet var taglineLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserverForName("ProfileConfigureRightSubviews", object: nil, queue: NSOperationQueue.mainQueue()) { (NSNotification) -> Void in
            if(User.bufferUser != nil) {
                self.taglineLabel.text = User.bufferUser?.tagline as? String;
            }
        };
    }
    
    override func viewWillAppear(animated: Bool) {
        if(User.bufferUser != nil) {
            taglineLabel.text = User.bufferUser?.tagline as? String;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
