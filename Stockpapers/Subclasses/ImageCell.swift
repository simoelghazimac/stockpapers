//
//  ImageCell.swift
//  Wallpapers
//
//  Created by Federico Vitale on 12/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class ImageCell: UITableViewCell {
    var img: UIImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let _ = self.darkTheme()
        
        img.layer.masksToBounds = true
        img.clipsToBounds = true
        
        img.contentMode = .scaleAspectFill
        
        self.addSubview(img)
        
        img.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            img.topAnchor.constraint(equalTo: self.topAnchor),
            img.rightAnchor.constraint(equalTo: self.rightAnchor),
            img.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            img.leftAnchor.constraint(equalTo: self.leftAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
