//
//  Preferences.swift
//  Wallpapers
//
//  Created by Federico Vitale on 12/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct Preferences {
    private let notificationCenter = NotificationCenter.default;
    private enum Keys: String {
        case cropImages = "cropImages"
        case themeColor = "themeColor"
        case firstRunGone = "isFirstRun"
        case highQualityPreview = "highQualityPreview"
        case pictureQuality = "pictureQuality"
        case showStatusBarOnPreview = "showStatusBarOnPreview"
        case userType = "userType"
        case openCount = "openCount"
        case hideGesture = "hideGesture"
        case appVersion = "appVersion"
        case parallaxEffectOnImagePreview = "parallaxEffectOnImagePreview"
        case closeFullScreenVCGestureSize = "closeFullScreenVCGestureSize"
        case theme = "theme"
        case experimentalFeatures = "experimentalFeatures"
    }

    static var keychain = KeyChainService.shared
    
    static var experimentalFeaturesEnabled: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.experimentalFeatures.rawValue)
            sync()
            
            printIfSimulator("Experimental Features: \(newValue)")
        }
        
        get {
            return UserDefaults.standard.bool(forKey: Keys.experimentalFeatures.rawValue)
        }
    }
    
    static var firstRunGone: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.firstRunGone.rawValue)
            sync()
            
            printIfSimulator("First run gone: \(firstRunGone)")
        }
        
        get {
            return UserDefaults.standard.bool(forKey: Keys.firstRunGone.rawValue)
        }
    }
    
    static var appVersion: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.appVersion.rawValue)
            self.sync()
            
            printIfSimulator("App Version: v\(appVersion)")
        }
        
        get {
            guard let version = UserDefaults.standard.string(forKey: Keys.appVersion.rawValue) else {
                return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            }
            
            return version
        }
    }
    
    static var closeFullScreenVCGestureSize: CloseGesture.PanSize {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.closeFullScreenVCGestureSize.rawValue)
            self.sync()
            
            Analytics.logEvent("pref_closeFullScreenVCGestureSize__changed", parameters: [
                "value": newValue.rawValue as NSObject
            ])
        }
        
        get {
            var size:Int = UserDefaults.standard.integer(forKey: Keys.closeFullScreenVCGestureSize.rawValue)
            
            if size > 2 || size < 0 {
                size = 2
            }
            
            return CloseGesture.PanSize(rawValue: size) ?? .long
        }
    }

    static var showStatusBarOnPreview: Bool {
        set {
            printIfSimulator("Show StatusBar: \(newValue)")
            Analytics.logEvent("pref_show_visibility__changed", parameters: [
                "value": newValue as NSObject
            ])
            
            UserDefaults.standard.setValue(newValue, forKey: Keys.showStatusBarOnPreview.rawValue)
            self.sync()
        }

        get {
            return UserDefaults.standard.bool(forKey: Keys.showStatusBarOnPreview.rawValue)
        }
    }

    static var cropImages: Bool {
        set {
            printIfSimulator("Crop Images: \(newValue)")
            UserDefaults.standard.setValue(newValue, forKey: Keys.cropImages.rawValue)
            self.sync()
            
            Analytics.logEvent("pref_crop_images__changed", parameters: [
                "value": newValue as NSObject
            ])
        }
        
        get {
            return UserDefaults.standard.bool(forKey: Keys.cropImages.rawValue)
        }
    }
    
    static var highQualityPreview: Bool {
        set {
            printIfSimulator("HQ Preview: \(newValue)")
            UserDefaults.standard.setValue(newValue, forKey: Keys.highQualityPreview.rawValue)
            self.sync()
            
            Analytics.logEvent("pref_high_quality_preview__changed", parameters: [
                "value": newValue as NSObject
            ])
        }
        
        get {
            return UserDefaults.standard.bool(forKey: Keys.highQualityPreview.rawValue)
        }
    }
    
    static var pictureQuality: PictureQuality {
        set {
            printIfSimulator("Picture Quality: \(newValue.rawValue)")
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.pictureQuality.rawValue)
            self.sync()
            
            Analytics.logEvent("pref_picture_quality__changed", parameters: [
                "value": newValue.rawValue
            ])
        }
        
        get {
            guard let quality = UserDefaults.standard.value(forKey: Keys.pictureQuality.rawValue) as? String else {
                return .full
            }
            
            return PictureQuality(rawValue: quality) ?? .full
        }
    }
    
    static var openCount: Int {
        set {
            let defaults = UserDefaults.standard
            
            defaults.set(newValue, forKey: Keys.openCount.rawValue)
            self.sync()
        }
        
        get {
            guard let count = UserDefaults.standard.value(forKey: Keys.openCount.rawValue) as? Int else {
                return 1
            }
            
            return count
        }
    }
    
    
    static var hideGesture: String {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hideGesture.rawValue)
            self.sync()
            
            printIfSimulator("Hide gesture: \(newValue)")
            
            Analytics.logEvent("pref_hide_gesture__changed", parameters: [
                "value": newValue
            ])
        }
        
        get {
            guard let gesture = UserDefaults.standard.string(forKey: Keys.hideGesture.rawValue) else {
                return "long-press"
            }
            
            return gesture
        }
    }
    
    static var themeColor: UIColor {
        set {
            printIfSimulator("Theme Color: \(newValue.toHexString())")
            NotificationCenter.default.post(name: .accentColorChanged, object: newValue)
            
            UserDefaults.standard.set(newValue.toHexString(), forKey: Keys.themeColor.rawValue)
            self.sync()
            
            Analytics.logEvent("pref_theme_color__changed", parameters: [
                "value": newValue.toHexString()
            ])
        }
        
        get {
            guard let hexcode = UserDefaults.standard.value(forKey: Keys.themeColor.rawValue) as? String else {
                return Colors.carrot
            }
            
            return UIColor(hexString: hexcode)
        }
    }
    
    static var theme: Theme {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.theme.rawValue)
            self.sync()
            
            printIfSimulator("New theme: \(newValue.rawValue)")
            
            Analytics.logEvent("pref_theme__changed", parameters: ["theme": newValue.rawValue] as [String: NSObject])
        }
        
        get {
            guard let value = UserDefaults.standard.value(forKey: Keys.theme.rawValue) as? String else {
                return Theme(rawValue: "dark")!
            }
            
            return Theme(rawValue: value) ?? Theme(rawValue: "dark")!
        }
    }
    
    static var parallaxEffectOnImagePreview: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.parallaxEffectOnImagePreview.rawValue)
            self.sync()
            
            printIfSimulator("Parallax Effect: \(parallaxEffectOnImagePreview)")
            
            Analytics.logEvent("pref_parallax_on_preview__changed", parameters: [
                "value": newValue as NSObject
            ])
        }
        
        get {
            guard let isEnabled = UserDefaults.standard.value(forKey: Keys.parallaxEffectOnImagePreview.rawValue) as? Bool else {
                return true
            }
            
            return isEnabled;
        }
    }
    
    static func restoreDefaults(restoreFirstRun: Bool = false) {
        themeColor = Colors.carrot
        
        cropImages = true
        highQualityPreview = false
        showStatusBarOnPreview = false
        parallaxEffectOnImagePreview = true
        
        pictureQuality = .full
        
        Analytics.logEvent("pref_restored", parameters: nil)
        
        if restoreFirstRun {
            firstRunGone = false
        }
    }
    
    static func sync() -> Void {
        UserDefaults.standard.synchronize()
    }
}



func printIfSimulator(_ arg: Any) {
    if Platform.isSimulator {
        print(arg)
    }
}
