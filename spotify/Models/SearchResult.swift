//
//  SearchResult.swift
//  spotify
//
//  Created by Айдар Нуркин on 18.07.2023.
//

import Foundation

enum SearchResult {
    case artist(model: ArtistObject)
    case album(model: Album)
    case track(model: Track)
    case playlist(model: Playlist)
}
