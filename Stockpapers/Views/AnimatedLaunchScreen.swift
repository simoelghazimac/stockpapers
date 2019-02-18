//
//  AnimatedLaunchScreen.swift
//  Stockpapers
//
//  Created by Federico Vitale on 04/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import Firebase

var apiClient: UnsplashAPIClient!

public enum ShortcutDestination {
    case favorites
    case history
    case preferences
    case home
}


class AnimatedLaunchScreen: UIViewController {
    private var hasInternetConnection: Bool = true
    private var constraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    private var setupQueue:DispatchGroup = DispatchGroup()
    private var albumsList: [RemoteCollection] = [RemoteCollection]()
    
    // public stuff
    var goTo: ShortcutDestination = .home
    
    /*
     * ----------------------------
     * MARK: - Remote Config setup
     * ----------------------------
     */
    private let remoteConfigManager = RCFManager.shared
    private var remoteConfig: RemoteConfig {
        // setup RemoteConfig settings
        remoteConfigManager.defaults = "RemoteConfigDefaults"
        return remoteConfigManager.remoteConfig
    }
    
    /// Animated columns
    // TODO: Fix layout on small screens
    private let columns: [UIImage?] = [
        UIImage(named: "Columns/C1"),
        UIImage(named: "Columns/C2"),
        UIImage(named: "Columns/C3"),
        UIImage(named: "Columns/C4")
    ]
    
    // Coords of each column
    // x, y
    private let coords = [
        [9.0, 31.0],
        [103.0, 74.0],
        [199.0, 60.0],
        [292.0, 93.0],
    ]
    
    // wrap all the columns with a UIStackView
    private let stack: UIStackView = {
        let s = UIStackView()
        
        s.axis = .horizontal
        s.alignment = .fill
        
        return s
    }()
    
    
    
    /*
     * -----------------------
     * MARK: - Lifecycle
     * ------------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "LoadingVC"
        
        // Observers
        // Make sure to remove all observers
        // when the user leave this view
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(self.tryAgain),
                name: .networkReachable,
                object: nil
        )
        
        // UI Setup
        view.backgroundColor = Colors.brainGray
        navigationController?.setNavigationBarHidden(true, animated: true)
        setupStack()
        
        // HERO Setup
        hero.isEnabled = true
        hero.modalAnimationType = .zoom
        
        
        /*
         * ------------------------------------------
         * MARK: - Connection with backend services
         * ------------------------------------------
         */
        
        // check internet connection
        checkInternetConnection()
        
        // retrive IAP products from apple
        IAPService.shared.getProducts()
        
        // Increment openCount
        Preferences.openCount += 1
        
        // getting apikeys from the server
        setupAPIKEYS()
        
        // get the list of the collections
        setupCollections()
        
        // do stuff on first run
        onFirstRun()
        
        // go to the app
        setupQueue.notify(queue: .main) {
            print("Should present")
            
            // one last check, the api key
            // this should never trigger if
            // the RCFManager has defaults
            // ---
            // Make sure to provide backup api keys,
            // even if not in production
            // ---
            if apiClient == nil {
                print("NO API KEYS")
                let actions = DarkAlertController(title: "API Error!", message: "Error retriving apikeys", preferredStyle: .actionSheet)
                actions.addAction(UIAlertAction(title: "Report", style: .default, image: nil, handler: { _ in
                    Analytics.logEvent("no_apikeys", parameters: nil)
                }))
                
                actions.addAction(UIAlertAction(title: "Cancel", style: .cancel, image: nil, handler: nil))
                
                self.present(actions, animated: true)
                return
            }
            
            print("Presenting...")
            self.animate(onComplete: { _ in
                
                print("Run baby run!")
                self.goHome()
            })
        }
    }
    
    // Remove observers
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .networkReachable, object: nil)
        
        // do stuff before the user leaves the screen
    }
    
    
    
    /*
     * ---------------------------
     * MARK: - Style Preferences
     * ---------------------------
     */
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    /*
     * -----------------------
     * MARK: - Setup Steps
     * ------------------------
     */
    func setupCollections() {
        setupQueue.enter()
        print("Getting collections")
        fetchRemoteConfig(remote: remoteConfig, onSuccess: {
            let data: Data = self.remoteConfigManager.data(forKey: .collections)
            print("Parsing data...")
            
            do {
                
                self.albumsList = try JSONDecoder().decode([RemoteCollection].self, from: data)
                print("Leaving collections")
                self.setupQueue.leave()
                
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }) { (error, message) in
            guard let error = error else {
                print(message!)
                return
            }
            
            print(error.localizedDescription)
        }
    }
    
    func onFirstRun() {
        setupQueue.enter()

        if Preferences.firstRunGone == false {
            Preferences.restoreDefaults()
        }
        
        setupQueue.leave()
    }
    
    func checkInternetConnection() {
        setupQueue.enter()
        print("Checking the connection...")
        
        NetworkManager.shared.isUnreachable { _ in
            self.hasInternetConnection = false
        }

        NetworkManager.shared.isReachable { _ in
            self.hasInternetConnection = true
        }
        
        if self.hasInternetConnection == false {
            let alert = DarkAlertController(title: "Connection Error", message: "Whoops! It's seems that you're offline...", preferredStyle: .alert);
            alert.addAction(title: "Ok", style: .default, handler: {_ in
                self.tryAgain()
            })
            
            alert.titleAttributes = [
                StringAttribute(key: .foregroundColor, value: UIColor.red),
                StringAttribute(key: .font, value: UIFont.systemFont(ofSize: 20, weight: .bold))
            ]
            
            self.present(alert, animated: true)
            return
        }
        
        print("Connection status: online")
        self.setupQueue.leave()
    }
    
    func setupAPIKEYS() {
        setupQueue.enter()
        print("Getting API Keys")
        
        fetchRemoteConfig(remote: remoteConfig, onSuccess: {
            let data = self.remoteConfig.configValue(forKey: "unsplash").dataValue
            
            do {
                let keys = try JSONDecoder().decode(APIResponse.self, from: data)
                
                Preferences.keychain.apiKeys = keys
                
                apiClient = UnsplashAPIClient(
                    client_id: keys.access_key,
                    client_secret: keys.secret_key
                )
                
                self.setupQueue.leave()
            } catch let error {
                let alert = DarkAlertController(
                    title: "Error",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Ok", image: nil))
                
                self.present(alert, animated: true)
                return
            }
        }) { (error, message) in
            let alert = DarkAlertController(
                title: "Error",
                message: error != nil ? error?.localizedDescription : message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Ok", image: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    func goHome() {
        var flowLayout: UICollectionViewFlowLayout {
            let layout = UICollectionViewFlowLayout()

            layout.itemSize = CGSize(width: abs(UIScreen.main.bounds.width - 35), height: 230)
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 35
            layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 35, right: 0)

            return layout
        }
        
        // home UICollectioViewController + Layout
        let home = HomeVC(persistenceManager: PersistenceManager.shared, layout: flowLayout)
        home.goToPage = goTo
        
        // prepare collections
        home.albumsList = self.albumsList
        
        // prepare animations
        home.hero.modalAnimationType = .zoom
        home.hero.isEnabled = true
        
        let navigationController = UINavigationController(rootViewController: home);
        
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barStyle = .blackTranslucent
        navigationController.navigationBar.barTintColor = Preferences.theme.darkerColor
        navigationController.setNavigationBarHidden(false, animated: true)
        
        navigationController.hero.isEnabled = true
        navigationController.hero.modalAnimationType = .zoom
                
        self.present(navigationController, animated: true, completion: nil)
    }

    func animate(onComplete: @escaping (_ isCompleted: Bool) -> ()) {
        let c1 = constraints[0]
        let c2 = constraints[1]
        let c3 = constraints[2]
        let c4 = constraints[3]
        
        c1.constant += 350
        c2.constant -= 400
        c3.constant += 350
        c4.constant -= 400
        
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }) { completed in
            
            onComplete(completed)
        }
    }
}


/*
 * -----------------------
 * MARK: - UI
 * ------------------------
 */
extension AnimatedLaunchScreen {
    fileprivate func setupStack() {
        for (index, column) in columns.enumerated() {
            let image = UIImageView(image: column);
            image.contentMode = .scaleAspectFill
            constraints.append(image.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: CGFloat(coords[index][1])))

            switch index {
            case 0:
                view.addSubview(image)
                image.setConstraints([
                    image.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
                    constraints[index]
                ])
                break
            case 1:
                view.addSubview(image)
                image.setConstraints([
                    image.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -50),
                    constraints[index]
                ])
                break
            case 2:
                view.addSubview(image)
                image.setConstraints([
                    image.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 50),
                    constraints[index]
                ])
                break
            case 3:
                view.addSubview(image)
                image.setConstraints([
                    image.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
                    constraints[index]
                ])
                break
            default:
                break
            }
        }
    }
}



/*
 * -----------------------
 * MARK: - Actions
 * ------------------------
 */
extension AnimatedLaunchScreen {
    @objc
    func tryAgain() {
        if hasInternetConnection == true {
            return
        }
        
        self.hasInternetConnection = true
        
        let c1 = constraints[0]
        let c2 = constraints[1]
        let c3 = constraints[2]
        let c4 = constraints[3]
        
        c1.constant = 0
        c2.constant = 0
        c3.constant = 0
        c4.constant = 0
        
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }) { completed in
            self.animate(onComplete: { _ in
                if self.hasInternetConnection == false {
                    let alert = DarkAlertController(title: "Connection Error", message: "No internet connection", preferredStyle: .alert)
                    alert.addAction(title: "Ok", style: .default, handler: { _ in
                        self.tryAgain()
                    })
                    
                    alert.titleAttributes = [
                        StringAttribute(key: .foregroundColor, value: UIColor.red),
                        StringAttribute(key: .font, value: UIFont.systemFont(ofSize: 20, weight: .bold))
                    ]
                    
                    self.present(alert, animated: true)
                    return
                }
                
                if apiClient != nil {
                    self.goHome()
                    return
                }
                
                print("NO API CLIENT")
            })
        }
    }
    
}
