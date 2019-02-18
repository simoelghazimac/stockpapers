//
//  Utils.swift
//  Wallpapers
//
//  Created by Federico Vitale on 12/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/*
 * -----------------------
 * MARK: - Icons
 * ------------------------
 */




struct Icon {
    struct WithStyle {
        struct Style {
            let dark: UIImage?
            let light: UIImage?
            
            init(icon iconName: String, style styleName:String) {
                self.dark = UIImage(named: "\(iconName)/\(styleName)/Dark")
                self.light = UIImage(named: "\(iconName)/\(styleName)/Light")
            }
        }
        
        let outline: Style
        let filled: Style
        
        init(name: String) {
            self.outline = Style(icon: name, style: "Outline")
            self.filled = Style(icon: name, style: "Filled")
        }
    }
    
    struct Themed {
        struct Dark {
            var alizarin: UIImage?
            var sunFlower: UIImage?
            var carrot: UIImage?
            var peterRiver: UIImage?
            var emerald: UIImage?
            var amethyst: UIImage?
            var sasquatchSocks: UIImage?
            var cloud: UIImage?
            var squeaky: UIImage?
            
            init(name: String) {
                self.alizarin = UIImage(named: "\(name)/Dark/Alzarin")
                self.sunFlower = UIImage(named: "\(name)/Dark/SunFlower")
                self.carrot = UIImage(named: "\(name)/Dark/Carrot")
                self.peterRiver = UIImage(named: "\(name)/Dark/PeterRiver")
                self.emerald = UIImage(named: "\(name)/Dark/Emerald")
                self.amethyst = UIImage(named: "\(name)/Dark/Amethyst")
                self.sasquatchSocks = UIImage(named: "\(name)/Dark/SasquatchSocks")
                self.cloud = UIImage(named: "\(name)/Dark/Cloud")
                self.squeaky = UIImage(named: "\(name)/Dark/Squeaky")
            }
        }
        
        struct Light {
            var alizarin: UIImage?
            var sunFlower: UIImage?
            var carrot: UIImage?
            var peterRiver: UIImage?
            var emerald: UIImage?
            var amethyst: UIImage?
            var sasquatchSocks: UIImage?
            var cloud: UIImage?
            var squeaky: UIImage?
            
            init(name: String) {
                self.alizarin = UIImage(named: "\(name)/Light/Alzarin")
                self.sunFlower = UIImage(named: "\(name)/Light/SunFlower")
                self.carrot = UIImage(named: "\(name)/Light/Carrot")
                self.peterRiver = UIImage(named: "\(name)/Light/PeterRiver")
                self.emerald = UIImage(named: "\(name)/Light/Emerald")
                self.amethyst = UIImage(named: "\(name)/Light/Amethyst")
                self.sasquatchSocks = UIImage(named: "\(name)/Light/SasquatchSocks")
                self.cloud = UIImage(named: "\(name)/Light/Cloud")
                self.squeaky = UIImage(named: "\(name)/Light/Squeaky")
            }
        }
        
        let dark:Dark
        let light:Light
        
        init(name:String) {
            self.dark = Dark(name: name)
            self.light = Light(name: name)
        }
    }
    
    let dark:UIImage?
    let light:UIImage?
    
    init(name:String) {
        self.dark = UIImage(named: "\(name)/Dark")
        self.light = UIImage(named: "\(name)/Light")
    }
}


struct Icons {
    static let favourite = Icon.WithStyle(name: "Favourite")
    static let close = Icon(name: "Close")
    static let rotate = Icon(name: "Rotate")
    static let downloadButton = UIImage(named: "downloadButton")
    static let favButton = Icon.Themed(name: "FavButton")
    
    
    struct Social {
        static let github = UIImage(named: "Social/github")
        static let instagram = UIImage(named: "Social/instagram")
        static let twitter = UIImage(named: "Social/twitter")
        static let medium = UIImage(named: "Social/medium")
        static let reddit = UIImage(named: "Social/reddit")
        static let link = UIImage(named: "Social/link")
        static let unsplash = UIImage(named: "Social/unsplash")
    }
}



/*
 * ------------------------
 * MARK: - Picture Quality
 * ------------------------
 */
enum PictureQuality: String {
    case thumb = "thumb"
    case small = "small"
    case regular = "regular"
    case full = "full"
    case raw = "raw"
}

/*
 * -------------------------
 * MARK: - TableView Helper
 * -------------------------
 */
func getNumberOfSections<T: SectionProtocol>(items: [T]) -> Int {
    var splitted = [T]()
    
    items.forEach { (s1) in
        let count = splitted.filter({ s1.section == $0.section }).count
        
        if count == 0 {
            splitted.append(s1)
        }
    }
    
    return splitted.count
}

func getNumberOfSections(items: [SettingItem]) -> Int {
    var splitted: [SettingItem] = [SettingItem]()
    
    items.forEach { (item) in
        let count = splitted.filter({ item.section == $0.section }).count
        
        if count == 0 {
            splitted.append(item)
        }
    }
    
    return splitted.count
}



/*
 * -----------------------
 * MARK: - Onboarding
 * ------------------------
 */
struct OnboardingData {
    let title:String
    let description:String
    let image: UIImage?
    
    init(title:String, descr:String, image:UIImage?=nil) {
        self.title = title
        self.description = descr
        self.image = image
    }
}


/*
 * -----------------------
 * MARK: - Functions
 * ------------------------
 */
func delay(_ d: DispatchTimeInterval, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + d, execute: completion)
}



/*
 * --------------------------------
 * MARK: - Firebase: Remote Config
 * --------------------------------
 */
func fetchRemoteConfig(remote: RemoteConfig, onSuccess: @escaping () -> Void, onError: @escaping (_ error: Error?, _ message: String?) -> Void) {
    let expiration = remote.configSettings.isDeveloperModeEnabled ? 0 : 3600;
    
    remote.fetch(withExpirationDuration: TimeInterval(expiration)) { (status:RemoteConfigFetchStatus, error) in
        if let error = error {
            onError(error, nil)
            return
        }
        
        if status == .success {
            remote.activateFetched()
            onSuccess()
        } else if status == .failure {
            onError(nil, "No error available")
        }
    }
}

struct RemoteCollection:Decodable {
    var id: Int
    var coverPhoto: String?
    var customDescription: String?
    var customTitle: String?
    var isHandPicked: Bool?
}

enum HideGesture:String {
    case tap = "tap"
    case longPress = "long-press"
    case none = "none"
}

struct CloseGesture {
    static var sizes = [
        UIScreen.main.bounds.height / 7.5,
        UIScreen.main.bounds.height / 5.5,
        UIScreen.main.bounds.height / 3.5
    ]
    
    enum PanSize:Int {
        case short = 0
        case medium = 1
        case long = 2
    }
}





class Network {
    internal enum HTTPMethod:String {
        case get, GET = "GET"
        case post, POST = "POST"
        case put, PUT = "PUT"
        case delete, DELETE = "DELETE"
    }
    
    enum Response<Value> {
        case success(Value)
        case failure(String?, Int?)
    }
    
    static func fetch(
        url:String,
        method: HTTPMethod = .GET,
        payload: [String:String]? = nil,
        headers: [String:String]? = nil,
        completion: @escaping (Response<Data>) -> Void
    ) {
        let url = URL(string: url)!
        var r = URLRequest(url: url);
        r.httpMethod = method.rawValue
        
        if let headers = headers {
            headers.forEach { (header) in
                r.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        if let payload = payload {
            do {
                let data = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
                r.httpBody = data
            } catch let error {
                completion(.failure(error.localizedDescription, nil))
            }
        }
        
        let task = URLSession.shared.dataTask(with: r) { (data, response, error) in
            let response = response as! HTTPURLResponse
            if let error = error {
                completion(.failure(error.localizedDescription, response.statusCode))
                return
            }
            
            guard let data = data else {
                completion(.failure("No data", response.statusCode))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
    
    static func fetch<T:Decodable>(
        url:String,
        method: HTTPMethod = .GET,
        payload: [String:String]? = nil,
        headers: [String:String]? = nil,
        completion: @escaping (Response<T>) -> Void
    ) {
        let url = URL(string: url)!
        var r = URLRequest(url: url);
        r.httpMethod = method.rawValue
        
        if let headers = headers {
            headers.forEach { (header) in
                r.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        if let payload = payload {
            do {
                let data = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
                r.httpBody = data
            } catch let error {
                completion(.failure(error.localizedDescription, nil))
            }
        }
        
        let task = URLSession.shared.dataTask(with: r) { (data, response, error) in
            let response = response as! HTTPURLResponse
            if let error = error {
                completion(.failure(error.localizedDescription, response.statusCode))
                return
            }
            
            guard let data = data else {
                completion(.failure("No data", response.statusCode))
                return
            }
            
            do {
                let d: T = try JSONDecoder().decode(T.self, from: data)
                completion(.success(d))
            } catch let error {
                completion(.failure(error.localizedDescription, response.statusCode))
            }
        }
        
        task.resume()
    }
}
