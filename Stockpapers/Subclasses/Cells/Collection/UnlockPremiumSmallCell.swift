//
//  UnlockPremiumCell.swift
//  Wallpapers
//
//  Created by Federico Vitale on 19/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class UnlockPremiumSmallCell: UICollectionViewCell {
    let collections = [CollectionRow]()
    
    
    let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark)))
    
    var title: UILabel = {
        let label = UILabel()
        
        label.text = "\(Preferences.keychain.userType == 0 ? "PLUS" : "PRO")"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        
        return label
    }()
    
    var darkView: UIView  = {
        let view = UIView()
        
        view.backgroundColor = UIColor.black.withAlpha(0.8)
        
        return view
    }()
    
    
    var background: UIImageView = UIImageView()
    
    /*
     * -----------------------
     * MARK: - Init
     * ------------------------
     */
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupUI()
    }
    
    
    /*
     * -----------------------
     * MARK: - UI
     * ------------------------
     */
    func setupUI() {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.backgroundColor = .clear
        
        setupBackground()
        setupVibrancyView()
        setupTitle()
    }
    
    func setupDarkView() {
        self.addSubview(darkView)
        
        darkView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            darkView.topAnchor.constraint(equalTo: self.topAnchor),
            darkView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            darkView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            darkView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    func setupVibrancyView() {
        let blurry = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurry.contentView.addSubview(vibrancyView)
        
        self.addSubview(blurry)
        
        blurry.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blurry.topAnchor.constraint(equalTo: self.topAnchor),
            blurry.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            blurry.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurry.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    func setupBackground() {
        self.addSubview(background)
        
        background.translatesAutoresizingMaskIntoConstraints = false
        background.image = UIImage(named: "UnlockPremiumBig")
        background.layer.cornerRadius = 5
        background.layer.masksToBounds = true
        background.contentMode = .scaleAspectFill
            
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: self.topAnchor),
            background.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            background.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    func setupTitle() {
        self.addSubview(title)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
}


