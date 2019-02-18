//
//  Array+Extension.swift
//  Stockpapers
//
//  Created by Federico Vitale on 24/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


extension Array where Element == StringAttribute {
    func suitableAttributedText(forText text: String?) -> NSAttributedString {
        if self.compactMap({ $0.range }).isEmpty {
            return NSAttributedString(string: text, attributes: self)
        }
        return NSMutableAttributedString(string: text, mutableAttributes: self)
    }
}
