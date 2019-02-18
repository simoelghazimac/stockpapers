import Foundation

struct Unsplash {
    struct URLResponse: Decodable {
        let url: URL?
    }
    
    struct Tag:Decodable {
        let title: String
    }
    
    struct Stats: Decodable {
        let photos: Int
        let downloads: Int
        let views: Int
        let likes: Int
        let photographers: Int
        let pixels: Int
        let downloads_per_second: Int
        let views_per_second: Int
        let developers: Int
        let applications: Int
        let requests: Int
    }
    
    struct StatsResponse: Decodable {
        struct Detail: Decodable {
            struct Historical: Decodable {
                struct Value: Decodable {
                    let date: String
                    let value: Int
                }
                
                let change: Int
                let average: Int
                let resolution: String
                let quantity: Int
                let values: [Value]
            }
            
            let total: Int
            let historical: Historical
        }
        
        let username: String
        let downloads: Detail
        let views: Detail
        let likes: Detail
    }
    
    struct UserPhoto: Decodable {
        let id:String
        let urls: Photo.URLS
    }
    
    struct Photo:Decodable {
        enum PictureSize {
            case thumb
            case small
            case regular
            case full
            case raw
        }
        
        struct Exif:Decodable {
            let make: String?
            let model: String?
            let exposure_time: String?
            let aperture: String?
            let focal_length: String?
            let iso: Int?
        }
        
        struct URLS: Decodable {
            let raw: URL
            let full: URL
            let regular: URL
            let small: URL
            let thumb: URL
        }
        
        
        struct Location: Decodable {
            struct Coords: Decodable {
                let latitude: Double?
                let longitude: Double?
            }
            
            let city: String?
            let country: String?
            let position: Coords
        }
        
        struct Links:Decodable {
            let `self`:String
            let html:String
            let download:String
            let download_location:String
        }
        
        struct UserCollection: Decodable {
            let title: String
        }
        
        let id:String
        let created_at: String
        let updated_at: String
        let width: Double
        let height: Double
        let color: String
        let likes: Int
        let liked_by_user: Bool
        let description: String?
        let categories: [String]
        let slug: String?
        
        
        let links: Links
        let urls: URLS
        let user: User
        let exif: Exif?
        
        let sponsored: Bool
//        let sponsored_by: [String: Any]?
        let sponsored_impressions_id: String?
        let current_user_collections: [UserCollection]?
        
        let views: Int?
        let downloads: Int?
        
        func getURL(ofSize size: PictureSize = .regular) -> URL {
            let urls = self.urls
            
            switch size {
            case .thumb:
                return urls.thumb
            case .small:
                return urls.small
            case .regular:
                return urls.regular
            case .full:
                return urls.full
            case .raw:
                return urls.raw
            }
        }
        
        func getURL(ofQuality size: PictureQuality = .regular) -> URL {
            let urls = self.urls
            
            switch size {
            case .thumb:
                return urls.thumb
            case .small:
                return urls.small
            case .regular:
                return urls.regular
            case .full:
                return urls.full
            case .raw:
                return urls.raw
            }
        }
    }
    
    
    struct User:Decodable {
        struct ProfileImage: Decodable {
            let small: String
            let medium: String
            let large: String
        }
        
        struct Links:Decodable {
            let `self`:    URL
            let html:      URL
            let photos:    URL
            let likes:     URL
            let portfolio: URL
            let following: URL
            let followers: URL
        }
        
        struct UserBadge: Decodable {
            let title: String
            let primary: Bool
            let slug: String
            let link: String?
        }
        
        struct Tags:Decodable {
            let custom: [Tag?]
            let aggregated: [Tag?]
        }
        
        
        let id: String
        let username: String
        let name: String?
        let first_name:String?
        let last_name:String?
        let twitter_username:String?
        let instagram_username:String?
        let portfolio_url: URL?
        let bio: String?
        let location: String?
        let total_likes: Int
        let total_photos: Int
        let total_collections: Int
        let accepted_tos: Bool?
        
        let downloads: Int?
        let numeric_id: Int?
        let profile_image: ProfileImage
        
        let photos: [UserPhoto?]?
        
        let tags: Tags?
        let allow_messages: Bool?
        let badge: UserBadge?
        
        // visible only at /me
        let uuid: String?
        let updated_at: String?
        let uploads_remaining: Int?
        let unlimited_uploads: Bool?
        
        let links: Links
    }
    
    struct Collection:Decodable {
        struct PreviewPhoto: Decodable {
            let id: String
            let urls: Photo.URLS
        }
        
        struct Meta:Decodable {
            let title:String?
            let description:String?
            let index: Int?
            let canonical:Bool?
        }
        
        struct Links: Decodable {
            let `self`:  URL
            let html:    URL
            let photos:  URL
            let related: URL
        }
        
        
        let id:Int
        var title:String
        var description:String?
        let published_at:String
        let updated_at:String
        let curated:Bool
        let featured:Bool
        let total_photos:Int
        let `private`:Bool
        let share_key:String?
        
        
        let links: Links?
        var cover_photo: Photo?
        let tags: [Tag]?
    }
}

