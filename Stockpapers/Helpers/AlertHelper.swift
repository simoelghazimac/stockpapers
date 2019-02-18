//
//  AlertHelper.swift
//  Stockpapers
//
//  Created by Federico Vitale on 20/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class AlertHelper {
    let vc: UIViewController?
    
    init(vc: UIViewController) {
        self.vc = vc
    }
    
    func presentOKAlert(title:String?, message: String?, buttonText:String = "Ok", completion: ((UIAlertAction) -> Void)?=nil) {
        guard let vc = self.vc else { return }
        
        let alert = DarkAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: buttonText, style: .default, handler: completion))
        
        vc.present(alert, animated: true)
    }
    
    func presentAlert(title:String?, message: String?, buttonText:String = "Ok", completion: ((UIAlertAction) -> Void)?=nil, onAbort: ((UIAlertAction) -> Void)? = nil) {
        guard let vc = self.vc else { return }
        
        let alert = DarkAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: onAbort))
        alert.addAction(UIAlertAction(title: buttonText, style: .default, handler: completion))
        
        vc.present(alert, animated: true)
    }
}

