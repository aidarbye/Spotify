import Foundation

struct Album: Codable {
    let album_type: String
    let total_tracks: Int
    let available_markets: [String]
    let id: String
    var images: [ImageObject]
    let name: String
    let release_date: String
    let artists: [Artist]
}
