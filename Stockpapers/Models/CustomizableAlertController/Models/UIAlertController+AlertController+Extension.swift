//
//  UIAlertController+Extension.swift
//  Stockpapers
//
//  Created by Federico Vitale on 24/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


extension UIAlertController {
    private var visualEffectView: UIVisualEffectView? {
        return self.view.visualEffectView
    }
    
    var contentView: UIView? {
        return self.view.subviews.first?.subviews.first?.subviews.first
    }
    
    var titleAttributes: [StringAttribute] {
        get { return self.attributedTitle_?.attributes ?? [] }
        set { self.attributedTitle_ = newValue.suitableAttributedText(forText: self.title) }
    }
    
    var messageAttributes: [StringAttribute] {
        get { return self.attributedMessage_?.attributes ?? [] }
        set { self.attributedMessage_ = newValue.suitableAttributedText(forText: self.message) }
    }
    
    
    // Methods
    func addAction(title: String, style: UIAlertAction.Style = .default, image: UIImage? = nil, handler: ((UIAlertAction) -> Void)? = nil) {
        self.addAction(UIAlertAction(title: title, style: style, image: image, handler: handler))
    }
}


private extension UIAlertController {
    private var attributedTitle_: NSAttributedString? {
        get {
            return self.value(forKey: "attributedTitle") as? NSAttributedString
        } set {
            self.setValue(newValue, forKey: "attributedTitle")
        }
    }
    
    private var attributedMessage_: NSAttributedString? {
        get {
            return self.value(forKey: "attributedMessage") as? NSAttributedString
        } set {
            self.setValue(newValue, forKey: "attributedMessage")
        }
    }
}
