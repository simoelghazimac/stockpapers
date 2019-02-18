//
//  UIButtonHelper.swift
//  Wallpapers
//
//  Created by Federico Vitale on 12/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    open override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.alpha = self.isHighlighted ? 0.8 : 1
            })
        }
    }
    
    open override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.alpha = self.isEnabled ? 1 : 0.5
            })
        }
    }
}
