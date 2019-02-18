//
//  RCFManager.swift
//  Stockpapers
//
//  Created by Federico Vitale on 11/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import Firebase
import Device

/*
 * ------------------------------
 * MARK: - Remote Config Manager
 * ------------------------------
 */
class RCFManager {
    static let shared = RCFManager(plist: nil)
    
    /// remote config object
    public var remoteConfig: RemoteConfig!
    
    /// set defaults from plist file
    public var defaults: String? = nil {
        didSet {
            remoteConfig.setDefaults(fromPlist: defaults)
        }
    }
    
    
    
    /// make sure to don't do typos while writing keys
    enum RemoteKey:String {
        case collections = "unsplash_collections"
        case apiKeys = "unsplash"
        
        case show_remote_message = "show_remote_message"
        case remote_message = "remote_message"
        case display_darkmode = "display_darkmode"
    }
    
    init(plist defaultPlist: String?) {
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.setDefaults(fromPlist: defaultPlist)
        remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: Constants.debug)
    }
    
    /// fetch remote config
    func fetchRemoteConfig(
        onSuccess: @escaping () -> Void,
        onError: @escaping (_ error: Error?, _ message: String?) -> Void
    ) -> Void {
        let expiration = remoteConfig.configSettings.isDeveloperModeEnabled ? 0 : 3600;
        
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expiration)) { (status:RemoteConfigFetchStatus, error) in
            if let error = error {
                onError(error, nil)
                return
            }
            
            if status == .success {
                self.remoteConfig.activateFetched()
                onSuccess()
            } else if status == .failure {
                onError(nil, "No error available")
            }
        }
    }
    
    
    func bool(forKey key: RemoteKey) -> Bool {
        return remoteConfig[key.rawValue].boolValue
    }
    
    func string(forKey key: RemoteKey) -> String {
        return remoteConfig[key.rawValue].stringValue ?? ""
    }
    
    func data(forKey key: RemoteKey) -> Data {
        return remoteConfig[key.rawValue].dataValue
    }
    
    func number(forKey key: RemoteKey) -> NSNumber {
        guard let numberValue = remoteConfig[key.rawValue].numberValue else {
            return NSNumber(value: 0.0)
        }
        
        return numberValue
    }
    
    func double(forKey key: RemoteKey) -> Double {
        guard let numberValue = remoteConfig[key.rawValue].numberValue else { return 0.0 }
        return numberValue.doubleValue
    }
    
    func float(forKey key: RemoteKey) -> Float {
        guard let numberValue = remoteConfig[key.rawValue].numberValue else { return 0.0 }
        return numberValue.floatValue
    }
    

}

