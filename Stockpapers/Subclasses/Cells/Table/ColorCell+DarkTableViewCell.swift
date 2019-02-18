//
//  ColorCell.swift
//  Wallpapers
//
//  Created by Federico Vitale on 12/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class ColorCell: DarkTableViewCell {
    private var square: UIView = UIView()
    private var colorName: UILabel = UILabel()
    
    var color: UIColor? {
        didSet {
            guard let color = color else { return }
            
            setupSquare()
            setupLabel()
            setupStyle()
            
            setupSeparator()
            
            // overwrite setup functions
            square.backgroundColor = color
            colorName.text = color.name
            
            if (color == Colors.deepSpace && theme == .dark) || (color == Colors.cloud && theme == .light) {
                colorName.alpha = 0.25
                square.alpha = 0.25
                
                selectionStyle = .none
                isUserInteractionEnabled = false
            }
            
            if theme.accentColor == color {
                accessoryType = .checkmark
                colorName.font = UIFont.boldSystemFont(ofSize: 17)
            } else {
                accessoryType = .none
            }
        }
    }
    
    private func setupLabel() {
        let label = self.colorName;
        
        self.addSubview(label)
        
        label.text = square.backgroundColor?.name
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.textColor = theme.textColor

        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 35),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            label.leadingAnchor.constraint(equalTo: square.trailingAnchor, constant: 18),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func setupSquare() {
        self.addSubview(square)
        
        square.backgroundColor = color
        square.layer.cornerRadius = 5
        
        square.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            square.widthAnchor.constraint(equalToConstant: 20),
            square.heightAnchor.constraint(equalToConstant: 20),
            square.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 35),
            square.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
