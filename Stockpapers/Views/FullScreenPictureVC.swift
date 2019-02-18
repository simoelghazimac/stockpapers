//
//  FullScreenPicture.swift
//  Wallpapers
//
//  Created by Federico Vitale on 11/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import UIKit
import QuartzCore
import Nuke
import Hero
import Firebase
import Device

class FullScreenPictureVC: UIViewController {
    var container = UIImageView()
    
    var downloadButton: UIButton = UIButton()
    var closeButton: UIButton = UIButton()
    var rotateBtn: UIButton = UIButton()
    
    var photo: Unsplash.Photo!
    var indicator: CustomLoader = CustomLoader()
    
    var favBtn: UIButton = UIButton()
    var watermark: UIButton = {
        let button = UIButton();
        
        button.isEnabled = false
        button.isUserInteractionEnabled = false
        
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10, weight: .bold)
        button.layer.cornerRadius = 3
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 2.5, left: 5, bottom: 2.5, right: 5)
        
        // button.setImage(UIImage(named: "Images/Watermark"), for: .normal)
        button.alpha = 0.5
        button.hide()
        
        return button
    }()
   
    var originalCenter: CGPoint?
    
    let theme: Theme = Preferences.theme
    let persistenceManager: PersistenceManager
    
    let topRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100);
    
    var rotationAngle: CGFloat = 0 {
        didSet {
            if rotationAngle >= 360 {
                rotationAngle = 0
            }
        }
    }
    
    // CoreData
    init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
     * -----------------------
     * MARK: - Lifecycle
     * ------------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "FullScreenPictureVC"
        
        self.originalCenter = self.view.center
        
        
        // HERO Setup
        self.hero.isEnabled = true
        
        // NavigationController Setup
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        
        // Setup UI
        setupImage()
        
        // Pan down to close
        let slideDownGesture = UIPanGestureRecognizer(target: self, action: #selector(self.slideToClose))
        view.addGestureRecognizer(slideDownGesture)
        

        // Setup the close button
        setupCloseBtn()
        setupRotateBtn()
        setupFavBtn()
        setupWatermark()
        
        watermark.setTitle("Shot by @\(photo.user.username)", for: .normal)
        
        // Setup the download button
        setupDownloadButton()
        
        
        if Preferences.parallaxEffectOnImagePreview == true {
            closeButton.addParallaxEffect()
            rotateBtn.addParallaxEffect()
            favBtn.addParallaxEffect()
            downloadButton.addParallaxEffect()
        }
        
        if container.image == nil {
            Nuke.loadImage(
                with: photo.getURL(ofSize: Preferences.highQualityPreview ? .raw : .full),
                options: ImageLoadingOptions(
                    transition: ImageLoadingOptions.Transition.fadeIn(duration: 0.25)
                ),
                into: container,
                completion: { (response, error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default))
                        
                        DispatchQueue.main.async {
                            self.present(alert, animated: true)
                        }
                        
                        return
                    }
                    
                    self.showUI()
                }
            )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        if Preferences.hideGesture == "tap" {
            let tap = UITapGestureRecognizer(target: self, action: #selector(toggleHideButtons))
            view.addGestureRecognizer(tap)
        } else if Preferences.hideGesture == "long-press" {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(hideButtons))
            view.addGestureRecognizer(longPress)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        hideUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard self.container.image != nil else { return }
        
        Nuke.loadImage(
            with: self.photo.urls.full,
            options: ImageLoadingOptions(
                placeholder: self.container.image,
                transition: .fadeIn(duration: 0.25),
                failureImage: self.container.image,
                failureImageTransition: .fadeIn(duration: 0.25)
            ),
            into: self.container) { (_, _) in
        }
        
        showUI()
    }
    
    /*
     * -----------------------
     * MARK: - CoreData
     * ------------------------
     */
    func saveHistoryItem(photo: Unsplash.Photo) {
        let item = HistoryItem(context: persistenceManager.context)
        
        item.id  = photo.id
        item.url = photo.urls.regular
        item.download_date = NSDate()
        
        persistenceManager.save()
    }
    
    func saveFavourite(photo: Unsplash.Photo) {
        let item = Favourite(context: persistenceManager.context)
        
        item.id = photo.id
        item.url = photo.urls.regular
        item.addedOn = NSDate()
        
        persistenceManager.save()
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        Analytics.logEvent("favourite_created", parameters: [
            "photo_id" : self.photo.id
        ])
    }
    
    var onClose = {
        // Some code
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let img = self.container.image {
            return (img.averageColor?.isLight() ?? false) ? .default : .lightContent
        }
        
        return (UIColor(hexString: photo.color).isLight() ?? false) ? .default : .lightContent
    }
    
    
    /*
     * -----------------------
     * MARK: - Custom Actions
     * ------------------------
     */
    @objc func hideButtons(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            hideUI()
            
            if Preferences.keychain.watermarksRemoved == false {
                UIView.animate(withDuration: 0.25) {
                    self.watermark.alpha = 0.5
                }
            }
            break
        default:
            UIView.animate(withDuration: 0.25, animations: {
                self.watermark.alpha = 0
            }) { (_) in
                self.showUI()
            }
            break
        }
    }
    
    @objc func toggleHideButtons(_ sender: UITapGestureRecognizer) {
        if self.downloadButton.alpha == 1 {
            hideUI()
            
            if Preferences.keychain.watermarksRemoved == false {
                UIView.animate(withDuration: 0.25) {
                    self.watermark.alpha = 0.5
                }
            }
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.watermark.alpha = 0
            }) { (_) in
                self.showUI()
            }
        }
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
            hideUI()
            self.watermark.hide()
            
            
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
                
                
                showUI()
                return
            }
            
            print("Closes at: \(delta)", "min: \(UIScreen.main.bounds.height / 3.5) - \(UIScreen.main.bounds.height / 5.5) - \(UIScreen.main.bounds.height / 7.5)")
           
            hero.dismissViewController {
                self.onClose()
            }
            
            break
        }
    }
    
    
    // Save the current wp
    @objc private func saveImage() {
        self.indicator.start()
        
        if let data = try? Data(contentsOf: self.photo.getURL(ofQuality: Preferences.pictureQuality)) {
            DispatchQueue.main.async {
                self.saveHistoryItem(photo: self.photo)

                let source = UIImage(data: data);
                self.container.image = imageRotatedByDegrees(oldImage: source!, deg: self.rotationAngle)
                
                // TODO: Change the crop method
                if Preferences.keychain.watermarksRemoved == false {
                    self.watermark.show()
                }
                
                if Preferences.cropImages == true {
                    let image = self.getImage(fromView: self.container)!
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.onceSaved), nil)
                } else {
                    UIImageWriteToSavedPhotosAlbum(source!, self, #selector(self.onceSaved), nil)
                }
            }
        }
    }
    
    @objc private func setFavourite() {
        let image: UIImage!
        
        if self.isFavourite() {
            // Change the icon
            
            if favBtn.currentImage == Icons.favourite.filled.dark {
                image = Icons.favourite.outline.dark
            } else {
                image = Icons.favourite.outline.light
            }
            
            // Remove the item from favourites
            if let item = getCurrentFavouriteItem() {
                persistenceManager.context.delete(item)
                try? persistenceManager.context.save()
            }
            
        } else {
            // change the icon
            if favBtn.currentImage == Icons.favourite.outline.dark {
                image = Icons.favourite.filled.dark
            } else {
                image = Icons.favourite.filled.light
            }
            
            self.saveFavourite(photo: photo)
        }
        
        self.favBtn.setImage(image, for: .normal)
    }
    
    
//  Notify save success
    @objc func onceSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        Analytics.logEvent("photo_saved", parameters: [
            "photo_id" : self.photo.id
        ])
        
        
         
        self.watermark.hide()
        
        if error != nil {
            self.indicator.stop(text: "Error") {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
            
            print(error!.localizedDescription)
            return
        }
        
        
        self.indicator.stop(text: "Saved!") {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    // Go Back to the collectionviewcontroller
    @objc func goBack() {
        hero.dismissViewController()
    }
    
    @objc func rotateRight() {
        self.container.image = imageRotatedByDegrees(oldImage: self.container.image!, deg: 90)
        self.rotationAngle += 90
        
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    /*
     * -----------------------
     * MARK: - UI SETUP
     * ------------------------
     */
    fileprivate func setupFavBtn() {
        favBtn.hide()
        favBtn.accessibilityIdentifier = "favoritesButton"
        
        favBtn.addTarget(self, action: #selector(self.setFavourite), for: .touchUpInside)
        
        view.addSubview(favBtn)
        
        favBtn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            favBtn.topAnchor.constraint(equalTo: rotateBtn.bottomAnchor, constant: 25),
            favBtn.rightAnchor.constraint(equalTo: rotateBtn.rightAnchor),
        ])
        
        favBtn.layoutIfNeeded()
        
        var image: UIImage!
        
        if self.isFavourite() {
            if self.lightUI(rotateBtn) {
                image = Icons.favourite.filled.dark
            } else {
                image = Icons.favourite.filled.light
            }
        } else {
            if self.lightUI(rotateBtn) {
                image = Icons.favourite.outline.dark
            } else {
                image = Icons.favourite.outline.light
            }
        }
        
        favBtn.setImage(image, for: .normal)
    }
    
    
    fileprivate func setupRotateBtn() {
        rotateBtn.hide()
        rotateBtn.accessibilityIdentifier = "rotateButton"
        
        rotateBtn.addTarget(self, action: #selector(self.rotateRight), for: .touchUpInside)
        
        view.addSubview(rotateBtn)
        
        rotateBtn.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            rotateBtn.topAnchor.constraint(equalTo: closeButton.topAnchor),
            rotateBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
        ])
        
        
        var image: UIImage!
        
        if lightUI(rotateBtn) == true {
            image = Icons.rotate.dark
        } else {
            image = Icons.rotate.light
        }
        
        rotateBtn.setImage(image, for: .normal)
    }
    
    // Setting up the close button
    fileprivate func setupCloseBtn() {
        closeButton.hide()
        closeButton.accessibilityIdentifier = "closeButton"
        
        closeButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 35),
            closeButton.widthAnchor.constraint(equalToConstant: 35),
        ])
        
        closeButton.layoutIfNeeded()
        
        let image: UIImage? = Icons.close.light
        
        if lightUI(closeButton) == true {
            closeButton.tintColor = Colors.brainGray
        } else {
            closeButton.tintColor = Colors.cloud
        }
        
        closeButton.setImage(image, for: .normal)
    }
    
    
    // Setting up the download button
    fileprivate func setupDownloadButton() {
        let image = Icons.downloadButton
        
        downloadButton.accessibilityIdentifier = "downloadButton"
        
        downloadButton.setImage(image, for: .normal)
        downloadButton.imageView?.contentMode = .scaleAspectFit
        
        downloadButton.addTarget(self, action: #selector(self.saveImage), for: .touchUpInside)
        downloadButton.hide()
        
        view.addSubview(downloadButton)
        
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
        ])
        
        downloadButton.layoutIfNeeded()
        downloadButton.sizeToFit()
    }
    
    fileprivate func setupWatermark() {
        container.addSubview(watermark)
        watermark.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            watermark.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            watermark.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    
    // Setting up the container
    fileprivate func setupImage() {
        container.backgroundColor = UIColor(hexString: self.photo.color)
        container.isUserInteractionEnabled = true
        
        container.layer.masksToBounds = true
        container.contentMode = .scaleAspectFill
        
        container.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.rightAnchor.constraint(equalTo: view.rightAnchor),
            container.leftAnchor.constraint(equalTo: view.leftAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height)
        ])
        

        container.addSubview(indicator)
        indicator.setupUI(in: container)
    }
    
    /*
     * -----------------------
     * MARK: - Utilities
     * ------------------------
     */
    
    func showUI() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.downloadButton.show()
            self.closeButton.show()
            self.rotateBtn.show()
            self.favBtn.show()
        })
    }
    
    func hideUI() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.downloadButton.hide()
            self.closeButton.hide()
            self.rotateBtn.hide()
            self.favBtn.hide()
        })
    }
    
    func lightUI(_ item: UIView, threshold: Float = 0.5) -> Bool {
        view.layoutIfNeeded()
        return self.container.image?.crop(rect: item.frame)?.averageColor?.isLight(threshold: threshold) == true
    }
    
    func isFavourite() -> Bool {
        let items = persistenceManager.fetch(Favourite.self)
        return items.filter({ $0.id == photo.id }).count >= 1
    }
    
    func getCurrentFavouriteItem() -> Favourite? {
        let items = persistenceManager.fetch(Favourite.self)
        return items.filter({ $0.id == photo.id }).first
    }
    
    // Get a "screen sized" portion of the image
    func getImage(fromView view: UIView) -> UIImage? {
        self.indicator.isHidden = true

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            self.indicator.isHidden = false
            return image
        }
        
        self.indicator.isHidden = false
        return nil
    }
}


/*
 * -----------------------
 * MARK: - Navigation
 * ------------------------
 */
extension FullScreenPictureVC: UIGestureRecognizerDelegate {
    private func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

