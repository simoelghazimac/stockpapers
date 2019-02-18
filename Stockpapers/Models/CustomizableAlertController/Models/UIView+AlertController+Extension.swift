//
//  UIView+Extension.swift
//  Stockpapers
//
//  Created by Federico Vitale on 24/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func mapEverySubview(predicate: (UIView) -> Void) {
        predicate(self)
        for subview in self.subviews {
            subview.mapEverySubview(predicate: predicate)
        }
    }
}

internal extension UIView {
    var visualEffectView: UIVisualEffectView? {
        
        if self is UIVisualEffectView {
            return self as? UIVisualEffectView
        }
        
        for subview in self.subviews {
            if let validView = subview.visualEffectView {
                return validView
            }
        }
        return nil
    }
}

