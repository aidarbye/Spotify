//
//  LibraryPlaylistViewController.swift
//  spotify
//
//  Created by Айдар Нуркин on 19.07.2023.
//

import UIKit

class LibraryPlaylistViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        APICaller.shared.getCurrentUserPlaylist { result in
            switch result {
            case .success(let playlists): break
            case .failure(let error): break
            }
        }
    }

}
