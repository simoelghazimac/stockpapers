//
//  HomeCollectionViewController.swift
//  Wallpapers
//
//  Created by Federico Vitale on 19/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import Nuke
import Firebase

class HomeVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let theme = Preferences.theme
    
    var alertHelper: AlertHelper!
    var persistenceManager: PersistenceManager
    
    var needsToBeUpdated: Bool = false
    var collections: [Unsplash.Collection] = [Unsplash.Collection]()
    var themeCollections: [Unsplash.Collection] = [Unsplash.Collection]()
    var handPickedCollections: [Unsplash.Collection] = [Unsplash.Collection]()
    
    var notification: UIButton = UIButton()
    var notificationTopConstraint: NSLayoutConstraint!
    
    var goToPage: ShortcutDestination? = nil
    
    func setupNotification() {
        notification.setTitle("Photo by @fede.vitale on Unsplash", for: .normal)
        notification.setTitleColor(.black, for: .normal)
        notification.backgroundColor = .white
        notification.layer.cornerRadius = 5
        notification.layer.masksToBounds = true
        notification.isUserInteractionEnabled = false
        notification.contentEdgeInsets = UIEdgeInsets(top: 15, left: 25, bottom: 15, right: 25)
        
        let parent = UIApplication.shared.keyWindow!;
        
        parent.addSubview(notification)
        
        notificationTopConstraint = notification.topAnchor.constraint(equalTo: parent.topAnchor, constant: -100)
        
        notification.setConstraints([
            notificationTopConstraint,
            notification.centerXAnchor.constraint(equalTo: parent.centerXAnchor)
        ])
    }
    
    func showNotification(interval: DispatchTimeInterval = .seconds(1)) {
        notificationTopConstraint.constant = 85
        let parent = UIApplication.shared.keyWindow!
        
        UIView.animate(withDuration: 0.25) {
            parent.layoutIfNeeded()
        }
        
        delay(interval) {
            self.notificationTopConstraint.constant = -100
            
            UIView.animate(withDuration: 0.25) {
                parent.layoutIfNeeded()
            }
        }
    }
    
    // ThemeList
    var themeList: [CollectionRow.Color] = [
        CollectionRow.Color(id: 218, color: Colors.carrot),
        CollectionRow.Color(id: 217, color: Colors.alizarin),
        CollectionRow.Color(id: 214, color: Colors.emerald),
        CollectionRow.Color(id: 213, color: Colors.sasquatchSocks),
        CollectionRow.Color(id: 212, color: Colors.peterRiver, coverPhoto: "QSfS0KAJLLg"),
        CollectionRow.Color(id: 664239, color: Colors.sunFlower, coverPhoto: "mv2BcIFWMFw"),
        CollectionRow.Color(id: 1020943, color: Colors.squeaky, coverPhoto: "pXf4OH65OhE"),
        CollectionRow.Color(id: 1634213, color: Colors.amethyst, coverPhoto: "e3OSaoc7EuE")
    ]
    
    /*
     * -----------------------
     * MARK: - CoreData
     * ------------------------
     */
    init(persistenceManager: PersistenceManager, layout: UICollectionViewLayout) {
        self.persistenceManager = persistenceManager
        
        super.init(collectionViewLayout: layout)
        
        self.alertHelper = AlertHelper(vc: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     * -----------
     * MARK: - UI
     * -----------
     */
    var indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
    var loader: CustomLoader = CustomLoader()
    var offlineIcon: UIImageView = UIImageView()
    
    var favButton: UIButton = UIButton()
    var favButtonIcon = Icons.favButton

    var waitingView: UIView = UIView()
    var albumsList: [RemoteCollection] = [RemoteCollection]()
    
    /*
     * -----------------
     * MARK: - Lifecycle
     * -----------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "HomeVC"
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Waiting View setup
        waitingView.hide()
        waitingView.backgroundColor = UIColor.black.withAlpha(0.8)
        waitingView.frame = self.view.bounds
        
        view.addSubview(waitingView)
        
        waitingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            waitingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            waitingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            waitingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            waitingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        waitingView.addSubview(loader)
        loader.setupUI(in: waitingView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .accentColorChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAllStyles), name: .themeChanged, object: nil)
        
        Preferences.openCount += 1
        
        // Ask for a review after 5 downloads
        if #available(iOS 10.3, *) {
            if Platform.isSimulator == false {
                let downloadsCount = persistenceManager.fetch(HistoryItem.self).count;
                
                if downloadsCount > 5 || Preferences.openCount > 10  && Platform.isSimulator == false {
                    SKStoreReviewController.requestReview()
                }
            }
        }
        
        if self.title == nil {
            self.title = "Wallpapers"
        }
        
        /*
         * -----------------------
         * MARK: Settings Button
         * ------------------------
         */
        let settingsBtn = UIBarButtonItem(title: "Preferences", style: .plain, target: self, action: #selector(self.openSettings));
        settingsBtn.accessibilityIdentifier = "PreferencesButton"
        settingsBtn.tintColor = navigationController?.navigationBar.tintColor
        navigationItem.rightBarButtonItem = settingsBtn
        
        setupIndicator()
        setupFavButton()
        setupNotification()
        
        NetworkManager.shared.isReachable { (_) in
            DispatchQueue.main.async {
                self.loadCollections()
            }
        }
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(SectionHeader.self)")
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "CollectionCell")
        
        if let goToPage = goToPage {
            switch goToPage {
            case .favorites:
                openFavorites()
                return
            case .history:
                openHistory()
                return
            case .preferences:
                openSettings()
                return
            default:
                break
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setFavTheme()
        
        hero.isEnabled = true
        navigationController?.hero.isEnabled = false
        navigationController?.hero.navigationAnimationType = .none
        navigationController?.navigationBar.barStyle = theme.navigationBarStyle
        
        updateAllStyles()
        
        // If internet connection is available: load collections.
        NetworkManager.shared.isReachable { _ in
            self.updateThemeIfNeeded()
        }
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.accessibilityIdentifier = "HomeVC"
        
        /*
         On first run, setup defaults
         */
        if Preferences.firstRunGone == false {
            Preferences.restoreDefaults()
            Preferences.firstRunGone = true
        }
    }
    
    
    /*
     * ------------------
     * MARK: - Delegate
     * ------------------
     */
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(SectionHeader.self)", for: indexPath) as? SectionHeader {
            
            let albumsCount: Int = collectionView.numberOfItems(inSection: indexPath.section)
            let photosCount: Int = handPickedCollections.reduce(indexPath.section) { (a, b) -> Int in
                return a + b.total_photos
            }
            
            
            
            let attributedTitles: [NSAttributedString?] = [nil, nil, nil]
            let titles: [String?] = [nil, "🔥 Hand Picked // \(photosCount) Photos // \(albumsCount) Albums", "🗂 Categories"]
            
            if attributedTitles[indexPath.section] != nil {
                sectionHeader.headerLabel.attributedText = attributedTitles[indexPath.section]
            } else {
                sectionHeader.headerLabel.text = titles[indexPath.section]
            }
            
            
            
            return sectionHeader
        }
        
        return SectionHeader()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return CGSize(width: 0, height: 35)
        }
    
        return CGSize(width: 0, height: 50)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let haveHandPicked = self.handPickedCollections.count > 1 ? 1 : 0
        return 2 + haveHandPicked
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return themeCollections.count
        } else if section == 1 {
            return handPickedCollections.count
        }
        
        return collections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        typealias Collection = Unsplash.Collection
        
        let collection: Collection = getCollection(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell

        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .gray
        cell.collection = collection
        
        if indexPath.row == 0 && indexPath.section == 1 {
            cell.accessibilityIdentifier = "firstHomeCell"
        }
        
        return cell
    }
    
    func getCollection(at indexPath: IndexPath) -> Unsplash.Collection {
        if indexPath.section == 0 {
            return themeCollections[indexPath.row]
        }
        
        if indexPath.section == 1 {
            return handPickedCollections[indexPath.row]
        }
        
        return collections[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let collection = getCollection(at: indexPath);
        let cell = collectionView.cellForItem(at: indexPath)
        
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.5,
            options: .curveLinear,
            animations:
            {
                cell?.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
            }
        ) { (_) in
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0.5,
                options: .curveLinear,
                animations:
                {
                    cell?.transform = CGAffineTransform.identity
                    
                    
                    let targetVC = CollectionVC(collectionViewLayout: self.setupFlowLayout())
                    targetVC.navigationController?.setNavigationBarHidden(true, animated: false)
                    targetVC.hero.isEnabled = true
                    targetVC.navigationController?.hero.isEnabled = true
                    
                    self.navigationController?.hero.navigationAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
                    
                    
                    targetVC.collection = collection
                    targetVC.title = collection.title
                    
                    self.navigationController?.pushViewController(targetVC, animated: true)
                }
            )
        }
    }

    
    
    /*
     * ------------------
     * MARK: - Utilities
     * ------------------
     */
    private func setupFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 35
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 35, left: 35, bottom: 35, right: 35)
        
        return flowLayout
    }
    
    @objc func themeChanged() {
        needsToBeUpdated = true
    }
    
    func updateThemeIfNeeded() {
        if needsToBeUpdated {
            needsToBeUpdated = false
            self.setFavTheme()
            self.loadThemedCollections()
        }
    }
    
    public func loadThemedCollections(customQuueueGroup queueGroup: DispatchGroup? = nil, completion: (() -> Void)? = nil) {
        self.themeCollections = []
        
        var group:DispatchGroup = DispatchGroup()
        
        if let queueGroup = queueGroup {
            group = queueGroup
        }
        
        
        themeList.forEach { (collection) in
            group.enter()
            
            if collection.isActive {
                let customDescr = collection.customDescription
                let customTitle = collection.customTitle
                
                if apiClient == nil {
                    print("Maybe old keys")
                    let keys = Preferences.keychain.apiKeys;
                    apiClient = UnsplashAPIClient(client_id: keys.access_key, client_secret: keys.secret_key)
                }
                
                if let coverID = collection.coverPhoto {
                    apiClient.getPhoto(id: coverID, completion: { (photo, photo_status) in
                        apiClient.getCollection(id: "\(collection.id)", completion: { (collection, status) in
                            guard var collection = collection else {
                                group.leave()
                                return
                            }
                            
                            if photo_status == 200 {
                                if let cover = photo {
                                    collection.cover_photo = cover
                                }
                            }
                            
                            
                            collection.title = customTitle ?? collection.title
                            collection.description = customDescr ?? collection.description
                            
                            self.themeCollections.append(collection)
                            
                            DispatchQueue.main.async {
                                group.leave()
                            }
                        })
                    })
                } else {
                    apiClient.getCollection(id: "\(collection.id)", completion: { (collection, status) in
                        guard var collection = collection else {
                            group.leave()
                            return
                        }
                        
                        collection.title = customTitle ?? collection.title
                        collection.description = customDescr ?? collection.description
                        
                        self.themeCollections.append(collection)
                        
                        DispatchQueue.main.async {
                            group.leave()
                        }
                    })
                }
            } else {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.needsToBeUpdated = false
            
            if completion != nil {
                completion?()
            } else {
                self.collectionView.reloadData()
            }
        }
    }
    
    public func loadCollections(load: Bool = false, completion: (() -> Void)? = nil) {
        indicator.startAnimating()
        
        self.collections = []
        
        let queueGroup = DispatchGroup()
        
        self.loadThemedCollections(customQuueueGroup: queueGroup)

        self.albumsList.forEach { (collection: RemoteCollection) in
            queueGroup.enter()
            
            let customDescr = collection.customDescription
            let customTitle = collection.customTitle
            
            let isHandPicked = collection.isHandPicked ?? false;
                    
            if let coverID = collection.coverPhoto {
                apiClient.getPhoto(id: coverID, completion: { (photo, photo_status) in
                    apiClient.getCollection(id: "\(collection.id)", completion: { (collection, status) in
                        guard var collection = collection else {
                            queueGroup.leave()
                            return
                        }
                        
                        if photo_status == 200 {
                            if let cover = photo {
                                collection.cover_photo = cover
                            }
                        }
                        
                        collection.title = customTitle ?? collection.title
                        collection.description = customDescr ?? collection.description
                        
                        if isHandPicked {
                            self.handPickedCollections.append(collection)
                            DispatchQueue.main.async {
                                self.handPickedCollections.sort(by: { (a, b) -> Bool in
                                    if a.id == 3644553 {
                                        return true
                                    }
                                    
                                    if b.id == 3644553 {
                                        return false
                                    }
                                    
                                    return a.total_photos > b.total_photos
                                })
                                queueGroup.leave()
                            }
                            return
                        }
                        
                        
                        self.collections.append(collection)
                        
                        DispatchQueue.main.async {
                            self.collections.sort(by: {$0.total_photos > $1.total_photos})
                            queueGroup.leave()
                        }
                    })
                })
            } else {
                apiClient.getCollection(id: "\(collection.id)", completion: { (collection, status) in
                    guard var collection = collection else {
                        queueGroup.leave()
                        return
                    }
                    
                    collection.title = customTitle ?? collection.title
                    collection.description = customDescr ?? collection.description

                    if isHandPicked {
                        self.handPickedCollections.append(collection)
                        DispatchQueue.main.async {
                            self.handPickedCollections.sort(by: { (a, b) -> Bool in
                                if a.id == 3644553 {
                                    return true
                                }
                                
                                if b.id == 3644553 {
                                    return false
                                }
                                
                                return a.total_photos > b.total_photos
                            })
                            queueGroup.leave()
                        }
                        return
                    }

                    
                    self.collections.append(collection)
                    
                    DispatchQueue.main.async {
                        self.collections.sort(by: {$0.total_photos > $1.total_photos})
                        queueGroup.leave()
                    }
                })
            }
        }
        queueGroup.notify(queue: .main) {
            self.indicator.stopAnimating()
            self.collectionView.reloadData()
            
            completion?()
        }
    }
    
    private func showNoSignal() {
        let targetView: UIView = self.collectionView
        
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
    
    
    
    /*
     * -----------------------
     * MARK: - UISetup
     * ------------------------
     */
    fileprivate func setupIndicator() {
        indicator.hidesWhenStopped = true
        
        view.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    fileprivate func setupFavButton() {
        setFavTheme()
        
        favButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(favButton)
        
        favButton.addTarget(self, action: #selector(openFavorites), for: .touchUpInside)
        favButton.addParallaxEffect()
        
        NSLayoutConstraint.activate([
            favButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            favButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            favButton.heightAnchor.constraint(equalToConstant: 65)
        ])
    }
    
    /*
     * -----------------------
     * MARK: - Utilities
     * ------------------------
     */
    
    func setFavTheme() {
        var imageName: UIImage?
        
        switch(theme.accentColor.name.lowercased()) {
        case "alizarin":
            imageName = favButtonIcon.light.alizarin
            break;
        case "peter river":
            imageName = favButtonIcon.light.peterRiver
            break
        case "sun flower":
            imageName = favButtonIcon.light.sunFlower
            break
        case "emerald":
            imageName = favButtonIcon.light.emerald
            break
        case "amethyst":
            imageName = favButtonIcon.light.amethyst
            break
        case "squeaky":
            imageName = favButtonIcon.light.squeaky
            break
        case "sasquatch socks":
            imageName = favButtonIcon.light.sasquatchSocks
            break
        case "carrot":
            imageName = favButtonIcon.light.carrot
            break
        default:
            imageName = favButtonIcon.light.cloud
            break
        }
        
        
        favButton.setImage(imageName, for: .normal)
    }
    
    
    /*
     
     * -----------------------
     * MARK: - Actions
     * ------------------------
     */
    
    @objc func openFavorites() {
        let vc = FavouritesVC.init(collectionViewLayout: self.setupFlowLayout())
        vc.items = persistenceManager.fetch(Favourite.self)
        vc.collectionView.backgroundColor = theme.color
        vc.title = "Favourites"
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openHistory() {
        let vc = HistoryVC.init(style: .grouped)
        vc.items = persistenceManager.fetch(HistoryItem.self)
        vc.tableView.backgroundColor = theme.color
        vc.title = "History"
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openSettings() {
        let destination = SettingsVC(persistenceManager: self.persistenceManager, style: .grouped)
        destination.title = "Preferences"
        
        navigationController?.pushViewController(destination, animated: true)
    }
    
    
}
