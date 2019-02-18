
//
//  PreviewCell.swift
//  Wallpapers
//
//  Created by Federico Vitale on 16/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import Nuke

class PreviewCell: UITableViewCell {
    var previewImage: UIImageView = UIImageView()
    var title: UILabel = UILabel()
    var descr: UILabel = UILabel()
    var searchTags: [String]?
    
    var queue = DispatchGroup()
    var view: UIVisualEffectView = UIVisualEffectView()
    
    var collection: Unsplash.Collection? {
        didSet {
            guard collection != nil else { return }
            guard let url = self.collection!.cover_photo?.urls.regular else { return }
            
            setupUI()
            
            self.title.text = collection!.title
            self.descr.text = collection!.description
            
            Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.2)), into: self.previewImage, progress: nil) { (_, _) in
                self.setupTitle()
                
                if self.collection?.description != nil {
                    self.setupDescription()
                }
                
            }
        }
    }
    
    init (reuseIdentifier identifier: String? = nil) {
        super.init(style: .default, reuseIdentifier: identifier)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     * ------------------------
     * MARK: - UI
     * ------------------------
     */
    private func setupUI() {
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .red
        
        self.selectedBackgroundView = selectedBackgroundView
        
        setupPreviewImage()
        setupOverlay()
        setupTitle()
    }
    
    private func setupPreviewImage() {
        self.addSubview(previewImage)
        
        previewImage.backgroundColor = Colors.brainGray
        previewImage.contentMode = .scaleAspectFill
        previewImage.layer.masksToBounds = true
        
        previewImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            previewImage.topAnchor.constraint(equalTo: self.topAnchor),
            previewImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            previewImage.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func setupOverlay() {
        let view = UIView(frame: .zero)
        
        view.alpha = 0.5
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: previewImage.topAnchor),
            view.bottomAnchor.constraint(equalTo: previewImage.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: previewImage.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: previewImage.leadingAnchor)
        ])
    }
    
    private func setupDescription() {
        self.addSubview(descr)
        self.bringSubviewToFront(descr)
        
        descr.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descr.numberOfLines = 1
        descr.textColor = Colors.cloud
        
        descr.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            descr.leadingAnchor.constraint(equalTo:  title.leadingAnchor),
            descr.topAnchor.constraint(equalTo:   title.bottomAnchor, constant: 5),
            descr.trailingAnchor.constraint(equalTo: title.trailingAnchor, constant: -15),
        ])
    }
    
    private func setupTitle() {
        self.addSubview(title)
        self.bringSubviewToFront(title)
        
        title.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        title.text = title.text?.capitalized
        title.numberOfLines = 0
        title.textColor = Colors.cloud
        
        title.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo:  self.leadingAnchor, constant: 15),
            title.bottomAnchor.constraint(equalTo:   self.bottomAnchor, constant: self.collection?.description != nil ? -45 : -15),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}



extension UIImageView
{
    func addColor(ofColor color: UIColor = UIColor.black) {
        let view = UIView(frame: .zero)
        
        view.alpha = 0.5
        view.backgroundColor = color
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }
    
    func addBlurEffect(withStyle style: UIBlurEffect.Style = .dark) -> UIVisualEffectView
    {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        
        self.addSubview(blurEffectView)
        
        return blurEffectView
    }
}
