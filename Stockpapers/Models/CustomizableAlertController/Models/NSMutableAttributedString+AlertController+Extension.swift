//
//  NSMutableAttributedString+Extension.swift
//  Stockpapers
//
//  Created by Federico Vitale on 24/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


extension NSMutableAttributedString {
    var mutableAttributes: [StringAttribute] {
        get { return self.attributes }
        set {
            let defaultRange = NSRange(location: 0, length: self.length)
            for attribute in newValue {
                self.addAttribute(attribute.key, value: attribute.value, range: attribute.range ?? defaultRange)
            }
        }
    }
    convenience init(string: String?, mutableAttributes: [StringAttribute]) {
        guard let text = string else { self.init(string: ""); return }
        self.init(string: text)
        self.mutableAttributes = mutableAttributes
    }
}

