//
//  ViewController.swift
//  Stockpapers
//
//  Created by Federico Vitale on 08/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import UIKit
import TTTAttributedLabel


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = TTTAttributedLabel(frame: .zero)
        label.text = "Federico -> https://rawnly.com"
        label.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(label)
        label.centerInSuperView()
    }
    
}
