//
//  URL+Extension.swift
//  Stockpapers
//
//  Created by Federico Vitale on 09/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

extension URL {
    init(string main: String, fallback secondary: String) {
        let url = URL(string: main)
        let fallback = URL(string: secondary)
        
        if UIApplication.shared.canOpenURL(url!) {
            self = url!
        } else {
            self = fallback!
        }
    }
    
    func withFallback(fallback str: String) -> URL! {
        let fallback = URL(string: str)!
        
        if UIApplication.shared.canOpenURL(self) {
            return self
        }
        
        return fallback
    }
    
    
    func makeGithubURL(user: String, repo: String) -> URL! {
        return URL(string: "grape://repo?=reponame=\(user)/\(repo)", fallback: "https://github.com/\(user)/\(repo)")
    }
    
    var canBeOpened: Bool {
        return UIApplication.shared.canOpenURL(self)
    }
    
    func open(options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:], completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(self, options: options, completionHandler: completion)
    }
    
    func safeOpen(options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:], completion: ((Bool) -> Void)?, onFail: @escaping (_ errorMessage: String) -> Void) {
        
        if self.canBeOpened {
            self.open(completion: completion)
            return
        }
        
        
        onFail("Can't open the URL")
    }
}
