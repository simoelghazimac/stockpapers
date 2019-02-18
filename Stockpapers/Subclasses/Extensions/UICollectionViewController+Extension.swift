//
//  UICollectionViewController+Extension.swift
//  Stockpapers
//
//  Created by Federico Vitale on 12/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionViewController {
    override open func updateAllStyles() {
        super.updateAllStyles()
        
        collectionView.backgroundColor = Preferences.theme.color
    }
}
