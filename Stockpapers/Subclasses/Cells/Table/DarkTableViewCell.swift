//
//  DarkTableViewCell.swift
//  Wallpapers
//
//  Created by Federico Vitale on 13/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class DarkTableViewCell: UITableViewCell {
    var theme: Theme {
        return Preferences.theme
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        self.setupStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc internal func setupStyle() {
        backgroundColor = theme.color
        textLabel?.textColor = theme.textColor
        detailTextLabel?.textColor = theme.textColor.withAlphaComponent(0.8)
        tintColor = UIColor.white.withAlphaComponent(0.8)
        
        
        selectedBackgroundView = {
            let selectedBackgroundView = UIView()
            
            selectedBackgroundView.backgroundColor = theme.darkerColor
            
            return selectedBackgroundView
        }()
        
        setupSeparator()
    }
    
    internal func setupSeparator() {
        let separator = UIView()
        separator.backgroundColor = theme.separatorColor
        
        addSubview(separator)
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 2.5)
        ])
    }
}
