import Foundation

struct AlbumDetailsResponse:Codable {
    let album_type: String
    let total_tracks: Int
    let available_markets: [String]
    let external_urls: [String: String]
    let id: String
    let images: [ImageObject]
    let name: String
    let release_date: String
    let genres: [String]
    let label: String
    let popularity:Int
    let artists: [Artist]
    let tracks: TrackResponse
}
