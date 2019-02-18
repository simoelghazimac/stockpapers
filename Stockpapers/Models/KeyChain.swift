//
//  SafePreferences.swift
//  WallpapersPlus
//
//  Created by Federico Vitale on 20/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import Valet

struct APIResponse: Decodable {
    let access_key:String
    let secret_key:String
}

class KeyChainService {
    private enum Keys:String {
        case appIdentifier = "StockPapersService"
        case watermarksRemoved = "StockPapersWatermarksRemoved"
        case apikeys_accessKey = "StockPapersAccessKey"
        case apikeys_secretKey = "StockPapersSecretKey"
        case bearer = "StockPapersUnsplashBearerToken"
    }
    
    private let identifier = Valet.valet(with: Identifier(nonEmpty: Keys.appIdentifier.rawValue)!, accessibility: .whenUnlocked)
    
    static let shared = KeyChainService()
    
    var watermarksRemoved: Bool {
        set {
            self.identifier.set(string: "\(newValue)", forKey: Keys.watermarksRemoved.rawValue)
        }
        
        get {
            guard let data: String = self.identifier.string(forKey: Keys.watermarksRemoved.rawValue) else {
                return false
            }
            
            return Bool(data) ?? false
        }
    }
    
    var bearer: String? {
        set {
            identifier.set(string: newValue!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: Keys.bearer.rawValue)
        }
        
        get {
            return identifier.string(forKey: Keys.bearer.rawValue) ?? nil
        }
    }
    
    var apiKeys: APIResponse {
        set {
            self.identifier.set(string: newValue.access_key, forKey: Keys.apikeys_accessKey.rawValue)
            self.identifier.set(string: newValue.secret_key, forKey: Keys.apikeys_secretKey.rawValue)
        }
        
        get {
            let access_key: String = self.identifier.string(forKey: Keys.apikeys_accessKey.rawValue)!
            let secret_key: String = self.identifier.string(forKey: Keys.apikeys_secretKey.rawValue)!
            
            return APIResponse(access_key: access_key, secret_key: secret_key)
        }
    }
    
}
