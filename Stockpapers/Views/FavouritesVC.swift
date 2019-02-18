//
//  FavouritesVC.swift
//  Stockpapers
//
//  Created by Federico Vitale on 07/12/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import Hero
import Nuke
import Firebase

class FavouritesVC: UICollectionViewController {
    let cellID = "FavouriteCollectionCell"
    
    var items: [Favourite] = [Favourite]()
    var photos: [Unsplash.Photo] = [Unsplash.Photo]()
    
    var theme: Theme {
        return Preferences.theme
    }
    
    /*
     * -----------------------
     * MARK: - Lifecycle
     * ------------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(PictureCell.self, forCellWithReuseIdentifier: self.cellID)
        
        Analytics.logEvent("favourites_vc_opened", parameters: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAllStyles()
        self.loadItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    /*
     * -----------------------
     * MARK: - Delegate
     * ------------------------
     */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! PictureCell
        let photo = photos[indexPath.row]
        
        Nuke.loadImage(
            with: photo.urls.regular,
            options: ImageLoadingOptions(transition: .fadeIn(duration: 0.25)),
            into: cell.imageView
        )
        
        cell.imageView.hero.id = photo.id
        cell.backgroundColor = .clear
        cell.imageView.backgroundColor = UIColor(hexString: photo.color)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 8
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let cell = collectionView.cellForItem(at: indexPath) as! PictureCell
        
        let destinationVC = FullScreenPictureVC(persistenceManager: PersistenceManager.shared)
        destinationVC.photo = self.photos[indexPath.row]
        
        destinationVC.onClose = {
            self.items = PersistenceManager.shared.fetch(Favourite.self)
            self.photos = []
            self.loadItems()
        }
        
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
    
    
    /*
     * -----------------------
     * MARK: - Utilities
     * ------------------------
     */
    func loadItems() {
        let queue: DispatchGroup = DispatchGroup()
        
        items.forEach { (item) in
            queue.enter()
            apiClient.getPhoto(id: item.id, completion: { (photo, _) in
                if let photo = photo {
                    self.photos.append(photo)
                    queue.leave()
                }
            })
        }
        
        queue.notify(queue: .main) {
            self.collectionView.reloadData()
        }
    }
}
