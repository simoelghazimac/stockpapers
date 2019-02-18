//
//  InfoDetailVC.swift
//  Stockpapers
//
//  Created by Federico Vitale on 09/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//
import Foundation
import UIKit


struct InfoDetailItem {
    let title:String
    let extra:String?
    let url:URL?
    let type: InfoItem.Style
    let icon: UIImage?
    
    init(title: String, type: InfoItem.Style, extra:String?=nil, url:URL?=nil, icon:UIImage?=nil) {
        self.title = title
        self.extra = extra
        self.url = url
        self.type = type
        self.icon = icon
    }
}

class InfoDetailVC: DarkTableViewController {
    var options: [InfoDetailItem]!
    var theme : Theme {
        return Preferences.theme
    }
    
    override func viewDidLoad() {
        tableView.register(ImageCell.self, forCellReuseIdentifier: "\(ImageCell.self)")
        tableView.register(DarkTableViewCell.self, forCellReuseIdentifier: "\(DarkTableViewCell.self)")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = options[indexPath.row]
        
        if let icon = option.icon {
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(ImageCell.self)", for: indexPath) as! ImageCell
            
            cell.titleLabel.text = option.title
            if option.type == .link {
                cell.titleLabel.textAttributes = [StringAttribute(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)]
            }
            
            cell.imageContainer.image = icon
            cell.imageContainer.backgroundColor = .clear
            cell.imageContainer.tintColor = theme == .light ? theme.darkerColor : Colors.cloud.withAlpha(0.5)
            
            cell.detailTextLabel?.text = option.extra
            cell.detailTextLabel?.textColor = theme.accentColor.withAlpha(0.35)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(DarkTableViewCell.self)", for: indexPath) as! DarkTableViewCell
        cell.textLabel?.text = option.title
        
        if option.type == .link {
            cell.textLabel?.textAttributes = [StringAttribute(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)]
        }
        
        cell.detailTextLabel?.text = option.extra
        cell.detailTextLabel?.textColor = Preferences.themeColor.withAlpha(0.35)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let option = options[indexPath.row]
        
        switch option.type {
        case .link:
            guard let url = option.url else { return }
            url.safeOpen(completion: nil) { (message) in
                let alert = DarkAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", image: nil))
                self.present(alert, animated: true)
            }
            break
        default:
            break;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}
