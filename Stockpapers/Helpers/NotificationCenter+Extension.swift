//
//  NotificationCenter.swift
//  Stockpapers
//
//  Created by Federico Vitale on 22/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation



extension Notification.Name {
    // IAP
    static let purchaseCompleted = Notification.Name("purchaseCompleted")
    static let purchaseFailed    = Notification.Name("purchaseFailed")
    static let purchaseRestored  = Notification.Name("purchaseRestored")
    
    // THEMING
    static let accentColorChanged = Notification.Name("accentColorChanged")
    static let themeChanged = Notification.Name("themeChanged")
}

