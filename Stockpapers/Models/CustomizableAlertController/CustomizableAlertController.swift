//
//  CustomizableAlertController.swift
//  CustomizableAlertController
//
//  Created by Daniel Illescas Romero on 07/01/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//
import UIKit

open class CustomizableAlertController: UIAlertController {
    open lazy var visualEffectView: UIVisualEffectView? = {
        return self.view.visualEffectView
    }()
    
    open lazy var lazyContentView: UIView? = {
        return self.contentView
    }()
    
    open lazy var tintColor: UIColor? = {
        return self.view.tintColor
    }()
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.tintColor = self.tintColor
    }
    
    func addParallaxEffect(x: Int = 20, y: Int = 20) {
        let horizontal = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -x
        horizontal.maximumRelativeValue = x
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -y
        vertical.maximumRelativeValue = y
        
        let motionEffectsGroup = UIMotionEffectGroup()
        motionEffectsGroup.motionEffects = [horizontal, vertical]
        
        self.view.addMotionEffect(motionEffectsGroup)
    }
    
    func setBackgroundColor(_ color: UIColor?) {
        self.contentView?.backgroundColor = color
    }
    
    func autoForegroundColor(dark: UIColor = .black, light: UIColor = .white) {
        self.tintColor = (self.contentView?.backgroundColor?.isLight() ?? true) ? light : dark
    }
    
    func setForegroundColor(_ color: UIColor?) {
        self.tintColor = color
    }
}
