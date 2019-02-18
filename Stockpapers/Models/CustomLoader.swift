//
//  CustomLoader.swift
//  Stockpapers
//
//  Created by Federico Vitale on 22/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit


/*
 * -----------------------
 * MARK: - Custom Loader
 * ------------------------
 */
class CustomLoader: UIView {
    let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
    let label: UILabel = UILabel()
    
    var heightConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!
    
    init() {
        super.init(frame: .zero)
        self.isHidden = true
        
        self.hide()
        
        self.backgroundColor = UIColor.black.withAlpha(0.8)
        self.layer.cornerRadius = 5
        
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: 50)
        self.widthConstraint  = self.widthAnchor.constraint(equalToConstant: 50)
        
        self.setupLoader()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
     * -----------------------
     * MARK: - Methods
     * ------------------------
     */
    func start(text: String?=nil) {
        if text != nil {
            self.setupLabel(withText: text)
            self.isHidden = false
            self.widthConstraint.constant = self.label.bounds.width + 24.0
            self.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.1, delay: 0.2, options: .curveEaseInOut, animations: {
                self.label.show()
                self.show()
            })
            
            return
        }
        
        label.hide()
        indicator.startAnimating()
        
        self.isHidden = false
        UIView.animate(withDuration: 0.1, delay: 0.2, options: .curveEaseInOut, animations: {
            self.show()
        })
    }
    
    func stop(text: String? = nil, completion: (() -> ())? = nil) {
        if text != nil && text?.isEmpty == false {
            self.indicator.stopAnimating()
            
            self.setupLabel(withText: text)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.widthConstraint.constant = self.label.bounds.width + 24.0
                self.layoutIfNeeded()
            }) { (_) in
                UIView.animate(withDuration: 0.25, animations: {
                    self.label.show()
                }) { _ in
                    delay(.microseconds(800), completion: {
                        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                            self.hide()
                        }) { _ in
                            self.isHidden = true
                            completion?()
                        }
                    })
                }
            }
            
            return
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.5, options: .curveEaseInOut, animations: {
            self.hide()
        }) { _ in
            self.indicator.stopAnimating()
            self.isHidden = true
            
            completion?()
        }
    }
    
    
    // UI Stuff
    func setupUI(in view: UIView) {
        if self.translatesAutoresizingMaskIntoConstraints {
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            self.widthConstraint,
            self.heightConstraint,
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    
    /*
     * -----------------------
     * MARK: - UI Setup
     * ------------------------
     */
    private func setupLabel(withText text: String?=nil) {
        label.hide()
        label.textColor = self.backgroundColor?.isLight() ?? true ? .black : .white
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.text = text
        label.textAlignment = .center
        
        label.sizeToFit()
        
        
        self.addSubview(label)
        
        // constraints
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func setupLoader() {
        indicator.hidesWhenStopped = true
        
        self.addSubview(indicator)
        
        // constraints
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
}




