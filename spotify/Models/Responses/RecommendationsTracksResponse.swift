import Foundation

struct RecommendationsTracksResponse: Codable {
    let tracks: [Track]
}

struct TrackResponse: Codable {
    let items: [Track]
}
