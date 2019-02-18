//
//  Constants.swift
//  Stockpapers
//
//  Created by Federico Vitale on 16/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import Device

struct Constants {
    static var didEnterBackground: Bool = false
    static var didLogin: Bool = false
    static var debug: Bool {
        return Device.version() == .simulator
    }
}
