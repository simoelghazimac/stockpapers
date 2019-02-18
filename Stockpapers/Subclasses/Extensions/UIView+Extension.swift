//
//  UIViewHelper.swift
//  Wallpapers
//
//  Created by Federico Vitale on 19/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

/*
 * -----------------------
 * MARK: - Utility
 * ------------------------
 */
extension UIView {
    func hide() {
        self.alpha = 0
        self.isUserInteractionEnabled = false
    }
    
    func show() {
        self.alpha = 1
        self.isUserInteractionEnabled = true
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
        
        self.addMotionEffect(motionEffectsGroup)
    }
    
    
    func setConstraints(_ constraints: [NSLayoutConstraint]) {
        guard let _ = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints);
    }
    
    func centerInSuperView(_ x: CGFloat = 0, _ y: CGFloat = 0) {
        guard let superView = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setConstraints([
            self.centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: x),
            self.centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant: y)
        ])
    }
    
    func fillSuperView(top: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0) {
        guard let superView = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setConstraints([
            self.topAnchor.constraint(equalTo: superView.topAnchor, constant: top),
            self.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: right),
            self.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: left),
            self.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: bottom)
        ])
    }
}
