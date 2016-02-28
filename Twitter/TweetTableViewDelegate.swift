//
//  HomeViewDelegate.swift
//  Twitter
//
//  Created by Tejen Hasmukh Patel on 2/27/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

protocol TweetTableViewDelegate: class, UITableViewDelegate {
    func reloadTableCellAtIndex(cell: TweetCell, indexPath: NSIndexPath);
}