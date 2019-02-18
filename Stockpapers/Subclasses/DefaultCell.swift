//
//  SwitchCell.swift
//  Wallpapers
//
//  Created by Federico Vitale on 12/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {

    var switchComponent:UISwitch = UISwitch()
    var label:UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hexString: "#0e0e12")
        
        self.selectedBackgroundView = backgroundView        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

