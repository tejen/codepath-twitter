//
//  AppInfo.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 5/8/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

/*

 In practice, Apple internal engineers employ AppInfo.swift, similar to this file, in most Apple enterprise apps, to globalize data and extensions.

 Such AppInfo.swift files typically contain a large singleton class for app data; such is unnecessary in this lightweight application, so a struct is being used instead.

 */

import UIKit
import Foundation

struct AppInfo {
    static var tabBarController: UITabBarController?

    // MARK: - Constants
    static let storyboard = UIStoryboard(name: "Main", bundle:nil)
    struct notifications {
        //TODO: implement alternatives to NSNotificationCenter
        static let ReturnToSplash = "ReturnToSplash"
        static let DetailsTweetChainReady = "DetailsTweetChainReady"
        static let ProfileConfigureSubviews = "ProfileConfigureSubviews"
        static let ProfileConfigureRightSubviews = "ProfileConfigureRightSubviews"
        static let ProfileConfigureView = "ProfileConfigureView"
        static let UserDidLogout = "UserDidLogout"
    }

    // MARK: - Public Helper Functions
    static func switchToProfileTab(reloadUserProfile: Bool = false) {
        if reloadUserProfile {
            delay(1.0) {
                let pnVc = tabBarController?.childViewControllers.last as! UINavigationController
                let pVc = pnVc.viewControllers.first as! ProfileViewController
                pVc.reloadData()
            }
        }

        tabBarController?.selectedIndex = 3
    }

    static func openTweetDetails(tweet: Tweet) {
        let vc = storyboard.instantiateViewControllerWithIdentifier("DetailsViewController") as! DetailsViewController
        vc.tweet = tweet

        UIApplication.sharedApplication().delegate?.window??.rootViewController!.presentedViewController!.presentViewController(vc, animated: true, completion: nil)
    }
}

public struct humanReadableDate {
    private var base: NSDate

    init(date: NSDate) {
        base = date
    }

    public var date: (unit: String, timeSince: Double) {
        var unit = "/"
        let formatter = NSDateFormatter()
        formatter.dateFormat = "M"
        let timeSince = Double(formatter.stringFromDate(base))!
        formatter.dateFormat = "d/yy"
        unit += formatter.stringFromDate(base)
        return (unit, timeSince)
    }

    public var datetime: String {
        let (unit, timeSince) = date
        let value = Int(timeSince)
        var l18n = "\(value)\(unit), "
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a"
        l18n += formatter.stringFromDate(base)
        return l18n
    }
}

// MARK: - NSDate
public extension NSDate {

    public var humanReadable: humanReadableDate {
        return humanReadableDate(date: self)
    }

    public var ago: String {
        var unit = "s"
        var timeSince = abs(self.timeIntervalSinceNow as Double); // in seconds
        let reductionComplete = reduced(unit, value: timeSince)

        while(reductionComplete != true) {
            unit = "m"
            timeSince = round(timeSince / 60)
            if reduced(unit, value: timeSince) { break; }

            unit = "h"
            timeSince = round(timeSince / 60)
            if reduced(unit, value: timeSince) { break; }

            unit = "d"
            timeSince = round(timeSince / 24)
            if reduced(unit, value: timeSince) { break; }

            unit = "w"
            timeSince = round(timeSince / 7)
            if reduced(unit, value: timeSince) { break; }

            (unit, timeSince) = self.humanReadable.date;   break
        }

        let value = Int(timeSince)
        return "\(value)\(unit)"
    }

    private func reduced(unit: String, value: Double) -> Bool {
        let value = Int(round(value))
        switch unit {
        case "s":
            return value < 60
        case "m":
            return value < 60
        case "h":
            return value < 24
        case "d":
            return value < 7
        case "w":
            return value < 4
        default: // include "w". cannot reduce weeks
            return true
        }
    }

}

// MARK: - String
public extension String {

    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: .LiteralSearch, range: nil)
    }

}

// MARK: - Double
public extension Double {

    var abbreviation: String { // eg. 2.3B, 1.1M, 1.7K, 823, etc...
        var number = self
        if(number > 999999999) {
            number = number/1000000000
            return String(format: "%.1f", number) + "B"
        }
        if(number > 999999) {
            number = number/1000000
            return String(format: "%.1f", number) + "M"
        }
        if(number > 9999) {
            number = number/1000
            return String(format: "%.1f", number) + "K"
        }

        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        return numberFormatter.stringFromNumber(number)!
    }

}

// MARK: - delay
func delay(delay: Double, closure: ()->()) {
    //TODO: encapsulate orphaned function.
    //TODO: use NSTimer framework.
    //TODO: consider asynchronous implementation.
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(),
        closure
    )
}
