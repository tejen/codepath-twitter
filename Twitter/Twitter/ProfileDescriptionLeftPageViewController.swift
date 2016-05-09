//
//  ProfileDescriptionLeftPageViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 3/3/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

final class ProfileDescriptionLeftPageViewController: UIViewController {

    // MARK: - Properties

    // MARK: Private Properties
    private var user: User! {
        didSet {
            configureViewController()
        }
    }

    // MARK: - IBOutlets
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screennameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!

    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var followersCountLabel: UILabel!

    @IBOutlet var imageLockIcon: UIImageView!
    @IBOutlet var imageCogIcon: UIImageView!
    @IBOutlet var imageProfileOptions: UIImageView!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        NSNotificationCenter.defaultCenter().addObserverForName(AppInfo.notifications.ProfileConfigureSubviews, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            self.grabLoadedUser()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        grabLoadedUser()
    }

    private func configureViewController() {
        NSNotificationCenter.defaultCenter().postNotificationName(AppInfo.notifications.ProfileConfigureRightSubviews, object: nil)

        let name = user.name
        let screenname = user.screenname
        let protected = user.protected
        let location = user.locationString
        let followingCount = user.followingCount
        let followersCount = user.followersCount

        imageLockIcon.hidden = protected == nil

        nameLabel.text = String(name!)

        screennameLabel.text = "@" + String(screenname!)
        locationLabel.text = String(location!)

        followersCountLabel.text = Double(followersCount!).abbreviation
        followingCountLabel.text = Double(followingCount!).abbreviation

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileCogMenu))
        imageCogIcon.userInteractionEnabled = true
        imageCogIcon.addGestureRecognizer(tapGestureRecognizer)

        [imageProfileOptions, imageCogIcon].forEach { $0.hidden = (user.screenname != User.currentUser?.screenname) }
    }

    // MARK: - Private Methods
    private func grabLoadedUser() {
        if User.bufferUser != nil {
            user = User.bufferUser
        }
    }

    // MARK: - Internal Methods
    func profileCogMenu() {
        guard user == User.currentUser else {
            return
        }

        let sheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .ActionSheet
        )

        sheet.addAction(
            UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        )

        sheet.addAction(
            UIAlertAction(title: "Sign Out", style: .Destructive) { _ in
                TwitterClient.sharedInstance.logout()
            }
        )

        presentViewController(sheet, animated: true, completion: nil)
    }

}
