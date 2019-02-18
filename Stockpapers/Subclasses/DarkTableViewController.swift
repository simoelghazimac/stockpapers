//
//  DarkTableViewController.swift
//  Wallpapers
//
//  Created by Federico Vitale on 13/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class DarkTableViewController: UITableViewController {
    var cellID: String = "CustomCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(DarkTableViewCell.self, forCellReuseIdentifier: cellID)
        self.setupStyle()
    }
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        self.setupStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupStyle()
    }
    
    private func setupStyle() {
        let theme:Theme = Preferences.theme
        
        self.view.backgroundColor      = theme.color
        self.tableView.backgroundColor = theme.color
        
        navigationController?.navigationBar.barStyle = theme.navigationBarStyle
        
        self.tableView.separatorStyle  = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = Preferences.themeColor
        navigationController?.navigationItem.rightBarButtonItem?.tintColor  = Preferences.themeColor
        navigationController?.navigationItem.leftBarButtonItem?.tintColor   = Preferences.themeColor
        
        self.tableView.separatorStyle  = .none
    }
}
