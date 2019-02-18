//
//  UnsplashAPIClient.swift
//  Wallpapers
//
//  Created by Federico Vitale on 11/11/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation

typealias DefaultCallback<T> = (_ responseObject: T?, _ statusCode: Int) -> Void
enum DecodableResponse<Value> {
    case success(Value)
    case failure(String?, Int?)
}


struct Filters {
    var query: String?
    var user: String?
    var collections: String?
    var count: String?
    
    init(query:String?=nil, user:String?=nil, collections:[String]?=nil, count:Int? = nil) {
        self.query = query
        self.user = user
        self.collections = collections?.joined(separator: ",")
        self.count = count != nil ? "\(count!)" : nil
    }
}

class UnsplashAPIClient {
    private let baseURL: String = "https://api.unsplash.com"
    private let client_id:String
    private let client_secret:String
    
    init(client_id:String, client_secret:String, redirect_uri: URL? = nil, bearerToken:String? = nil) {
        self.client_id = client_id
        self.client_secret = client_secret
    }
    
    
    private func fetch(endpoint: String, params: [URLQueryItem]? = [URLQueryItem](), completion: @escaping (Data, HTTPURLResponse) -> ()) -> Void {
        let session = URLSession.shared
        var url = URL(string: self.baseURL)!
        
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "client_id", value: self.client_id)]
        
        
        params?.forEach({ (item) in
            if item.value != nil {
                queryItems.append(item)
            }
        })
        

        url.appendPathComponent(endpoint)
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems
        
        url = urlComponents.url!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            guard let data = data else { return }
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            completion(data, httpResponse)
        }
        
        task.resume()
    }
    
    /// GET A PHOTO BY ID
    public func getPhoto(id: String, completion: @escaping DefaultCallback<Unsplash.Photo>) {
        self.fetch(endpoint: "photos/\(id)") { (data, response) in
            if response.statusCode != 200 {
                completion(nil, response.statusCode)
                return
            }
            
            do {
                let photo = try JSONDecoder().decode(Unsplash.Photo.self, from: data)
                completion(photo, response.statusCode)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    /// GET COLLECTION BY ID
    public func getCollection(id:String, isCurated curated: Bool = false, completion: @escaping DefaultCallback<Unsplash.Collection>) {
        let endpoint = curated ? "collections/curated/\(id)" : "collections/\(id)"
        
        self.fetch(endpoint: endpoint) { (data, response) in
            if response.statusCode != 200 {
                completion(nil, response.statusCode)
                return
            }
            
            do {
                let collection = try JSONDecoder().decode(Unsplash.Collection.self, from: data)
                completion(collection, response.statusCode)
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
    }
    
    public func getPhotosFromCollection(collection: Unsplash.Collection, page: Int = 1, limit:Int=30, completion: @escaping DefaultCallback<[Unsplash.Photo]>) {
        self.fetch(endpoint: "collections/\(collection.id)/photos", params: [
            URLQueryItem(name: "per_page", value: "\(limit > 30 ? 30 : limit)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]) { (data, response) in
            if response.statusCode != 200 {
                completion(nil, response.statusCode)
                return
            }
            
            do {
                let photos = try JSONDecoder().decode([Unsplash.Photo].self, from: data)
                completion(photos, response.statusCode)
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
    }
    
    public func getRandomPhoto(filters: Filters = Filters(), completion: @escaping DefaultCallback<Unsplash.Photo>) {
        self.fetch(endpoint: "photos/random", params: [
            URLQueryItem(name: "query", value: filters.query),
            URLQueryItem(name: "count", value: filters.count),
            URLQueryItem(name: "collections", value: filters.collections),
            URLQueryItem(name: "user", value: filters.user)
        ]) { (data, response) in
            if response.statusCode != 200 {
                completion(nil, response.statusCode)
                return
            }
            
            do {
                let photo = try JSONDecoder().decode(Unsplash.Photo.self, from: data)

                completion(photo, response.statusCode)
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
    }
    
    public func getRandomPhotoWithNoParams(completion: @escaping DefaultCallback<Unsplash.Photo>) {
        self.fetch(endpoint: "photos/random") { (data, response) in
            if response.statusCode != 200 {
                completion(nil, response.statusCode)
                return
            }
            
            do {
                let photo = try JSONDecoder().decode(Unsplash.Photo.self, from: data)
                completion(photo, response.statusCode)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // GET USER BY ID
    public func getUser(user username: String, completion: @escaping DefaultCallback<Unsplash.User>) {
        self.fetch(endpoint: "/users/\(username)") { (data, response) in
            if response.statusCode != 200 {
                completion(nil, response.statusCode)
                return
            }
            
            do {
                let user = try JSONDecoder().decode(Unsplash.User.self, from: data)
                completion(user, response.statusCode)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // LIST ALL COLLECTIONS
    public func listCollections() {}
    
    // GET USER'S PHOTOS
    public func getUserPhotos(user username: String) {}
}


// Authenticated methods
extension UnsplashAPIClient {
    private enum HTTPMethod:String {
        case get, GET = "GET"
        case post, POST = "POST"
        case put, PUT = "PUT"
        case delete, DELETE = "DELETE"
        
    }
    private func authenticatedFetch(url:String, method: HTTPMethod = .GET, payload: [String: Any] = [:], headers: [String: String] = [:], completion: @escaping (DecodableResponse<Data>) -> Void) {
        let session = URLSession.shared
        
        var r = URLRequest(url: URL(string: url)!)
        r.httpMethod = method.rawValue
        
        do {
            r.httpBody = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
        } catch let error {
            completion(.failure(error.localizedDescription, nil))
            return
        }
        
        r.setValue(Preferences.keychain.bearer != nil ? "Bearer \(Preferences.keychain.bearer!)" : "Client-ID \(Preferences.keychain.apiKeys.access_key)", forHTTPHeaderField: "Authorization")
        headers.forEach { (header) in
            r.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        let task = session.dataTask(with: r) { (data, response, error) in
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
    
    public func getCurrentUser(completion: @escaping (DecodableResponse<Unsplash.User>) -> Void) {
        authenticatedFetch(url: "https://api.unsplash.com/me") { (response) in
            switch response {
            case .success(let data):
                do {                    
                    let user = try JSONDecoder().decode(Unsplash.User.self, from: data)
                    completion(.success(user))
                } catch let DecodingError.dataCorrupted(context) {
                    completion(.failure(context.debugDescription, nil))
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    
                    completion(.failure("Key '\(key)' not found:" + context.debugDescription, nil))
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    
                    completion(.failure("Value '\(value)' not found:" + context.debugDescription, nil))
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    
                    completion(.failure("Type '\(type)' mismatch:" + context.debugDescription, nil))
                } catch {
                    completion(.failure(error.localizedDescription, nil))
                }
                
                break
            case .failure(let message, let status):
                completion(.failure(message, status))
                break
            }
        }
    }
}
