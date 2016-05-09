//
//  TabBarViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/21/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

final class TabBarViewController: UITabBarController {

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserverForName(AppInfo.notifications.UserDidLogout, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
        }

        AppInfo.tabBarController = self
    }

}
