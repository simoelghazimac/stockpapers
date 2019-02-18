//
//  FullScreenCell.swift
//  Stockpapers
//
//  Created by Federico Vitale on 13/02/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


class FullScreenCell: UICollectionViewCell {
    weak var delegate: FullScreenNavigation?

    
    var imageView: UIImageView = UIImageView()
    
    var downloadButton: UIButton = UIButton()
    var closeButton: UIButton = UIButton()
    var rotateBtn: UIButton = UIButton()
    var favBtn: UIButton = UIButton()
    
    var indicator: CustomLoader = CustomLoader()
    
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
        
        button.alpha = 0.5
        button.hide()
        
        return button
    }()
    
    var photo: Unsplash.Photo!
    var originalCenter: CGPoint?
    let theme: Theme = Preferences.theme
    let persistenceManager: PersistenceManager = PersistenceManager.shared
    
    let topRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100);
    
    var rotationAngle: CGFloat = 0 {
        didSet {
            if rotationAngle >= 360 {
                rotationAngle = 0
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ current_photo: Unsplash.Photo) {
        self.photo = current_photo
        self.originalCenter = self.center
        
        // Setup UI
        setupImageView()
        
        
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
        
        
        
        if Preferences.hideGesture == "tap" {
            let tap = UITapGestureRecognizer(target: self, action: #selector(toggleHideButtons))
            addGestureRecognizer(tap)
        } else if Preferences.hideGesture == "long-press" {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(hideButtons))
            addGestureRecognizer(longPress)
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
    
    // Save the current wp
    @objc private func saveImage() {
        self.indicator.start()
        
        if let data = try? Data(contentsOf: self.photo.getURL(ofQuality: Preferences.pictureQuality)) {
            DispatchQueue.main.async {
                self.saveHistoryItem(photo: self.photo)
                
                let source = UIImage(data: data);
                self.imageView.image = imageRotatedByDegrees(oldImage: source!, deg: self.rotationAngle)
                
                // TODO: Change the crop method
                if Preferences.keychain.watermarksRemoved == false {
                    self.watermark.show()
                }
                
                if Preferences.cropImages == true {
                    let image = self.getImage(fromView: self.imageView)!
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
    
    @objc func rotateRight() {
        self.imageView.image = imageRotatedByDegrees(oldImage: self.imageView.image!, deg: 90)
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
        
        addSubview(favBtn)
        
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
        
        addSubview(rotateBtn)
        
        rotateBtn.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            rotateBtn.topAnchor.constraint(equalTo: closeButton.topAnchor),
            rotateBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -25),
        ])
        
        
        var image: UIImage!
        
        if lightUI(rotateBtn) == true {
            image = Icons.rotate.dark
        } else {
            image = Icons.rotate.light
        }
        
        rotateBtn.setImage(image, for: .normal)
    }
    
    
    @objc func onClose() {
        if let del = self.delegate {
            del.dismiss(animated: true, completion: nil)
        }
    }
    
    // Setting up the close button
    fileprivate func setupCloseBtn() {
        closeButton.hide()
        closeButton.accessibilityIdentifier = "closeButton"
        
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        
        addSubview(closeButton)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
            closeButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
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
        
        addSubview(downloadButton)
        
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            downloadButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            downloadButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -15),
        ])
        
        downloadButton.layoutIfNeeded()
        downloadButton.sizeToFit()
    }
    
    fileprivate func setupWatermark() {
        imageView.addSubview(watermark)
        watermark.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            watermark.centerXAnchor.constraint(equalTo: centerXAnchor),
            watermark.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    
    // Setting up the imageView
    fileprivate func setupImageView() {
        imageView.isUserInteractionEnabled = true
        
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        
        imageView.fillSuperView()
        
        
        imageView.addSubview(indicator)
        indicator.setupUI(in: imageView)
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
        self.layoutIfNeeded()
        return self.imageView.image?.crop(rect: item.frame)?.averageColor?.isLight(threshold: threshold) == true
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
