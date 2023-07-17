//
//  SearchResultResponse.swift
//  spotify
//
//  Created by Айдар Нуркин on 17.07.2023.
//

import Foundation

struct SearchResultResponse: Codable {
    let albums: AlbumsResponse
    let tracks: TrackResponse
    let artists: SearchArtistResponse
    let playlists: PlaylistResponse
}

struct SearchArtistResponse: Codable {
    let items: [ArtistObject]
}

