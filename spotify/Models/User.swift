import Foundation

struct User: Codable {
    let display_name: String
    let external_urls: [String:String]
    let id: String
}
