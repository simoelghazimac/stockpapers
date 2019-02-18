//
//  HistoryVC.swift
//  Wallpapers
//
//  Created by Federico Vitale on 16/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import Hero
import Nuke

/*
 UX TIP:
    Consider to use a "UICollectionViewController" instead of a "UITableViewController"
 */
class HistoryVC: DarkTableViewController {
    var items: [HistoryItem] = [HistoryItem]()

    var todayItems: [HistoryItem] {
        return items.filter({ Calendar.current.isDateInToday($0.download_date as Date) }).reversed()
    }
    
    var yesterdayItems: [HistoryItem] {
        return items.filter({ Calendar.current.isDateInYesterday($0.download_date as Date) }).reversed()
    }
    var pastItems: [HistoryItem] {
        return items.filter({
            !Calendar.current.isDateInToday($0.download_date as Date) &&
                !Calendar.current.isDateInYesterday($0.download_date as Date)
        }).reversed()
    }
    
    var theme: Theme {
        return Preferences.theme
    }
    
    
    /*
     * ------------------
     * MARK: - Lifecycle
     * ------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.title == nil {
            self.title = "Downloads History"
        }
        
        tableView.register(ImageCell.self, forCellReuseIdentifier: "\(ImageCell.self)")
        
        print("yesterday:", yesterdayItems)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStyle()
        self.hero.isEnabled = true
    }
    
    
    /*
     * ---------------------------
     * MARK: - TableView Delegate
     * ---------------------------
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        
        let a = todayItems.count > 0
        let b = yesterdayItems.count > 0
        let c = pastItems.count > 0
        
        if a || b || c {
            count = 1
        } else if a && b || a && c || b && c {
            count = 2
        } else if a && b && c {
            count = 3
        } else {
            count = 0
        }
        
        return count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Today"
        } else if section == 1 {
            return "Yesterday"
        } else if section == 2 {
            return "All Time"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return todayItems.count
        } else if section == 1 {
            return yesterdayItems.count
        }
        
        return pastItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var item: HistoryItem?
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(ImageCell.self)", for: indexPath) as! ImageCell
        
        switch indexPath.section {
        case 0:
            if todayItems.count > 0 {
                item = todayItems[indexPath.row]
                cell.titleLabel.text = (item!.download_date as Date).getTime(style: .short)
            }
            break
        case 1:
            if yesterdayItems.count > 0 {
                item = yesterdayItems[indexPath.row]
                cell.titleLabel.text = (item!.download_date as Date).getTime(style: .short)
            }
            break
        default:
            if pastItems.count > 0 {
                item = pastItems[indexPath.row]
                cell.titleLabel.text = (item!.download_date as Date).getDateAndTime(dateStyle: .short, timeStyle: .short)
            }
            break
        }
        
        guard item != nil else {
            let cell = DarkTableViewCell()
            
            cell.backgroundColor = .clear
            cell.textLabel?.text = "No items"
            cell.textLabel?.alpha = 0.1
            cell.textLabel?.textColor = Colors.brainGrayLight
            
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            
            return cell
        }
        
        cell.item = item
        cell.detailTextLabel?.alpha = 0.2
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var item:HistoryItem
        
        switch indexPath.section {
        case 0:
            item = todayItems[indexPath.row]
            break
        case 1:
            item = yesterdayItems[indexPath.row]
            break
        default:
            item = pastItems[indexPath.row]
            break
        }
        
        apiClient.getPhoto(id: item.id) { (photo, _) in
            DispatchQueue.main.async {
                let destinationVC = FullScreenPictureVC(persistenceManager: PersistenceManager.shared)
                
                destinationVC.hero.isEnabled = true
                destinationVC.hero.modalAnimationType = .fade
                destinationVC.container.hero.id = photo!.id
                destinationVC.photo = photo
                
                destinationVC.modalPresentationStyle = .overCurrentContext

                self.present(destinationVC, animated: true)
            }
        }
    }
    
    
    /*
     * -----------------------
     * MARK: - Custom Utility
     * -----------------------
     */
    private func updateStyle() {
        tableView.reloadData()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationController?.navigationBar.tintColor = theme.accentColor
        navigationItem.rightBarButtonItem?.tintColor  = theme.accentColor
        navigationItem.leftBarButtonItem?.tintColor   = theme.accentColor
    }
}


/*
 * -----------------------
 * MARK: - Navigation
 * ------------------------
 */
extension HistoryVC: UIGestureRecognizerDelegate {
    private func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController!.viewControllers.count > 1 {
            return true
        }
        
        return false
    }
}
