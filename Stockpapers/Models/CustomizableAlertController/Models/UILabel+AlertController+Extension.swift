//
//  UILabel+Extension.swift
//  Stockpapers
//
//  Created by Federico Vitale on 24/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    var textAttributes: [StringAttribute] {
        get { return self.attributedText?.attributes ?? [] }
        set { self.attributedText = newValue.suitableAttributedText(forText: self.text) }
    }
}
