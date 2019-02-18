//
//  InfoVC.swift
//  Stockpapers
//
//  Created by Federico Vitale on 09/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//
import Foundation
import UIKit
import Firebase

struct InfoItem: SectionProtocol {
    enum Style {
        case link
        case list
        case tap
        case none
        case value
    }
    
    var id: Int
    var section: Int
    var title:String
    var value: String?
    
    var type: Style
    var sectionTitle: String?
    var sectionFooter: String?
    
    init(id: Int, section: Int, title: String, value:String? = nil, type:Style = .none, sectionTitle:String?=nil, sectionFooter:String?=nil) {
        self.id = id
        self.section = section
        self.title = title
        self.type = type
        self.sectionTitle = sectionTitle
        self.sectionFooter = sectionFooter
        self.value = value
    }
}

class InfoVC: DarkTableViewController {
    var infos: [InfoItem] = [
        // List all libraries
        InfoItem(id: 0, section: 0, title: "📚 Libraries", type: .list, sectionTitle: "👾 Nerd Infos"),
        
        // display photos sources list with links (Unsplash for now)
        InfoItem(id: 1, section: 0, title: "🖼️ Photos Source", type: .list),
        
        // If tapped 9 times do something
        InfoItem(
            id: 2,
            section: 1,
            title: "App Version",
            value: "v\(Preferences.appVersion)",
            type: .value,
            sectionTitle: "App Infos"
        ),
        
        // Present a selection with socials and website
        InfoItem(
            id: 3,
            section: 1,
            title: "Who made this app?",
            type: .list
        ),
        ]
    
    override func viewDidLoad() {
        title = "Infos"
        
        
        tableView.register(DarkTableViewCell.self, forCellReuseIdentifier: "\(DarkTableViewCell.self)")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return getNumberOfSections(items: infos)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return infos.filter({ $0.section == 0 }).count
        }
        
        if section == 1 {
            return infos.filter({ $0.section == 1 }).count
        }
        
        return infos.filter({ $0.section != 0 }).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(DarkTableViewCell.self)", for: indexPath)
        let info = infos.filter({ $0.section == indexPath.section })[indexPath.row]
        
        switch info.type {
        case .list:
            cell.accessoryType = .disclosureIndicator
            break
        case .link:
            cell.textLabel?.textAttributes = [
                StringAttribute(key: .underlineStyle, value: NSUnderlineStyle.single)
            ]
            break
        case .tap:
            break
        case .value:
            cell.detailTextLabel?.text = info.value
        case .none:
            cell.selectionStyle = .none
            break;
        }
        
        cell.textLabel?.text = info.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var options:[InfoDetailItem]?
        let item = infos.filter({ $0.section == indexPath.section })[indexPath.row]
        
        // Deselect the selected row
        tableView.deselectRow(at: indexPath, animated: true)
        
        print("Section: \(indexPath.section) - Row: \(indexPath.row)")
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                Analytics.logEvent("info_vc", parameters: [
                    "action": "open",
                    "target": "libraries"
                    ])
                
                
                // Libraries
                options = [
                    InfoDetailItem(title: "UnsplashAPIClient", type: .link, extra: "github/rawnly", url: URL(string: "https://github.com/rawnly/UnsplashAPIClient"), icon: Icons.Social.github),
                    InfoDetailItem(title: "Hero", type: .link, extra: "github/HeroTransitions", url: URL(string: "https://github.com/HeroTransitions/Hero"), icon: Icons.Social.github),
                    InfoDetailItem(title: "Nuke", type: .link, extra: "github/kean", url: URL(string: "https://github.com/github/kean"), icon: Icons.Social.github),
                    InfoDetailItem(title: "Valet", type: .link, extra: "github/Square", url: URL(string: "https://github.com/github/Square"), icon: Icons.Social.github),
                    InfoDetailItem(title: "Reachability.swift", type: .link, extra: "github/ashleymills", url: URL(string: "https://github.com/github/ashleymills"), icon: Icons.Social.github),
                ]
                break;
            case 1:
                // Photo sources
                Analytics.logEvent("info_vc", parameters: [
                    "action": "open",
                    "target": "photo_sources"
                    ])
                
                options = [
                    InfoDetailItem(title: "Unsplash", type: .link, url: URL(string: "https://unsplash.com"), icon: Icons.Social.unsplash)
                ]
                break;
            default:
                break
            }
            break;
        case 1:
            switch indexPath.row {
            case 1:
                Analytics.logEvent("info_vc", parameters: [
                    "action": "open",
                    "target": "developer_info"
                    ])
                
                // Socials
                let twitterURL = URL(string: "twitter://user?screen_name=rawnlydev", fallback: "https://twitter.com/rawnlydev")
                let instagramURL = URL(string: "instagram://user?username=fedevitale.dev", fallback: "https://instagram.com/fedevitale.dev")
                let githubURL = URL(string: "grape://user?login=rawnly", fallback: "https://github.com/rawnly")
                let redditURL = URL(string: "apollo://reddit.com/u/rawnly", fallback: "https://reddit.com/u/rawnly")
                let mediumURL = URL(string: "https://medium.com/@fede.vitale")
                
                options = [
                    InfoDetailItem(title: "Instagram", type: .link, extra: "@fedevitale.dev", url: instagramURL, icon: Icons.Social.instagram),
                    InfoDetailItem(title: "Twitter", type: .link, extra: "@rawnlydev", url: twitterURL, icon: Icons.Social.twitter),
                    InfoDetailItem(title: "Medium", type: .link, extra: "@Rawnly", url: mediumURL, icon: Icons.Social.medium),
                    InfoDetailItem(title: "Github", type: .link, extra: "@Rawnly", url: githubURL, icon: Icons.Social.github),
                    InfoDetailItem(title: "Reddit", type: .link, extra: "@rawnly", url: redditURL, icon: Icons.Social.reddit),
                    InfoDetailItem(title: "Website", type: .link, url: URL(string: "https://rawnly.com"), icon: Icons.Social.link),
                ]
                break;
            default:
                break
            }
            break;
        default:
            break;
        }
        
        if item.type == .list && (options?.count ?? 0) > 0 {
            let vc = InfoDetailVC(style: .grouped)
            
            vc.title = item.id == 3 ? "Federico Vitale" : item.title
            vc.options = options!
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.infos.filter({$0.section == section && $0.sectionTitle != nil }).first?.sectionTitle ?? nil;
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.infos.filter({$0.section == section && $0.sectionFooter != nil }).first?.sectionFooter ?? nil;
    }
}
