//
//  CollectionView.swift
//  Wallpapers
//
//  Created by Federico Vitale on 12/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import UIKit
import Nuke
import Hero
import Firebase

private let reuseIdentifier = "Cell"

struct Limit {
    static var plusUser = 16
    static var baseUser = 11
}

class CollectionVC: UICollectionViewController {
    var theme: Theme {
        return Preferences.theme
    }
    
    var collection: Unsplash.Collection!
    var coverPhoto: UIImage!
    var photos: [Unsplash.Photo] = [Unsplash.Photo]()
    
    var collection_page: Int = 0
    var isFetching: Bool = false
    
    var statusBarHidden: Bool = false
    var limit: Int = Limit.baseUser
    
    var refreshControl = UIRefreshControl()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /*
     * -----------------
     * MARK: - Lifecycle
     * -----------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "CollectionVC"
        
        Analytics.logEvent("collection_opened", parameters: [
            "id": collection.id
        ])
        
        if title == nil {
            title = "Collection"
        }
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        
        
        refreshControl.tintColor = Preferences.themeColor
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching photos...", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold),
            NSAttributedString.Key.foregroundColor: Preferences.themeColor.withAlpha(0.8)
        ])
        
        refreshControl.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        
        title = title?.capitalized
        
        collectionView.backgroundColor = theme.color
        
        collectionView!.register(PictureCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Setting up HERO
        hero.isEnabled = true
    }
    
    @objc func reload() {
        self.isFetching = true
        
        apiClient.getPhotosFromCollection(collection: self.collection, page: self.collection_page, limit: self.limit) { (photos, statusCode) in
            if let photos = photos {
                if self.photos.count < photos.count {
                    self.photos = photos
                }
                
                DispatchQueue.main.async {
                    self.isFetching = false
                    self.refreshControl.endRefreshing()
                    self.collectionView.reloadData()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barStyle = Preferences.theme.navigationBarStyle
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        limit = collection.total_photos
    }
    
    
    /*
     * -----------------------
     * MARK: - Delegate
     * ------------------------
     */
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > (contentHeight - scrollView.frame.height - 350) {
            if isFetching == false {
                if self.photos.count < self.collection.total_photos && self.photos.count < self.limit {
                    isFetching = true
                    
                    self.collection_page += 1
                    
                    print("Fetching page: \(self.collection_page) of \(Int(self.collection.total_photos / 30)). isFetching: \(isFetching)")

                    apiClient.getPhotosFromCollection(collection: self.collection, page: self.collection_page, limit: self.limit) { (photos, statusCode) in
                        if let photos = photos {
                            self.photos += photos

                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                                self.isFetching = false
                                print("Page \(self.collection_page) fetched. isFetching: \(self.isFetching)")
                            }
                        }
                    }
                }
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PictureCell
        let photo = photos[indexPath.row]
        
        cell.backgroundColor = .clear
        cell.imageView.backgroundColor = UIColor(hexString: photo.color)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 8
        
        if photo.id.isEmpty == false {
            cell.imageView.hero.id = "\(photo.id)"
        }
        
        Nuke.loadImage(
            with: photo.getURL(ofSize: .regular),
            options: ImageLoadingOptions(
                transition: ImageLoadingOptions.Transition.fadeIn(duration: 0.25)
            ),
            into: cell.imageView
        )
        
        cell.label.isHidden = true
        cell.label.text = photo.id
        
        if indexPath.row == 0 {
            cell.accessibilityIdentifier = "firstCollectionCell"
        }
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cell = collectionView.cellForItem(at: indexPath) as! PictureCell;
        let photo = photos[indexPath.row]
        
        if Preferences.experimentalFeaturesEnabled {
            let fullScreenLayout = UICollectionViewFlowLayout()
            fullScreenLayout.scrollDirection = .horizontal
            fullScreenLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            fullScreenLayout.minimumInteritemSpacing = 10
            fullScreenLayout.minimumLineSpacing = 10
            
            let vc = FullScreenNavigation(collectionViewLayout: fullScreenLayout)
            vc.collection = self.collection
            vc.photos = photos
            vc.hero.isEnabled = true
            vc.hero.modalAnimationType = .none
            vc.selectedIndex = indexPath
            
            vc.modalPresentationStyle = .overFullScreen
            vc.modalPresentationCapturesStatusBarAppearance = true
            
            self.present(vc, animated: true)
            
            return
        }
        
        let destinationVC = FullScreenPictureVC(persistenceManager: PersistenceManager.shared)
        destinationVC.photo = photo
        
        // Hero
        destinationVC.hero.isEnabled = true
        destinationVC.hero.modalAnimationType = .none
        
        if cell.imageView.hero.id != nil {
            destinationVC.container.hero.id = cell.imageView.hero.id
        }
        
        destinationVC.container.image = cell.imageView.image
        
        destinationVC.modalPresentationStyle = .overFullScreen
        destinationVC.modalPresentationCapturesStatusBarAppearance = true
        
        self.present(destinationVC, animated: true)
    }
    
    @objc func hideStatusBar() {
        statusBarHidden = !Preferences.showStatusBarOnPreview
        
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        print("Status Bar is: \(self.prefersStatusBarHidden ? "hidden" : "visible")")
    }
}


/*
 * -----------------------
 * MARK: - Prefetch
 * ------------------------
 */
extension CollectionVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            self.loadImageForCellAt(indexPath: indexPath)
        }
    }
}

/*
 * -----------------------
 * MARK: - Utility
 * ------------------------
 */
extension CollectionVC {
    private func loadImageForCellAt(indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PictureCell
        let photo = self.photos[indexPath.row];
        
        Nuke.loadImage(
            with: photo.getURL(ofQuality: .thumb),
            options: ImageLoadingOptions(
                transition: ImageLoadingOptions.Transition.fadeIn(duration: 0.25)
            ),
            into: cell.imageView
        )
    }
}

/*
 * -----------------------
 * MARK: - Navigation
 * ------------------------
 */
extension CollectionVC: UIGestureRecognizerDelegate {
    private func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController!.viewControllers.count > 1 {
            return true
        }
        
        return false
    }
}
