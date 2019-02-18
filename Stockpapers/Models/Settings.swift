//
//  Settings.swift
//  Wallpapers
//
//  Created by Federico Vitale on 19/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

/*
 * -----------------------
 * MARK: - Settings
 * ------------------------
 */

enum SettingDetailType {
    case string(String)
    case int(Int)
    case color(UIColor)
    case bool(Bool)
    case pictureQuality(PictureQuality)
    case geture(UIGestureRecognizer)
}

protocol SectionProtocol {
    var section: Int { get }
}

protocol SettingDetailProtocol: SectionProtocol {
    var title: String { get set }
    var section: Int { get }
    var value: SettingDetailType { get }
    
    var isEnabled: Bool { get set }
}

struct SettingDetailChoose: SettingDetailProtocol {
    var title: String
    var isEnabled: Bool
    
    let section: Int
    let value: SettingDetailType
    let option: Setting
    
    init(title: String, value: SettingDetailType, option: Setting, enabled: Bool = true, section: Int = 0) {
        self.title = title
        self.value = value
        self.section = section
        
        self.isEnabled = enabled
        self.option = option
    }
}


/*
 * -----------------------
 * MARK: - User Stuff
 * ------------------------
 */
struct User {
    enum UserType:Int {
        case premium = 2
        case supporter = 1
        case base = 0
    }
    
    let id: Int
    var type: Int

    init(type: UserType = .base) {
        self.type = type.rawValue
        self.id = Int.random(in: 0...9999999)
    }
}
