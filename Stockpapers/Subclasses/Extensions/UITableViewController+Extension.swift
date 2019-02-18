//
//  UITableViewControllerHelper.swift
//  Wallpapers
//
//  Created by Federico Vitale on 19/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


/*
 * -----------------------
 * MARK: - TableViewController
 * ------------------------
 */
extension UITableViewController {
    override open func updateAllStyles() {
        super.updateAllStyles()

        tableView.backgroundColor = Preferences.theme.color
        
        tableView.reloadSections(IndexSet(0..<tableView.numberOfSections), with: .fade)
        tableView.reloadSectionIndexTitles()
        tableView.reloadInputViews()
    }
}

