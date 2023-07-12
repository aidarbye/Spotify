import Foundation

struct FeaturedPlaylistResponse: Codable{
    let playlists: PlaylistResponse
}

struct PlaylistResponse:Codable {
    let items: [Playlist]
}
