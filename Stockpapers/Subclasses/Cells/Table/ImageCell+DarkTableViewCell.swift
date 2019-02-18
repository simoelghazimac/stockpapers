//
//  ImageCell+DarkTableViewCell.swift
//  Stockpapers
//
//  Created by Federico Vitale on 09/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import Hero
import Nuke


class ImageCell: DarkTableViewCell {
    var imageContainer: UIImageView = UIImageView()
    var titleLabel: UILabel = UILabel()
    
    var sideImage: UIImage? {
        didSet {
            self.imageContainer.image = sideImage
        }
    }
    
    var item: HistoryItem? {
        didSet {
            guard let item = item else { return }
            
            titleLabel.text = "\(item.id)"
            imageContainer.hero.id = item.id
            
            Nuke.loadImage(with: item.url, into: imageContainer)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        setupImageContainer()
        setupTitleLabel()
        setupStyle()
        
        setupSeparator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupTitleLabel() {
        let label = self.titleLabel;
        
        self.addSubview(label)
        
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.textColor = theme.textColor
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 35),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            label.leadingAnchor.constraint(equalTo: imageContainer.trailingAnchor, constant: 18),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func setupImageContainer() {
        self.addSubview(imageContainer)
        
        imageContainer.backgroundColor = Colors.brainGrayLight
        imageContainer.layer.cornerRadius = 5
        
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageContainer.widthAnchor.constraint(equalToConstant: 20),
            imageContainer.heightAnchor.constraint(equalToConstant: 20),
            imageContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            imageContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
