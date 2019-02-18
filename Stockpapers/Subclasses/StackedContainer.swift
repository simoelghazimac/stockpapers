//
//  StackedContainer.swift
//  Wallpapers
//
//  Created by Federico Vitale on 19/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


class StackedContainer: UIView {
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    var descr: String? {
        didSet {
            self.descrLabel.text = descr
        }
    }
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
    
    var data: (title: String, descr: String)? {
        didSet {
            self.title = data?.title
            self.descr = data?.descr
        }
    }
    
    let titleLabel = UILabel()
    let descrLabel = UILabel()
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupComponents()
    }
    
    init(title: String?=nil, description: String?=nil, image: UIImage?=nil) {
        super.init(frame: .zero)
        
        self.title = title
        self.descr = description
        self.image = image
        
        setupComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSize(parent: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo:  parent.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            self.heightAnchor.constraint(equalToConstant: 85)
        ])
    }
    
    private func setupComponents() {
        
        if image != nil {
            setupImage()
        }

        // Style for texts
        setupTitle()
        setupDescr()

        // Create a stack view for texts
        setupStack()
    }
    
    private func setupImage() {
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.image = image
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.leadingAnchor, constant: 85),
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
    
    private func setupStack() {
        let container = UIStackView(arrangedSubviews: [titleLabel, descrLabel])
        container.axis = .vertical
        container.alignment = .fill
        container.distribution = .fillEqually
        
        container.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            container.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupTitle(_ withConstraints: Bool = false) {
        titleLabel.text = title ?? ""
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if withConstraints {
            self.addSubview(titleLabel)

            if image != nil {
                NSLayoutConstraint.activate([
                    titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 0),
                    titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
                    titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
                ])
            } else {
                NSLayoutConstraint.activate([
                    titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                    titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                    titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
                ])
            }
        }
    }
    
    private func setupDescr(_ withConstraints: Bool = false) {
        descrLabel.text = descr ?? ""
        descrLabel.numberOfLines = 4
        descrLabel.textAlignment = .justified
        descrLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descrLabel.textColor = .white
        
        descrLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if withConstraints {
            self.addSubview(descrLabel)
            
            NSLayoutConstraint.activate([
                descrLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
                descrLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                descrLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
            ])
        }
    }
}

