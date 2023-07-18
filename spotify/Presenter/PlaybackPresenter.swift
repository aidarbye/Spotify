//
//  PlaybackPresenter.swift
//  spotify
//
//  Created by Айдар Нуркин on 18.07.2023.
//

import Foundation
import UIKit

final class PlaybackPresenter {
    static func startPlayback(
        from viewController: UIViewController,
        track: Track
    ) {
        let vc = PlayerViewController()
        vc.title = track.name
        vc.navigationItem.largeTitleDisplayMode = .never
        viewController.present(UINavigationController(rootViewController: vc), animated: true)
    }
    static func startPlayback(
        from viewController: UIViewController,
        tracks: [Track]
    ) {
        let vc = PlayerViewController()
        viewController.present(UINavigationController(rootViewController: vc), animated: true)
    }
}
