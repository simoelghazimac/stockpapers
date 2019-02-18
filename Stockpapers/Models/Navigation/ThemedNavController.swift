//
//  ThemedNavController.swift
//  Stockpapers
//
//  Created by Federico Vitale on 28/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class ThemedNavController: UINavigationController {
    var theme: Theme {
        return Preferences.theme
    }
    
    override func viewDidLoad() {
        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Theme stuff
        navigationBar.barStyle = theme.navigationBarStyle
        navigationBar.tintColor = theme.accentColor
    }
}
