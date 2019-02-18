//
//  UIAlertAction+Extension.swift
//  Stockpapers
//
//  Created by Federico Vitale on 24/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


extension UIAlertAction {
    convenience init(title: String, style: UIAlertAction.Style = .default, image: UIImage?, handler: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: title, style: style, handler: handler)
        if let image = image {
            self.accessoryImage = image
        }
    }

    var label: UILabel? {
        return (self.value(forKey: "__representer") as? NSObject)?.value(forKey: "label") as? UILabel
    }
    
    var titleAttributes: [StringAttribute] {
        get { return self.label?.attributedText?.attributes ?? [] }
        set { self.label?.textAttributes = newValue }
    }
    
    var titleTextColor: UIColor? {
        get { return self.titleTextColor_ }
        set { self.titleTextColor_ = newValue }
    }
    
    var isUnderline: Bool {
        get { return self.titleAttributes.filter({ ($0.value as? NSUnderlineStyle) == NSUnderlineStyle.single }).count > 0 }
        
        set {
            self.titleAttributes = [StringAttribute(key: .underlineStyle, value: NSUnderlineStyle.single)]
        }
    }
    
    var accessoryImage: UIImage? {
        get { return self.image_ }
        set { self.image_ = newValue }
    }
    
    var contentElementViewController: ElementViewController? {
        get { return self.contentViewController_ as? ElementViewController }
        set {
            if accessoryImage != nil {
                print("The accessory image might overlap with the content of the contentViewController")
            }
            self.contentViewController_ = newValue
        }
    }
    
    var contentViewController: UIViewController? {
        get { return self.contentViewController_ }
        set {
            if accessoryImage != nil {
                print("The accessory image might overlap with the content of the contentViewController")
            }
            self.contentViewController_ = newValue
        }
    }
    
    var tableViewController: UITableViewController? {
        get { return self.contentViewController_ as? UITableViewController }
        set {
            if accessoryImage != nil {
                print("The accessory image might overlap with the content of the contentViewController")
            }
            self.contentViewController_ = newValue
        }
    }
    
    var accessoryView: UIView? {
        get { return contentElementViewController?.elementView }
        set {
            let elementViewController = ElementViewController()
            elementViewController.elementView = newValue
            self.contentViewController = elementViewController
        }
    }
}


private extension UIAlertAction {
    // idea from: https://medium.com/@maximbilan/ios-uialertcontroller-customization-5cfd88140db8
    private var image_: UIImage? {
        get {
            return self.value(forKey: "image") as? UIImage
        } set {
            let imageWithGoodDimensions = newValue?.scale(to: CGSize(width: 30, height: 30))
            self.setValue(imageWithGoodDimensions?.withRenderingMode(.alwaysOriginal), forKey: "image")
        }
    }
    
    private var contentViewController_: UIViewController? {
        get {
            return self.value(forKey: "contentViewController") as? UIViewController
        } set {
            self.setValue(newValue, forKey: "contentViewController")
        }
    }
    
    private var titleTextColor_: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        } set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}
