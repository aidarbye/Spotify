import Foundation

struct Track: Codable {
    var album: Album?
    let artists: [Artist]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let id: String
    let is_playable: Bool?
    let name: String
    let preview_url: String?
    let available_markets: [String]
    let track_number: Int
    let external_urls: [String:String]
}
