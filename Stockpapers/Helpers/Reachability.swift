//
//  Reachability.swift
//  Wallpapers
//
//  Created by Federico Vitale on 13/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import Reachability

class NetworkManager: NSObject {
    var reachability: Reachability!
    
    static let shared = NetworkManager()
    
    override init() {
        super.init()
        
        // Initialise reachability
        reachability = Reachability()!
        
        // Register an observer for the network status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.networkStatusChanged),
            name: .reachabilityChanged,
            object: reachability
        )
        
        do {
            // Start the network status notifier
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    
    @objc func networkStatusChanged(_ notification: Notification) {
        print("Network status changed.")
        
        self.isUnreachable { _ in
            NotificationCenter.default.post(name: .networkUnreachable, object: nil)
        }
        
        self.isReachable { _ in
            NotificationCenter.default.post(name: .networkReachable, object: nil)
        }
    }
    
    func stopNotifier() -> Void {
        do {
            // Stop the network status notifier
            try (self.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    
    // Network is reachable
    func isReachable(completed: @escaping (NetworkManager) -> Void) {
        if (self.reachability).connection != .none {
            completed(self)
        }
    }
    
    // Network is unreachable
    func isUnreachable(completed: @escaping (NetworkManager) -> Void) {
        if (self.reachability).connection == .none {
            completed(self)
        }
    }
    
    // Network is reachable via WWAN/Cellular
    func isReachableViaWWAN(completed: @escaping (NetworkManager) -> Void) {
        if (self.reachability).connection == .cellular {
            completed(self)
        }
    }
    
    // Network is reachable via WiFi
    func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        if (self.reachability).connection == .wifi {
            completed(self)
        }
    }
}

extension NSNotification.Name {
    public static var networkReachable: NSNotification.Name = Notification.Name(rawValue: "networkReachable")
    public static var networkUnreachable: NSNotification.Name = Notification.Name(rawValue: "networkUnreachable")
}
