//
//  UIDevice+Extension.swift
//  Stockpapers
//
//  Created by Federico Vitale on 11/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    // iphone X/Xs
    var isX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    
    // iphone 6+/7+/8+
    var isPlus:Bool {
        return UIScreen.main.nativeBounds.height == 2208
    }
    
    // iphone 6/7/8
    var isStandard:Bool {
        return UIScreen.main.nativeBounds.height == 1334
    }
    
    // iphone 5
    var isOld:Bool {
        return UIScreen.main.nativeBounds.height == 1136
    }
}

