//
//  Theming.swift
//  Wallpapers
//
//  Created by Federico Vitale on 19/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

/*
 * -----------------------
 * MARK: - Theming
 * ------------------------
 */
struct Colors {
    static let alizarin: UIColor = UIColor(hexString: "#e74c3c")
    static let sunFlower: UIColor = UIColor(hexString: "#f1c40f")
    static let carrot: UIColor = UIColor(hexString: "#e67e22")
    static let peterRiver: UIColor = UIColor(hexString: "#3498db")
    static let emerald: UIColor = UIColor(hexString: "#2ecc71")
    static let amethyst: UIColor = UIColor(hexString: "#9b59b6")
    static let sasquatchSocks: UIColor = UIColor(hexString: "#FC427B")
    static let cloud: UIColor = UIColor(hexString: "#ffffff")
    static let squeaky: UIColor = UIColor(hexString: "#63cdda")
    static let deepSpace: UIColor = UIColor(hexString: "#1d1d1d")
    
    static let brainGray: UIColor = UIColor(hexString: "#0d0d0d")
    static let brainGrayDark: UIColor = UIColor(hexString: "#000000")
    static let brainGrayLight: UIColor = UIColor(hexString: "#0f0f0f")
    
    static func getColorName(_ color: UIColor) -> String {
        switch color {
        case Colors.alizarin:
            return "Alizarin"
        case Colors.sunFlower:
            return "Sun Flower"
        case Colors.carrot:
            return "Carrot"
        case Colors.peterRiver:
            return "Peter River"
        case Colors.emerald:
            return "Emerald"
        case Colors.amethyst:
            return "Amethyst"
        case Colors.squeaky:
            return "Squeaky"
        case Colors.sasquatchSocks:
            return "Sasquatch Socks"
        case Colors.cloud:
            return "Cloud"
        case Colors.deepSpace:
            return "Deep Space"
        default:
            print("Color not exists in plaette library", color.toHexString())
            return color.toHexString()
        }
    }
}

struct SystemColors {
    static let red: UIColor = UIColor(red:1.00, green:0.23, blue:0.19, alpha:1.00)
    static let orange: UIColor = UIColor(red:1.00, green:0.58, blue:0.01, alpha:1.00)
    static let yellow: UIColor = UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.00)
    static let green: UIColor = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.00)
    static let tealBlue: UIColor = UIColor(red:0.35, green:0.79, blue:0.98, alpha:1.00)
    static let blue: UIColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.00)
    static let purple: UIColor = UIColor(red:0.34, green:0.34, blue:0.84, alpha:1.00)
    static let pink: UIColor = UIColor(red:1.00, green:0.18, blue:0.33, alpha:1.00)
    
    static func getColorName(_ color: UIColor) -> String {
        switch color {
        case SystemColors.red:
            return "System Red"
        case SystemColors.orange:
            return "System Orange"
        case SystemColors.yellow:
            return "System Yellow"
        case SystemColors.green:
            return "System Green"
        case SystemColors.tealBlue:
            return "System Teal Blue"
        case SystemColors.blue:
            return "System Blue"
        case SystemColors.purple:
            return "System Purple"
        case SystemColors.pink:
            return "System Pink"
        default:
            print("Color not exists in plaette library", color.toHexString())
            return color.toHexString()
        }
    }
}

enum Theme: String {
    case dark = "dark"
    case light = "light"
    
    var textColor:UIColor {
        if self == .dark {
            return .white
        }
        
        return .black
    }
    
    var color: UIColor {
        if self == .dark {
            return Colors.brainGray
        }
        
        return Colors.cloud
    }
    
    var darkerColor: UIColor {
        if self == .dark {
            return Colors.brainGrayDark
        }
        
        return UIColor(hexString: "#dddddd")
    }
    
    var navigationBarStyle: UIBarStyle {
        if self == .dark {
            return .blackTranslucent
        }
        
        return .default
    }
    
    var accentColor: UIColor {
        return Preferences.themeColor
    }
    
    var separatorColor: UIColor {
        if self == .dark {
            return Colors.brainGrayLight.withAlpha(0.3)
        }
        
        return self.darkerColor.withAlpha(0.2)
    }
}
