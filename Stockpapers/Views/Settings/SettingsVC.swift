//
//  SettingsViewController.swift
//  Wallpapers
//
//  Created by Federico Vitale on 12/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//


import Foundation
import UIKit
import MessageUI
import Firebase

struct Platform {
    static var isSimulator:Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}


class SettingsVC: DarkTableViewController {
    var isPurchasing: Bool = false
    
    var alertHelper: AlertHelper!
    let persistenceManager: PersistenceManager!
    
    let historyVC = HistoryVC(style: .grouped)
    var favouritesVC: FavouritesVC!
    var remoteConfig:RemoteConfig {
        let remote = RCFManager.shared
        remote.defaults = "RemoteConfigDefaults"
        return remote.remoteConfig
    }
    
    var theme: Theme {
        return Preferences.theme
    }
    
    var settings: [SettingItem] {
        
        let generals = [
            SettingItem("Show statusbar on preview", .switchable, id: .toggleStatusBarOnPreview),
            SettingItem("Parallax Effect", .switchable, id: .toggleParallax)
        ]
        
        let theme = [
            SettingItem("Accent Color", .view, .theming, id: .accentColor),
            SettingItem("Dark Theme", .switchable, .theming, id: .toggleDarkTheme),
        ]
        
        let imageSettings = [
            SettingItem("Image Size", .imageSettings, id: .imageSize),
            SettingItem("Close Gesture", .imageSettings, id: .closeGesture),
            SettingItem("Wallpapers Quality", .imageSettings, id: .pictureQuality),
            SettingItem("Hide UI: Gesture", .imageSettings, id: .hideGesture),
            SettingItem("High Quality Preview", .switchable, .imageSettings, id: .toggleHighQualityPreview)
        ]
        
        let data = [
            SettingItem("Downloads History", .data, id: .history),
            SettingItem("Favourites", .data, id: .favourites),
        ]
        
        let purchases = [
            SettingItem("Remove Watermarks", .bool, .purchases, id: .removeWatermarks, style: .accent),
            SettingItem("Restore Purchases", .bool, .purchases, id: .restorePurchases, style: .accent),
        ]
        
        let restore = [
            SettingItem("Restore Settings", .bool, .restore, id: .restoreSettings, style: .danger)
        ]
        
        let info = [
            SettingItem("Experimental Features", .info, type: .switchable, id: .experimentalFeatures, style: .danger),
            SettingItem("About StockPapers", .selectable, .info, id: .about, style: .default)
        ]
        
        
        return generals+theme+imageSettings+data+purchases+restore+info
    }
    

    

    // UI
    var loader: CustomLoader = CustomLoader()
    var waitingView: UIView = {
        let v = UIView();
        v.backgroundColor = Colors.brainGray.withAlpha(0.8)
        v.frame = UIScreen.main.bounds
        v.hide()
        v.layer.zPosition = 100000
        return v;
    }()
    
    // CoreData
    init(persistenceManager: PersistenceManager, style: UITableView.Style = .grouped) {
        self.persistenceManager = persistenceManager
        super.init(style: style)
        self.alertHelper = AlertHelper(vc: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    /*
     * ------------------
     * MARK: - Lifecycle
     * ------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        waitingView.addSubview(loader)
        loader.setupUI(in: waitingView)
        tableView.addSubview(waitingView)


        if title == nil {
            title = "Settings"
        }
        
        
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "\(SettingTableViewCell.self)")
        
        
        historyVC.items = persistenceManager.fetch(HistoryItem.self)
        historyVC.title = "History"
        
        favouritesVC = FavouritesVC(collectionViewLayout: self.setupFlowLayout())
        favouritesVC.items = persistenceManager.fetch(Favourite.self)
        favouritesVC.collectionView.backgroundColor = theme.color
        favouritesVC.title = "Favourites"
        
        
        // Observers
        NotificationCenter.default.addObserver(self, selector: #selector(updateStyle), name: .accentColorChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeWatermarks), name: .purchaseCompleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPurchaseError), name: .purchaseFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showRestoredMessage), name: .purchaseRestored, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hero.isEnabled = false
        self.navigationController?.hero.isEnabled = false
        
        tableView.reloadData() 
    }

    
    
    /*
     * ---------------------------
     * MARK: - TableView Delegate
     * ---------------------------
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return getNumberOfSections(items: settings)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSettings(for: section).count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let setting = getSettings(for: section).first else {
            return nil
        }
        
        switch setting.section {
        case .generals:
            return "generals"
        case .imageSettings:
            return "image settings"
        case .theming:
            return "theming"
        case .purchases:
            return "purchases"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let setting = getSettings(for: section).first else {
            return nil
        }
        
        switch setting.section {
        case .restore:
            return "Restore settings to their default values"
        default:
            return nil
        }
    }
    
    func getSetting(at indexPath: IndexPath) -> SettingItem {
        return settings.filter({ $0.section.rawValue == indexPath.section })[indexPath.row]
    }
    
    func getSettings(for section: Int) -> [SettingItem] {
        return settings.filter({ $0.section.rawValue == section })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "\(SettingTableViewCell.self)", for: indexPath) as! SettingTableViewCell
        
        let setting = getSetting(at: indexPath)
        cell.setting = setting
        
        switch setting.section {
        case .generals:
            if let id = setting.id, let sw = cell.accessoryView as? UISwitch {
                switch id {
                case .toggleStatusBarOnPreview:
                    sw.setOn(Preferences.showStatusBarOnPreview, animated: true)
                    sw.addTarget(self, action: #selector(toggleStatusBarOnPreview), for: .valueChanged)
                    sw.accessibilityIdentifier = "toggleStatusBarOnPreview"
                    break
                case .toggleParallax:
                    sw.setOn(Preferences.parallaxEffectOnImagePreview, animated: true)
                    sw.addTarget(self, action: #selector(toggleParallaxEffect), for: .valueChanged)
                    sw.accessibilityIdentifier = "toggleParallaxEffect"
                    break
                default:
                    break
                }
            }
            
            return cell
        case .theming:
            if let id = setting.id, let sw = cell.accessoryView as? UISwitch {
                switch id {
                case .toggleDarkTheme:
                    sw.setOn(Preferences.theme == .dark, animated: true)
                    sw.addTarget(self, action: #selector(toggleDarkTheme), for: .valueChanged)
                    sw.accessibilityIdentifier = "toggleDarkTheme"
                    break
                case .accentColor:
                    cell.accessibilityIdentifier = "accentColor"
                    break
                default:
                    break
                }
            }
            
            break
        case .imageSettings:
            if let id = setting.id {
                switch id {
                case .imageSize:
                    let text = (Preferences.cropImages ? "Screen Size" : "Original Size")
                    cell.detailTextLabel?.text = text
                    break
                case .closeGesture:
                    var label: String
                    
                    switch Preferences.closeFullScreenVCGestureSize {
                    case .short:
                        label = "Short"
                        break
                    case .medium:
                        label = "Medium"
                        break
                    case .long:
                        label = "Long"
                        break
                    }
                    
                    cell.detailTextLabel?.text = label
                    break
                case .pictureQuality:
                    cell.detailTextLabel?.text = Preferences.pictureQuality.rawValue.capitalized
                    break
                case .hideGesture:
                    cell.detailTextLabel?.text = Preferences.hideGesture.capitalized.split(separator: "-").joined(separator: " ")
                    break
                case .toggleHighQualityPreview:
                    if let sw = cell.accessoryView as? UISwitch {
                        sw.setOn(Preferences.highQualityPreview, animated: true)
                        sw.addTarget(self, action: #selector(toggleHighQualityPreview), for: .valueChanged)
                        sw.accessibilityIdentifier = "toggleHQPreview"
                    }
                    break
                default:
                    break
                }
            }
            return cell
        case .purchases:
            if let id = setting.id {
                switch id {
                case .restorePurchases:
                    cell.accessibilityIdentifier = "restorePurchases"
                    break
                case .removeWatermarks:
                    cell.isEnabled = !Preferences.keychain.watermarksRemoved
                    cell.accessibilityIdentifier = "removeWatermarks"
                    break
                default:
                    break
                }
            }
            
            break
        case .info:
            if let id = setting.id {
                switch id {
                case .unsplashLogin:
                    cell.isEnabled = Preferences.keychain.bearer == nil
                    cell.accessibilityIdentifier = "unsplashLogin"
                    break
                case .experimentalFeatures:
                    if let sw = cell.accessoryView as? UISwitch {
                        sw.setOn(Preferences.experimentalFeaturesEnabled, animated: true)
                        sw.addTarget(self, action: #selector(toggleExperimentalFeatures), for: .valueChanged)
                        sw.accessibilityIdentifier = "toggleExperimentalFeatures"
                    }
                default:
                    break
                }
            }
            break
        default:
            break
        }

        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let setting = getSetting(at: indexPath)
        let vc = SettingsDetailChoose(style: .grouped)
        
        print(setting.title)
        
        if setting.type == .switchable || setting.id == nil {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! SettingTableViewCell
        if cell.isEnabled == false {
            return
        }
        
        
        switch setting.id! {
        case .favourites:
            navigationController?.pushViewController(favouritesVC, animated: true)
            break
        case .history:
            navigationController?.pushViewController(historyVC, animated: true)
            return
        case .removeWatermarks:
            if self.isPurchasing == false && Preferences.keychain.watermarksRemoved == false {
                Analytics.logEvent("removeWatermarks", parameters: nil)

                UIView.animate(withDuration: 0.25) {
                    self.loader.start()
                    self.waitingView.show()
                }

                self.isPurchasing = true
                IAPService.shared.purchaseProduct(product: .removeWatermark)
            }
            return
        case .restorePurchases:
            IAPService.shared.restorePurchases()
            return
        case .restoreSettings:
            
            // warn the user before continue
            let warn = DarkAlertController(title: "Are you sure?", message: "This action is not reversible!", preferredStyle: .alert)
            
            warn.addAction(UIAlertAction(title: "Yep! I'm pretty sure!", style: .default, handler: { _ in
                self.restoreDefaults()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }))
            
            warn.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }))

            present(warn, animated: true)
            return
        case .unsplashLogin:
            Analytics.logEvent("unsplash_login", parameters: nil)
            
            let alert = DarkAlertController(title: "⚠️", message: "Unsplash is not yet integrated, however you can login with your Unsplash account and see the differences once implementation will be done.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Maybe later", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Let's Go!", style: .default, handler: { (_) in
                let u = URL(string: "https://unsplash.com/oauth/authorize?client_id=\(Preferences.keychain.apiKeys.access_key)&redirect_uri=stockpapers://callback&response_type=code&scope=\(["public", "read_user", "write_user", "read_collections", "write_collections", "write_likes", "write_followers"].joined(separator: "+"))")
                u?.open(completion: { (_) in
                    Analytics.logEvent("unsplash_opened", parameters: nil)
                })
            }))

            present(alert, animated: true)
            return
        case .about:
            Analytics.logEvent("info_vc", parameters: nil)
            navigationController?.pushViewController(InfoVC(style: .grouped), animated: true)
            return
        default:
            vc.setting = setting
            navigationController?.pushViewController(vc, animated: true)
            return
        }
    }
    
    
    /*
     * -----------------------
     * MARK: - Custom Utility
     * -----------------------
     */
    @objc private func updateStyle() {
        let theme: Theme = Preferences.theme

        navigationController?.setNavigationBarHidden(false, animated: true)

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.navigationController?.navigationBar.tintColor = theme.accentColor
            self.navigationItem.rightBarButtonItem?.tintColor  = theme.accentColor
            self.navigationItem.leftBarButtonItem?.tintColor   = theme.accentColor
        })

        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barStyle = theme.navigationBarStyle
        tableView.backgroundColor = theme.color
        view.backgroundColor = theme.color

        tableView.reloadSections(IndexSet(arrayLiteral: 0, 1, 2, 4, 6), with: .fade)
    }
    
    private func restoreDefaults() {
        Preferences.restoreDefaults(restoreFirstRun: false)
        
        let statusbarCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        let parallaxCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        let darkThemeCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
        let hqCell = tableView.cellForRow(at: IndexPath(row: 4, section: 1))
        
        (statusbarCell?.accessoryView as? UISwitch)?.setOn(Preferences.showStatusBarOnPreview, animated: true)
        (parallaxCell?.accessoryView as? UISwitch)?.setOn(Preferences.parallaxEffectOnImagePreview, animated: true)
        (darkThemeCell?.accessoryView as? UISwitch)?.setOn(Preferences.theme == .dark, animated: true)
        (hqCell?.accessoryView as? UISwitch)?.setOn(Preferences.highQualityPreview, animated: true)
        
        updateStyle()
    }
    
    private func setupFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 35
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 35, left: 35, bottom: 35, right: 35)
        
        return flowLayout
    }
}


/*
 * -----------------
 * MARK: - Handlers
 * -----------------
 */
extension SettingsVC {
    @objc func toggleHighQualityPreview(_ sender: UISwitch) {
        Preferences.highQualityPreview = sender.isOn
    }
    
    @objc func toggleExperimentalFeatures(_ sender: UISwitch) {
        if sender.isOn {
            self.alertHelper.presentAlert(title: "Warning!", message: "These features are still under heavy development.", buttonText: "Let's try them!", completion: { (_) in
                
                self.showBigToast(title: "Alert!", message: "Experimental Features \(sender.isOn ? "Enabled" : "Disabled")")
                
                Preferences.experimentalFeaturesEnabled = sender.isOn
            }) { _ in
                sender.setOn(false, animated: true)
            }
        } else {
            Preferences.experimentalFeaturesEnabled = sender.isOn
        }
    }
    
    @objc func toggleStatusBarOnPreview(_ sender: UISwitch) {
        Preferences.showStatusBarOnPreview = sender.isOn
    }
    
    @objc func toggleParallaxEffect(_ sender: UISwitch) {
        Preferences.parallaxEffectOnImagePreview = sender.isOn
    }
    
    @objc func toggleDarkTheme(_ sender: UISwitch) {
        Preferences.theme = sender.isOn ? .dark : .light
        updateAllStyles()
//        tableView.reloadData()
    }
    
    @objc func removeWatermarks() {
        self.isPurchasing = false
        
        Preferences.keychain.watermarksRemoved = true
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        let alert = DarkAlertController(title: "Thank you!", message: "Enjoy the full experience!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Hooray 🎉", image: nil))
        
        UIView.animate(withDuration: 0.25) {
            self.loader.stop(text: "Purchase completed", completion: {
                self.waitingView.hide()
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 3)], with: .fade)
                self.present(alert, animated: true)
            })
        }
    }
    
    
    @objc func showRestoredMessage(_ notification: Notification) {
        self.isPurchasing = false
        
        guard let identifier = notification.object as? String else {
            return
        }
        
        switch identifier {
        case IAPProduct.removeWatermark.rawValue:
            Preferences.keychain.watermarksRemoved = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            break
        default:
            print("Unknown pack: \(identifier)")
            break
        }
        
        alertHelper.presentOKAlert(title: "Hooray!", message: "Your purchases have been restored.", completion: { _ in
            UIView.animate(withDuration: 0.25) {
                self.loader.stop()
                self.waitingView.hide()
            }
        })
    }
    
    @objc func showPurchaseError(_ notification: Notification) {
        self.isPurchasing = false
        print("- Settings : PURCHASE ERROR")
        
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        alertHelper.presentOKAlert(title: "🥺 Purchase Error", message: "There was an error with your purchase. Please try again", completion: { _ in
            UIView.animate(withDuration: 0.25) {
                self.loader.stop()
                self.waitingView.hide()
            }
        })
    }
}


/*
 * -----------------------
 * MARK: - Navigation
 * ------------------------
 */
extension SettingsVC: UIGestureRecognizerDelegate {
    private func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController!.viewControllers.count > 1 {
            return true
        }
        
        return false
    }
}
