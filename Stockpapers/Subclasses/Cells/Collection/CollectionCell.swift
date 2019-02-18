//
//  CollectionCell.swift
//  Wallpapers
//
//  Created by Federico Vitale on 19/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import Nuke


class CollectionCell: UICollectionViewCell {
    var previewImage:UIImageView = UIImageView()
    var title:UILabel = UILabel()
    var descr:UILabel = UILabel()
    var fullDescr:UILabel = UILabel()
    
    var detailButton: UIButton = UIButton()
    
    private var titleTopAnchor: NSLayoutConstraint?
    private var titleTopAnchorWithDescr: NSLayoutConstraint?
    
    var collection: Unsplash.Collection? {
        didSet {
            guard collection != nil else { return }
            guard let url = self.collection!.cover_photo?.urls.regular else { return }
            
            setupUI()
            
            self.title.text = collection!.title.replacingOccurrences(of: "Trend:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            self.descr.text = collection!.description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "No description provided."
            self.fullDescr.text = collection!.description?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Nuke.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.2)), into: self.previewImage, progress: nil) { (_, _) in
                self.setupTitle()
                self.setupDescription()
                
                if self.collection?.description != nil {
                    self.setupFullDescr()
                    
                    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.toggleDetail))
                    self.addGestureRecognizer(longPress)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    /*
     * ------------------------
     * MARK: - UI
     * ------------------------
     */
    private func setupUI() {
        layer.cornerRadius = 5
        layer.masksToBounds = false // true
        
        contentView.layer.cornerRadius = layer.cornerRadius
        contentView.layer.masksToBounds = true
        
        layoutIfNeeded()

        layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 5
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.contentsScale = UIScreen.main.scale
        
        
        //        layer.shouldRasterize = true // NO
        
        setupPreviewImage()
        setupOverlay()
    }
    
    private func setupDetailButton() {
        detailButton.backgroundColor = .white
        detailButton.layer.cornerRadius = 7.5
        
        contentView.addSubview(detailButton)
        contentView.bringSubviewToFront(detailButton)
        
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            detailButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            detailButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            detailButton.heightAnchor.constraint(equalToConstant: 15),
            detailButton.widthAnchor.constraint(equalToConstant: 15)
        ])
        
        
        detailButton.addTarget(self, action: #selector(self.toggleDetail), for: .touchUpInside)
    }
    
    private func setupPreviewImage() {
        contentView.addSubview(previewImage)
        
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
        
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: previewImage.topAnchor),
            view.bottomAnchor.constraint(equalTo: previewImage.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: previewImage.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: previewImage.leadingAnchor)
        ])
    }
    
    
    private func setupTitle(hasDescr: Bool = false) {
        contentView.addSubview(title)
        contentView.bringSubviewToFront(title)
        
        titleTopAnchor = title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        titleTopAnchorWithDescr = title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -55)
        
        title.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        title.text = title.text?.capitalized
        title.numberOfLines = 1
        title.textColor = .white
        
        title.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo:  self.leadingAnchor, constant: 15),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -55)
        ])
    }
    
    private func setupDescription() {
        contentView.addSubview(descr)
        contentView.bringSubviewToFront(descr)
        
        descr.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descr.numberOfLines = 2
        descr.textColor = .white
        
        descr.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            descr.leadingAnchor.constraint(equalTo:  title.leadingAnchor),
            descr.topAnchor.constraint(equalTo:   title.bottomAnchor, constant: 5),
            descr.trailingAnchor.constraint(equalTo: title.trailingAnchor, constant: -15),
        ])
    }
    
    private func setupFullDescr() {
        fullDescr.hide()
        
        contentView.addSubview(fullDescr)
        contentView.bringSubviewToFront(fullDescr)
        
        fullDescr.font = .systemFont(ofSize: 16, weight: .regular)
        fullDescr.numberOfLines = 0
        fullDescr.textColor = .white
        fullDescr.textAlignment = .natural
        
        fullDescr.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            fullDescr.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            fullDescr.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            fullDescr.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15)
        ])
    }
    
    /*
     * -----------------------
     * MARK: - Actions
     * ------------------------
     */
    
    @objc private func toggleDetail(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            if fullDescr.alpha == 0 {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.title.hide()
                    self.descr.hide()
                }) { (_) in
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                        self.fullDescr.show()
                    })
                }
            }
            break
        default:
            if fullDescr.alpha == 1 {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.fullDescr.hide()
                }) { (_) in
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                        self.title.show()
                        self.descr.show()
                    })
                }
            }
            break
        }
    }
    
}
