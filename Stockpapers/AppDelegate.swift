//
//  AppDelegate.swift
//  Stockpapers
//
//  Created by Federico Vitale on 11/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import UIKit
import CoreData
import Hero
import Firebase

//let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
//
//if Preferences.appVersion != currentAppVersion {
//    Preferences.appVersion = currentAppVersion
//}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let filePath = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        
        let home = AnimatedLaunchScreen()
        
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            print(shortcutItem.type)
            
            switch shortcutItem.type {
            case "OpenFavorites":
                home.goTo = .favorites
                break
            case "OpenHistory":
                home.goTo = .history
                break
            default:
                home.goTo = .home
                break
            }
    
        }
        
        window?.rootViewController = home;
        window?.makeKeyAndVisible()
        
        window?.backgroundColor = Colors.brainGray
        
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print(shortcutItem.type)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        print("DID WILL BE INACVIE")
        
        Constants.didEnterBackground = true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("DID ENTER BACKGROUND")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("DID ENTER FOREGROUND")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("DID BECOME ACTIVE")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sendingAppID = options[.sourceApplication] ?? "Unknwon"
        
        print(sendingAppID)
        
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host, let params = components.queryItems else {
            print("NO COMPONENTS")
            return false
        }
        
        Analytics.logEvent("opened_by", parameters: ["AppID" : sendingAppID as! NSObject])
        
        print( components )
        
        switch host {
        case "callback":
            if let codeObj = params.first(where: { $0.name == "code" }), let code = codeObj.value {
                
                struct AuthResponse:Decodable {
                    let access_token:String
                    let created_at:String
                    let scope: String
                }
                
                // GET THE TOKEN
                let payload: [String: String] = [
                    "client_id": Preferences.keychain.apiKeys.access_key,
                    "client_secret": Preferences.keychain.apiKeys.secret_key,
                    "redirect_uri": "stockpapers%3A%2F%2Fcallback",
                    "code": code,
                    "grant_type": "authorization_code"
                ]
                
                Network.fetch(url: "https://unsplash.com/oauth/token", method: .POST, payload: payload, headers: nil) { (response) in
                    switch response {
                    case .success(let data):
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                            print(json)
                        } catch let error {
                            print(error.localizedDescription)
                        }
                        break
                    case .failure(let message, let statusCode):
                        print(message ?? "", statusCode ?? 0)
                        break
                    }
                }
                return true
            }
            break
        default:
            break
        }
        
        return false
    }
}
