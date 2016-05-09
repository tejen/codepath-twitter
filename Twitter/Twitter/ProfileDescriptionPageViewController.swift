//
//  ProfileDescriptionPageViewController.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 3/2/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

final class ProfileDescriptionPageViewController: UIPageViewController {

    // MARK: - Properties

    // MARK: Private Properties
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
            self.newPageViewController("Left"),
            self.newPageViewController("Right")
        ]
    }()

    private func newPageViewController(side: String) -> UIViewController {
        return AppInfo.storyboard.instantiateViewControllerWithIdentifier("ProfilePage\(side)VC")
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        dataSource = self

        if let firstViewController = orderedViewControllers.first {
            setViewControllers( [firstViewController],
                direction: .Forward,
                animated: true,
                completion: nil
            )
        }

        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.lightGrayColor()
        appearance.currentPageIndicatorTintColor = UIColor.grayColor()
    }

}

// MARK: - UIPageViewControllerDataSource
extension ProfileDescriptionPageViewController: UIPageViewControllerDataSource {

    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            firstViewControllerIndex = orderedViewControllers.indexOf(firstViewController) else {
                return 0
        }

        return firstViewControllerIndex
    }

}
