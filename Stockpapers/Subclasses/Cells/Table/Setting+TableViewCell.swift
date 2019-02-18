//
//  Settings.swift
//  Stockpapers
//
//  Created by Federico Vitale on 12/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

enum AccessoryType: Int {
    case selectable = 0,
    switchable,
    bool,
    button,
    view,
    none
}

enum Setting {
    case accentColor
    case imageSize
    case closeGesture
    case pictureQuality
    case hideGesture
    case history
    case favourites
    case about
    case removeWatermarks
    case restorePurchases
    case restoreSettings
    case unsplashLogin
    case experimentalFeatures

    
    case toggleHighQualityPreview
    case toggleDarkTheme
    case toggleStatusBarOnPreview
    case toggleParallax
}

struct SettingItem {
    let type: AccessoryType
    let title: String
    let section: SectionID
    let style: SettingTableViewCell.Style
    let viewColor: UIColor?
    let trigger : Selector?
    let id : Setting?
    
    init(
        _ title: String,
        _ type: AccessoryType = .selectable,
        _ section: SectionID = .generals,
        id: Setting? = nil,
        style: SettingTableViewCell.Style = .default,
        action trigger: Selector? = nil,
        viewColor: UIColor? = nil
    ) {
        self.title = title
        self.type = type
        self.section = section
        
        self.id = id
        self.style = style
        self.viewColor = viewColor
        self.trigger = trigger
    }
    
    init(
        _ title: String,
        _ section: SectionID = .generals,
        type: AccessoryType = .selectable,
        id: Setting? = nil,
        style: SettingTableViewCell.Style = .default,
        action trigger: Selector? = nil,
        viewColor: UIColor? = nil
        ) {
        self.title = title
        self.type = type
        self.section = section
        
        self.id = id
        self.style = style
        self.viewColor = viewColor
        self.trigger = trigger
    }
    
    
    
    enum SectionID: Int {
        case generals = 0,
        theming,
        imageSettings,
        data,
        purchases,
        restore,
        info
    }
}

class SettingTableViewCell: UITableViewCell {
    enum Style {
        case accent
        case danger
        case boldDanger
        case bold
        case `default`
    }
    
    var theme:Theme {
        return Preferences.theme
    }
    
    // Once you set this, you're ready to rock!
    var setting: SettingItem? {
        didSet {
            textLabel?.text = setting?.title
            setupStyle()
        }
    }
        
    var isEnabled: Bool = true {
        didSet {
            if isEnabled == false {
                textLabel?.alpha = 0.1
                selectionStyle = .none
            } else {
                textLabel?.alpha = 1
                
                if setting!.type != .switchable {
                    selectionStyle = .default
                }
            }
        }
    }
    
    var separator: UIView = {
        let s = UIView()
        s.backgroundColor = Preferences.theme .separatorColor
        s.tag = 1
        return s
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupStyle()
        
//        setupSeparator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStyle() {
        guard let setting = setting else { return }
        
        switch setting.type {
        case .selectable:
            accessoryType = .disclosureIndicator
            accessoryView = nil
            break
        case .switchable:
            selectionStyle = .none
            accessoryType = .none
            accessoryView = {
                let toggle = UISwitch()
                
                if let action = setting.trigger {
                    toggle.addTarget(self, action: action, for: .valueChanged)
                }
                
                toggle.onTintColor = theme.accentColor
                toggle.setOn(false, animated: false)
                
                return toggle
            }()
            break
        case .button:
            accessoryType = .none
            accessoryView = {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 25));

                button.setTitle("Tap Me", for: .normal)
                button.setTitleColor(theme.textColor, for: .normal)
                button.backgroundColor = theme.accentColor
                button.layer.cornerRadius = 2.5
                button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
                
                if let action = setting.trigger {
                    button.addTarget(self, action: action, for: .touchUpInside)
                }

                return button
            }()
            
            selectionStyle = .none
            break
        case .view:
            accessoryType = .none
            accessoryView = {
                let square = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                square.layer.cornerRadius = 5
                square.backgroundColor = setting.viewColor ?? theme.accentColor
                return square
            }()
            break
        default:
            accessoryView = nil
            accessoryType = .none
            break
        }

        backgroundColor = .clear
        selectedBackgroundView = {
            let selectedView = UIView()
            selectedView.backgroundColor = theme.darkerColor
            return selectedView
        }()
        
        textLabel?.textColor = {
            switch setting.style {
            case .accent:
                return theme.accentColor
            case .default:
                return isEnabled ? theme.textColor : theme.textColor.withAlpha(0.3)
            case .danger:
                return Colors.alizarin
            default:
                return theme.textColor
            }
        }()
        
        detailTextLabel?.textColor = theme.textColor.withAlpha(0.2)
        tintColor = theme.textColor.withAlpha(0.2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.isEnabled = true
        self.setting = nil
        
        detailTextLabel?.text = nil
        textLabel?.text = nil
    }
    
    internal func setupSeparator() {
        addSubview(separator)
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 2.5)
        ])
    }
}
