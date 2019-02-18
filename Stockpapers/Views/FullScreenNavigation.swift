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


class FullScreenNavigation: UICollectionViewController {
    var theme: Theme {
        return Preferences.theme
    }
    
    var selectedIndex: IndexPath!
    var collection: Unsplash.Collection!
    var photos: [Unsplash.Photo] = [Unsplash.Photo]()
    
    var collection_page: Int = 0
    var isFetching: Bool = false
    var originalCenter: CGPoint?

    
    /*
     * -----------------
     * MARK: - Lifecycle
     * -----------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "FullScreenNavigation"
        
        collectionView.backgroundColor = theme.color
        collectionView!.register(FullScreenCell.self, forCellWithReuseIdentifier: "\(FullScreenCell.self)")
        
        let slideDownGesture = UIPanGestureRecognizer(target: self, action: #selector(self.slideToClose))
        view.addGestureRecognizer(slideDownGesture)

        self.originalCenter = self.view.center

        // Setting up HERO
        hero.isEnabled = true
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.navigationBar.barStyle = Preferences.theme.navigationBarStyle
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        if self.photos.count>0 {
            print("I will scroll to \(selectedIndex.row) from \(collectionView.getCurrentPage())")
            collectionView.scrollToItem(at: selectedIndex, at: .centeredVertically, animated: true)
        }
    }
    
    /*
     * -----------------------
     * MARK: - StatusBar Stuff
     * ------------------------
     */
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var prefersStatusBarHidden: Bool {
        return Preferences.showStatusBarOnPreview == false
    }
    
    /*
     * -----------------------
     * MARK: - Delegate
     * ------------------------
     */
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ( collectionView.getCurrentPage() == (photos.count - 5) && photos.count > 0) {
            fetchPhotos()
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let indexPath = IndexPath(row: collectionView.getCurrentPage(), section: 0)

        guard collectionView.cellForItem(at: indexPath) != nil else {
            fetchPhotos()
            return
        }
    }
    
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let indexPath = IndexPath(row: collectionView.getCurrentPage(), section: 0)

        guard collectionView.cellForItem(at: indexPath) != nil else {
            fetchPhotos()
            return
        }
    }
    
    func fetchPhotos() {
        if isFetching == false {
            if self.photos.count < self.collection.total_photos {
                isFetching = true
                
                self.collection_page += 1
                
                print("Fetching page: \(self.collection_page) of \(Int(self.collection.total_photos / 30)). isFetching: \(isFetching)")
                
                apiClient.getPhotosFromCollection(collection: self.collection, page: self.collection_page) { (photos, statusCode) in
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(FullScreenCell.self)", for: indexPath) as! FullScreenCell
        let photo = photos[indexPath.row]
        
        cell.setup(photo)

        cell.backgroundColor = .clear
        cell.imageView.backgroundColor = UIColor(hexString: photo.color)
        cell.layer.masksToBounds = true
        cell.delegate = self
        
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
        
        if indexPath.row == 0 {
            cell.accessibilityIdentifier = "firstFullScreenCollectionCell"
        }
        
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}


/*
 * -----------------------
 * MARK: - Prefetch
 * ------------------------
 */
extension FullScreenNavigation: UICollectionViewDataSourcePrefetching {
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
extension FullScreenNavigation {
    private func loadImageForCellAt(indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(FullScreenCell.self)", for: indexPath) as! FullScreenCell
        let photo = photos[indexPath.row];
        
        Nuke.loadImage(
            with: photo.getURL(ofQuality: .thumb),
            options: ImageLoadingOptions(
                transition: ImageLoadingOptions.Transition.fadeIn(duration: 0.25)
            ),
            into: cell.imageView
        )
    }
    
    
    @objc func slideToClose(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        let newPosition = CGPoint(x: self.view.center.x + (translation.x / 2), y: self.view.center.y + translation.y)
        let delta = newPosition.y - originalCenter!.y;
        
        if 1 - ((delta / 100) / 3) >= 0.5 {
            view.alpha = 1 - ((delta / 100) / 3)
        }
        
        
        switch gesture.state {
        case .began, .changed:
            if newPosition.y >= originalCenter!.y {
                self.view.center = newPosition
            }
            
            print(delta, CloseGesture.sizes[Preferences.closeFullScreenVCGestureSize.rawValue])
            
            gesture.setTranslation(.zero, in: self.view)
            break
        default:
            UIView.animate(withDuration: 0.25) {
                self.view.alpha = 1
            }
            
            // if the drag-to-exit is cancelled
            if delta < (CloseGesture.sizes[Preferences.closeFullScreenVCGestureSize.rawValue]) {
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseOut, animations: {
                    self.view.center = self.originalCenter!
                }, completion: nil)
                
                
                return
            }
            
            print("Closes at: \(delta)", "min: \(UIScreen.main.bounds.height / 3.5) - \(UIScreen.main.bounds.height / 5.5) - \(UIScreen.main.bounds.height / 7.5)")
            
            hero.dismissViewController()
            break
        }
    }
    
}

/*
 * -----------------------
 * MARK: - Navigation
 * ------------------------
 */
extension FullScreenNavigation: UIGestureRecognizerDelegate {
    private func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController!.viewControllers.count > 1 {
            return true
        }
        
        return false
    }
}





