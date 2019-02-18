//
//  UnlockPremiumCell.swift
//  Wallpapers
//
//  Created by Federico Vitale on 19/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class UnlockPremiumCell: UICollectionViewCell {
    let collections = [CollectionRow]()
    
    
    var title: UILabel = {
        let label = UILabel()
        
        label.text = "Unlock More"
        label.font = .systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .white
        
        return label
    }()
    
    var subTitle: UILabel = {
        let label = UILabel()
        var text: String = ""
        
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        
        return label
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
        self.backgroundColor = Preferences.theme.color
        
        setupBackground()
        setupTitle()
        setupSubTitle()
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
    
    func setupSubTitle() {
        self.addSubview(subTitle)
        
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subTitle.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            subTitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20)
        ])
    }
}


