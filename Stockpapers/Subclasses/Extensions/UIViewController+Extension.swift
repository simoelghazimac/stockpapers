//
//  UIViewControllerHelper.swift
//  Wallpapers
//
//  Created by Federico Vitale on 12/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import Hero

extension UIViewController {
    @objc func updateAllStyles() {
        var theme: Theme {
            return Preferences.theme
        }
        
        view.backgroundColor = theme.color
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = theme.accentColor
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.barStyle  = theme.navigationBarStyle
        navigationItem.rightBarButtonItem?.tintColor  = theme.accentColor
        navigationItem.leftBarButtonItem?.tintColor   = theme.accentColor
        navigationItem.largeTitleDisplayMode = .always
        
        if theme == .dark {
            navigationController?.navigationBar.barTintColor = theme.darkerColor
        } else {
            navigationController?.navigationBar.barTintColor = theme.color
        }
        
        tabBarController?.tabBar.tintColor = theme.accentColor
        tabBarController?.tabBar.barTintColor = theme.color
    }
    
    func showBigToast(title: String, message: String, style: UINotificationFeedbackGenerator.FeedbackType = .success, duration: DispatchTimeInterval = .milliseconds(1250)) {
        let alert = DarkAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        UINotificationFeedbackGenerator().notificationOccurred(style)
        
        delay(.milliseconds(1250), completion: {
            alert.dismiss(animated: true, completion: nil)
        })
    }
}
