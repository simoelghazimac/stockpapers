//
//  Date+Extension.swift
//  Stockpapers
//
//  Created by Federico Vitale on 13/01/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation


extension Date {
    func getDate(style: DateFormatter.Style = .short) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            
            formatter.dateStyle = style
            formatter.timeStyle = .none
            
            formatter.locale = Locale(identifier: Locale.current.languageCode ?? "en_US")
            
            return formatter
        }()
        
        return dateFormatter.string(from: self)
    }
    
    func getTime(style: DateFormatter.Style = .short) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            
            formatter.dateStyle = .none
            formatter.timeStyle = style
            
            formatter.locale = Locale(identifier: Locale.current.languageCode ?? "en_US")
            
            return formatter
        }()
        
        return dateFormatter.string(from: self)
    }
    
    func getDateAndTime(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            
            formatter.dateStyle = dateStyle
            formatter.timeStyle = timeStyle
            
            formatter.locale = Locale(identifier: Locale.current.languageCode ?? "en_US")
            
            return formatter
        }()
        
        return dateFormatter.string(from: self)
    }
}
