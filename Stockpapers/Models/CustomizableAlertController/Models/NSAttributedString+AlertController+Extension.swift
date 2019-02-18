//
//  NSAttributedString+Extension.swift
//  Stockpapers
//
//  Created by Federico Vitale on 24/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    struct StringAttribute {
        
        let key: NSAttributedString.Key
        let value: Any
        var range: NSRange? = nil
        
        init(key: NSAttributedString.Key, value: Any, range: NSRange? = nil) {
            self.key = key
            self.value = value
            self.range = range
        }
    }
    
    var attributes: [StringAttribute] {
        
        var savedAttributes: [StringAttribute] = []
        
        let rawAttributes = self.attributes(at: 0, longestEffectiveRange: nil, in: NSRange(location: 0, length: self.length))
        
        for rawAttribute in rawAttributes {
            savedAttributes.append(StringAttribute(key: rawAttribute.key, value: rawAttribute.value))
        }
        return savedAttributes
    }
    convenience init(string: String?, attributes: [StringAttribute]) {
        
        guard let validString = string else { self.init(string: "", attributes: [:]); return }
        
        var attributesDict: [NSAttributedString.Key: Any] = [:]
        for attribute in attributes {
            attributesDict[attribute.key] = attribute.value
        }
        self.init(string: validString, attributes: attributesDict)
    }
}
