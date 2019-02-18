//
//  OnBoardingViewController.swift
//  Wallpapers
//
//  Created by Federico Vitale on 19/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

final class UpgradeUserVC: UIViewController {
    public var data: [OnboardingData] = [OnboardingData]()
    public var button: UIButton = UIButton()
    public var closeButton: UIButton = UIButton()
    
    
    public var showCloseBtn:Bool = true
    
    private var containers: [StackedContainer] = [StackedContainer]()
    private let stackedView: UIStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ThemeManager.shared.currentTheme.mainColor.color
        
        self.setupStackedView()
        
        data.forEach { (item: OnboardingData) in
            let container = StackedContainer(title: item.title, description: item.description, image: item.image);
            stackedView.addArrangedSubview(container)
            container.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                container.leadingAnchor.constraint(equalTo: stackedView.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: stackedView.trailingAnchor),
                container.heightAnchor.constraint(equalToConstant: 85)
            ])
        }
        
        
        self.setupButton()
        self.setupCloseBtn()
        
        
    }
    
    private func setupButton() {
        button.setTitleColor(.white, for: .normal)
        
        button.backgroundColor = Preferences.themeColor
        button.layer.cornerRadius = 5
        button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Upgrade to \(Preferences.keychain.userType == 0 ? "Plus" : "Pro")", for: .normal)
        button.addTarget(self, action: #selector(self.oneTimePurchase), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    @objc func oneTimePurchase() {
        self.hero.dismissViewController {
            if Preferences.keychain.userType == 0 {
                IAPService.shared.purchaseProduct(product: .plusPack)
            } else if Preferences.keychain.userType == 1 {
                IAPService.shared.purchaseProduct(product: .proPack)
            }
        }
    }
    
    private func setupCloseBtn() {
        closeButton.setImage(Icons.close.light, for: .normal)
        
        if !showCloseBtn {
            closeButton.hide()
        }

        closeButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        
        view.addSubview(closeButton)
        view.bringSubviewToFront(closeButton)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
        ])
    }
    
    
    private func setupStackedView() {
        stackedView.spacing = 25.0
        stackedView.distribution = .equalSpacing
        stackedView.axis = .vertical
        stackedView.center = view.center
        
        view.addSubview(stackedView)
        
        stackedView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackedView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            stackedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35)
        ])
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
     
     /*
     * -----------------------
     * MARK: - Lifecycle
     * ------------------------
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @objc func goBack() {
        self.hero.dismissViewController()
    }
}
