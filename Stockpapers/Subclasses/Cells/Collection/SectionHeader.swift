//
//  SectionHeader.swift
//  Stockpapers
//
//  Created by Federico Vitale on 18/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class SectionHeader: UICollectionReusableView {
    var headerLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        headerLabel.textColor = .lightGray
        headerLabel.font = .systemFont(ofSize: 15)
        headerLabel.textAlignment = .left
        
        addSubview(headerLabel)
        
        headerLabel.setConstraints([
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 35/2),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(35/2))
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        headerLabel.text = nil
    }
}
