import Foundation

struct PlaylistDetailsResponse: Codable {
    let collaborative: Bool
    let description: String?
    let external_urls: [String:String]
    let id: String
    let images: [ImageObject]
    let name: String
    let tracks: PlaylistTrackResponse
}

struct PlaylistTrackResponse: Codable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Codable {
    let track: Track
}

struct LibraryPlaylistResponse: Codable {
    let items: [Playlist]
}
