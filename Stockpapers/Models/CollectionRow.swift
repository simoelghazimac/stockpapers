//
//  CollectionRow.swift
//  Wallpapers
//
//  Created by Federico Vitale on 19/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


struct CollectionRow: SectionProtocol {
    var id: Int
    var section: Int
    var sectionTitle:String?
    var coverPhoto: String?
    var customDescription: String?
    var customTitle: String?
    
    var isActive: Bool {
        return true
    }
    
    var userType: User.UserType
    
    init(id: Int, userType: User.UserType = .base, coverPhoto:String?=nil, customTitle:String?=nil, customDescription:String?=nil) {
        self.id = id
        self.section = 0
        
        self.userType = userType
        self.customDescription = customDescription
        self.coverPhoto = coverPhoto
        self.customTitle = customTitle
    }
    
    struct Color {
        var color: UIColor?
        
        var id: Int
        
        var sectionTitle:String?
        var coverPhoto: String?
        var customDescription: String?
        var customTitle: String?
        
        var isActive: Bool {
            get {
                return (self.color == Preferences.themeColor || self.color?.toHexString().lowercased() == Preferences.themeColor.toHexString().lowercased() || self.color!.name == Preferences.themeColor.name)
            }
        }
        
        init(id: Int, color: UIColor, coverPhoto:String?=nil, descr: String? = nil) {
            self.id = id
            self.customDescription = descr ?? color.getColorDescription()
            self.customTitle = color.name
            self.coverPhoto = coverPhoto
            self.color = color
        }
        
    }
}

