//
//  HomeViewController.swift
//  Wallpapers
//
//  Created by Federico Vitale on 11/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import Hero
import Nuke

struct CollectionRow:SectionProtocol {
    var id: Int
    var section: Int
    var sectionTitle:String?
    
    init(at: IndexPath, withTitle title: String? = nil) {
        self.id = at.row
        self.section = at.section
        self.sectionTitle = title
    }
}

class HomeViewController: DarkTableViewController {    
    var featuredCollections: [Unsplash.Collection] = [Unsplash.Collection]()
    var specialCollections:  [Unsplash.Collection] = [Unsplash.Collection]()
    var collections:         [Unsplash.Collection] = [Unsplash.Collection]()
    
    var filteredCollections:         [Unsplash.Collection] = [Unsplash.Collection]()
    var filteredSpecialCollections:  [Unsplash.Collection] = [Unsplash.Collection]()
    var filteredFeaturedCollections: [Unsplash.Collection] = [Unsplash.Collection]()
    
    let list: [CollectionRow] = [
        // Featured
        CollectionRow(at: IndexPath(row: 799924,  section: 0)),
        CollectionRow(at: IndexPath(row: 1052683, section: 0)),
        CollectionRow(at: IndexPath(row: 869015,  section: 0)),
        CollectionRow(at: IndexPath(row: 500770,  section: 0)),
        CollectionRow(at: IndexPath(row: 1143269, section: 0)),
        
        // Special
        CollectionRow(at: IndexPath(row: 2411320, section: 1)),
        CollectionRow(at: IndexPath(row: 210767, section: 1)),
        CollectionRow(at: IndexPath(row: 574331,  section: 1)),
        CollectionRow(at: IndexPath(row: 311028,  section: 1)),
        CollectionRow(at: IndexPath(row: 1166960, section: 1)),
        
        // Others
        CollectionRow(at: IndexPath(row: 144067,  section: 2)),
        CollectionRow(at: IndexPath(row: 827743,  section: 2)),
        CollectionRow(at: IndexPath(row: 3330448, section: 2)),
        CollectionRow(at: IndexPath(row: 3356584, section: 2)),
        CollectionRow(at: IndexPath(row: 3330445, section: 2)),
        CollectionRow(at: IndexPath(row: 181581,  section: 2)),
        CollectionRow(at: IndexPath(row: 1198157, section: 2))
    ]
    
    
    // UI
    var offlineIcon: UIImageView = UIImageView()
    var indicator = UIActivityIndicatorView(style: .white)
    var searchController = UISearchController(searchResultsController: nil)
    
    // CoreData
    let persistenceManager: PersistenceManager

    init(persistenceManager: PersistenceManager, style: UITableView.Style = .grouped) {
        self.persistenceManager = persistenceManager
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
     * ------------------
     * MARK: - Lifecycle
     * ------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Preferences.firstRunGone = false
        
        if self.title == nil {
            self.title = "Wallpapers"
        }


        /*
         * -----------------------
         * MARK: SearchController
         * -----------------------
         */
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search a collection"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        /*
         * ----------------------
         * MARK: Settings Button
         * ----------------------
         */
        let settingsBtn = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.openSettings));
        settingsBtn.tintColor = navigationController?.navigationBar.tintColor
        navigationItem.rightBarButtonItem = settingsBtn
        
        
        setupIndicator()

        // If the user is offline: display an alert.
        NetworkManager.shared.isUnreachable { _ in
            DispatchQueue.main.async {
                self.showNoSignal()
                
                
                let ac = UIAlertController(title: "Connection Error", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(ac, animated: true)
            }
            
            return
        }
        
        // If internet connection is available: load collections.
        NetworkManager.shared.isReachable { _ in
            self.loadCollections()
        }
    }
    
    // Everytime the this is called, update the "Accent Color"
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)

        navigationController?.navigationBar.tintColor = Preferences.themeColor
        navigationItem.rightBarButtonItem?.tintColor  = Preferences.themeColor
        navigationItem.leftBarButtonItem?.tintColor   = Preferences.themeColor
        
        searchController.searchBar.tintColor          = Preferences.themeColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        /*
         On first run, setup defaults
         */
        if Preferences.firstRunGone == false {
            Preferences.restoreDefaults()
            
            print("ONBOARDING SHOULD LAUNCH")
            
            // Launch Onboarding...
            let onboardingController = OnBoardingViewController()
            
            onboardingController.data = [
                OnboardingData(title: "Item 1", descr: "lorem impsum dolor sit amet"),
                OnboardingData(title: "Item 2", descr: "lorem impsum dolor sit amet"),
                OnboardingData(title: "Item 3", descr: "lorem impsum dolor sit amet")
            ]
            
            onboardingController.hero.isEnabled = true
            onboardingController.hero.modalAnimationType = .selectBy(presenting: .pageIn(direction: .up), dismissing: .auto)
            
            present(onboardingController, animated: true)
            
            Preferences.firstRunGone = true
        }
    }
    
    /*
     * ---------------------------
     * MARK: - TableView Settings
     * ---------------------------
     */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 65.0
        return 250.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return getNumberOfSections(items: self.list)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.list.filter({ $0.section == section }).first?.sectionTitle
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int = 0
        
        if isFiltering() {
            switch section {
            case 0:
                count = self.filteredFeaturedCollections.count
                break
            case 1:
                count = self.filteredCollections.count
                break
            case 2:
                count = self.filteredSpecialCollections.count
                break
            default:
                count = (self.filteredCollections + self.filteredFeaturedCollections).count
                break
            }
        } else {
            switch section {
            case 0:
                count = self.featuredCollections.count
                break
            case 1:
                count = self.collections.count
                break
            case 2:
                count = self.specialCollections.count
                break
            default:
                count = (self.collections + self.featuredCollections).count
                break
            }
        }
        
        return count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var collection: Unsplash.Collection?
        let cell = PreviewCell(reuseIdentifier: self.cellID);
        
        switch indexPath.section {
        case 0:
            if isFiltering() {
                collection = self.filteredFeaturedCollections[indexPath.row]
            } else {
                collection = self.featuredCollections[indexPath.row]
            }
            break
        case 2:
            if isFiltering() {
                collection = self.filteredSpecialCollections[indexPath.row]
            } else {
                collection = self.specialCollections[indexPath.row]
            }
            break
        default:
            if isFiltering() {
                collection = self.filteredCollections[indexPath.row]
            } else {
                collection = self.collections[indexPath.row]
            }
            break
        }
        
        let tags: [String]? = collection!.tags?.map({ (tag: Unsplash.Collection.Tag) -> String in
            return "#\(tag.title)"
        })
        
        cell.searchTags = tags ?? [String]()
        cell.collection = collection

        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var collection: Unsplash.Collection?
        
        switch indexPath.section {
        case 0:
            if isFiltering() {
                collection = self.filteredFeaturedCollections[indexPath.row]
            } else {
                collection = self.featuredCollections[indexPath.row]
            }
            break
        case 2:
            if isFiltering() {
                collection = self.filteredSpecialCollections[indexPath.row]
            } else {
                collection = self.specialCollections[indexPath.row]
            }
            break
        default:
            if isFiltering() {
                collection = self.filteredCollections[indexPath.row]
            } else {
                collection = self.collections[indexPath.row]
            }
            break
        }

        guard collection != nil else {
            return
        }
        
        let destinationVC = CollectionViewController(collectionViewLayout: self.setupFlowLayout());
        
        // Capitalize collection title
        collection!.title = collection!.title.capitalized
        
        // Set the title
        destinationVC.title = collection!.title
        
        // Set the cover photo
        destinationVC.coverPhoto = (tableView.cellForRow(at: indexPath) as! PreviewCell).previewImage.image
        
        // Passing Data
        destinationVC.collection = collection!
        
        // Dark Theme
        destinationVC.setDark()
    
        // Push the new view
        navigationController?.pushViewController(destinationVC, animated: true)
        
        // Deselect current row
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

/*
 * -------------------
 * MARK: - Extensions
 * -------------------
 */
extension HomeViewController {
    @objc func loadCollections() {
        indicator.startAnimating()
        
        let queueGroup: DispatchGroup = DispatchGroup()
        
        list.forEach { (col: CollectionRow) in
            queueGroup.enter()
            
            apiClient.getCollection(id: "\(col.id)", completion: { (collection, _) in
                guard let collection = collection else { return }
                
                switch col.section {
                case 0:
                    self.featuredCollections.append(collection)
                    DispatchQueue.main.async {
                        self.featuredCollections.sort { (a, b) -> Bool in
                            return a.total_photos < b.total_photos
                        }
                        
                        queueGroup.leave()
                    }
                    break
                case 1:
                    self.collections.append(collection)
                    DispatchQueue.main.async {
                        self.collections.sort { (a, b) -> Bool in
                            return a.total_photos < b.total_photos
                        }
                        
                        queueGroup.leave()
                    }
                    break
                case 2:
                    self.specialCollections.append(collection)
                    DispatchQueue.main.async {
                        self.specialCollections.sort { (a, b) -> Bool in
                            return a.total_photos < b.total_photos
                        }
                        
                        queueGroup.leave()
                    }
                default:
                    queueGroup.leave()
                    break
                }
            })
        }
        
        queueGroup.notify(queue: .main) {
            self.indicator.stopAnimating()
            self.tableView.reloadData()

            print("Loaded")
        }
    }
    
    @objc func openSettings() {
        let destination = SettingsViewController(persistenceManager: self.persistenceManager, style: .grouped)
        navigationController?.pushViewController(destination, animated: true)
    }
    
    
    /*
     * -----------------
     * MARK: View Setup
     * -----------------
     */
    fileprivate func setupFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 35
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 35, left: 35, bottom: 35, right: 35)
        
        return flowLayout
    }
    
    fileprivate func showNoSignal() {
        let targetView: UIView = self.tableView
        
        offlineIcon.image = UIImage(named: "no-signal")
        offlineIcon.contentMode = .scaleAspectFit
        offlineIcon.center = targetView.center
        offlineIcon.alpha  = 0.5
        
        targetView.addSubview(offlineIcon)
        targetView.bringSubviewToFront(offlineIcon)

        offlineIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            offlineIcon.centerXAnchor.constraint(equalTo: targetView.centerXAnchor),
            offlineIcon.centerYAnchor.constraint(equalTo: targetView.centerYAnchor, constant: -150),
            offlineIcon.heightAnchor.constraint(equalToConstant: 60),
            offlineIcon.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    
    fileprivate func setupIndicator() {
        indicator.hidesWhenStopped = true
        
        view.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}



extension HomeViewController: UISearchResultsUpdating {
    enum SearchScope {
        case all
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterResultsForSearchText(searchController.searchBar.text!)
    }
    
    func searchIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterResultsForSearchText(_ searchText: String, scope: SearchScope = .all) {
        self.filteredCollections = self.collections.filter({ (collection: Unsplash.Collection) -> Bool in
            return collection.title.lowercased().contains(searchText.lowercased()) || collection.tags?.filter({ (tag: Unsplash.Collection.Tag) -> Bool in
                return tag.title.lowercased().contains(searchText.lowercased())
            }).count ?? 0 > 0
        })
        
        self.filteredFeaturedCollections = self.featuredCollections.filter({ (collection: Unsplash.Collection) -> Bool in
            return collection.title.lowercased().contains(searchText.lowercased()) || collection.tags?.filter({ (tag: Unsplash.Collection.Tag) -> Bool in
                return tag.title.lowercased().contains(searchText.lowercased())
            }).count ?? 0 > 0
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchIsEmpty()
    }
}

