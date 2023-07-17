import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
}
struct ArtistObject: Codable {
    let id: String
    let genres: [String]
    let name: String
    let images: [ImageObject]
    let type: String
    let external_urls: [String: String]
}
