//
//  SettingsDetailChoose.swift
//  Wallpapers
//
//  Created by Federico Vitale on 12/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class SettingsDetailChoose: DarkTableViewController {
    private var allOptions: [SettingDetailChoose] = [
        // Accent Color Options
        SettingDetailChoose(title: "Sun Flower", value: .color(Colors.sunFlower), option: .accentColor),
        SettingDetailChoose(title: "Carrot", value: .color(Colors.carrot), option: .accentColor),
        SettingDetailChoose(title: "Alizarin", value: .color(Colors.alizarin), option: .accentColor),
        SettingDetailChoose(title: "Sasquatch Socks", value: .color(Colors.sasquatchSocks), option: .accentColor),
        SettingDetailChoose(title: "Amethyst", value: .color(Colors.amethyst), option: .accentColor),
        SettingDetailChoose(title: "Peter River", value: .color(Colors.peterRiver), option: .accentColor),
        SettingDetailChoose(title: "Squeaky", value: .color(Colors.squeaky), option: .accentColor),
        SettingDetailChoose(title: "Emerald", value: .color(Colors.emerald), option: .accentColor),

        
        // Image Size
        SettingDetailChoose(title: "Screen Size", value: .bool(true), option: .imageSize),
        SettingDetailChoose(title: "Original Size", value: .bool(false), option: .imageSize),
        
        // Close Gesture
        SettingDetailChoose(title: "Short", value: .int(CloseGesture.PanSize.short.rawValue), option: .closeGesture),
        SettingDetailChoose(title: "Medium", value: .int(CloseGesture.PanSize.medium.rawValue), option: .closeGesture),
        SettingDetailChoose(title: "Long", value: .int(CloseGesture.PanSize.long.rawValue), option: .closeGesture),
        
        // Image Quality
        SettingDetailChoose(title: "Maximum", value: .pictureQuality(.raw), option: .pictureQuality),
        SettingDetailChoose(title: "Full",    value: .pictureQuality(.full), option: .pictureQuality),
        SettingDetailChoose(title: "Regular", value: .pictureQuality(.regular), option: .pictureQuality),
        SettingDetailChoose(title: "Small",   value: .pictureQuality(.small), option: .pictureQuality),
        
        // Hide Gesture
        SettingDetailChoose(title: "Tap", value: .string("tap"), option: .hideGesture),
        SettingDetailChoose(title: "Long Press", value: .string("long-press"), option: .hideGesture),
        SettingDetailChoose(title: "None", value: .string("none"), option: .hideGesture),
    ]
    
    var visibleOptions: [SettingDetailChoose] {
        return allOptions.filter({ $0.option == setting.id! })
    }
    
    var setting: SettingItem! {
        didSet {
            title = setting.title
        }
    }

    
    /*
     * ------------------
     * MARK: - Lifecycle
     * ------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ColorCell.self, forCellReuseIdentifier: "\(ColorCell.self)")
        tableView.register(ImageCell.self, forCellReuseIdentifier: "\(ImageCell.self)")
        tableView.register(DarkTableViewCell.self, forCellReuseIdentifier: "\(DarkTableViewCell.self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    /*
     * ---------------------------
     * MARK: - TableView Delegate
     * ---------------------------
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return getNumberOfSections(items: visibleOptions)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Pick an option"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getOptions(for: section).count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.separatorStyle = .none

        let option = getOption(at: indexPath)
        
        if setting.id == .accentColor {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(ColorCell.self)", for: indexPath) as! ColorCell
            
            if case .color(let color) = option.value {
                cell.color = color
                
                print(color.toHexString(), color.name)
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(DarkTableViewCell.self)", for: indexPath) as! DarkTableViewCell
        
        cell.setupStyle()
        
        switch setting.id! {
        case .imageSize:
            if case .bool(let value) = option.value {
                if value == Preferences.cropImages {
                    cell.accessoryType = .checkmark
                }
            }
            break
        case .pictureQuality:
            if case .pictureQuality(let value) = option.value {
                if Preferences.pictureQuality == value {
                    cell.accessoryType = .checkmark
                }
            }
            break
        case .hideGesture:
            if case .string(let value) = option.value {
                if Preferences.hideGesture == value {
                    cell.accessoryType = .checkmark
                }
            }
            break
        case .closeGesture:
            if case .int(let value) = option.value {
                if Preferences.closeFullScreenVCGestureSize.rawValue == value {
                    cell.accessoryType = .checkmark
                }
            }
        default:
            break
        }
        
        if cell.accessoryType == .checkmark {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        }
        
        cell.textLabel?.text = option.title.capitalized
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UISelectionFeedbackGenerator().selectionChanged()
        
        let option = getOption(at: indexPath)
        
        switch setting.id! {
        case .accentColor:
            if case .color(let value) = option.value {
                Preferences.themeColor = value
            }
            break
        case .imageSize:
            if case .bool(let value) = option.value {
                Preferences.cropImages = value
            }
            break
        case .pictureQuality:
            if case .pictureQuality(let value) = option.value {
                Preferences.pictureQuality = value
            }
            break
        case .hideGesture:
            if case .string(let value) = option.value {
                Preferences.hideGesture = value
            }
            break
        case .closeGesture:
            if case .int(let value) = option.value {
                Preferences.closeFullScreenVCGestureSize = CloseGesture.PanSize(rawValue: value)!
            }
            break
        default:
            break
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    
    /*
     * -----------------------
     * MARK: - Custom Utility
     * -----------------------
     */
    private func updateStyle() {
        tableView.reloadData()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationController?.navigationBar.tintColor = Preferences.themeColor
        navigationItem.rightBarButtonItem?.tintColor  = Preferences.themeColor
        navigationItem.leftBarButtonItem?.tintColor   = Preferences.themeColor
    }
    
    
    
    func getOption(at indexPath: IndexPath) -> SettingDetailChoose {
        return visibleOptions.filter({ $0.section == indexPath.section })[indexPath.row]
    }
    
    func getOptions(for section: Int) -> [SettingDetailChoose] {
        return visibleOptions.filter({ $0.section == section })
    }
}

/*
 * -----------------------
 * MARK: - Navigation
 * ------------------------
 */
extension SettingsDetailChoose: UIGestureRecognizerDelegate {
    private func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController!.viewControllers.count > 1 {
            return true
        }
        
        return false
    }
}
