//
//  ElementViewController.swift
//  Stockpapers
//
//  Created by Federico Vitale on 24/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


class ElementViewController: UIViewController {
    var elementView: UIView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let validView = self.elementView  {
            
            self.view.addSubview(validView)
            
            validView.translatesAutoresizingMaskIntoConstraints = false
            
            let margins = self.view.layoutMarginsGuide
            
            validView.centerYAnchor.constraint(equalTo: margins.topAnchor, constant: validView.frame.height).isActive = true
            validView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
            validView.widthAnchor.constraint(equalTo: margins.widthAnchor).isActive = true
            validView.heightAnchor.constraint(equalTo: margins.heightAnchor).isActive = true
        }
    }
}
