//
//  DarkAlertController.swift
//  Stockpapers
//
//  Created by Federico Vitale on 24/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


final class DarkAlertController: CustomizableAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.visualEffectView?.effect = UIBlurEffect(style: .dark)
        self.tintColor = SystemColors.blue
        
        
        self.contentView?.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.1)
        
        let boldAttribute = StringAttribute(key: .font, value: UIFont.systemFont(ofSize: 18, weight: .bold))
        let whiteStringAttribute = StringAttribute(key: .foregroundColor, value: UIColor.white)
        
        self.titleAttributes = [whiteStringAttribute, boldAttribute]
        self.messageAttributes = [whiteStringAttribute]
        
        self.actions.forEach { (action) in
            if action.style == .destructive || action.style == .cancel {
                action.titleTextColor = Colors.alizarin
            }
        }
        
        self.addParallaxEffect()
    }
}

