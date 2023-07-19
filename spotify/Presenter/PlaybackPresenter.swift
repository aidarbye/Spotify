//
//  PlaybackPresenter.swift
//  spotify
//
//  Created by Айдар Нуркин on 18.07.2023.
//

import Foundation
import UIKit
import AVKit

protocol PlayerDataSourse: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
}

final class PlaybackPresenter {
    
    var playerVC: PlayerViewController?
    
    static let shared = PlaybackPresenter()
    
    private var track: Track?
    private var tracks = [Track]()
    
    var index = 0
    
    var player: AVPlayer?
    var playerQueue: AVQueuePlayer?
    
    var currentTrack: Track? {
        if let track = track, tracks.isEmpty {
            return track
        }
        else if let player = self.playerQueue, !tracks.isEmpty {
            return tracks[index]
        }
        return nil
    }
    
    func startPlayback(
        from viewController: UIViewController,
        track: Track
    ) {
        // some songs dont have preview_url so this must be changed
        guard let url = URL(string: track.preview_url ?? "") else { return }
        
        player = AVPlayer(url: url)
        player?.volume = 0.5
        
        self.track = track
        self.tracks = []
        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        vc.title = track.name
        vc.navigationItem.largeTitleDisplayMode = .never
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player?.play()
        }
        self.playerVC = vc
    }
    func startPlayback(
        from viewController: UIViewController,
        tracks: [Track]
    ) {
        self.tracks = tracks
        self.track = nil
        
        let items: [AVPlayerItem] = tracks.compactMap { track in
            guard let url = URL(string: track.preview_url ?? "") else {
                return nil
            }
            return AVPlayerItem(url: url)
        }
        
        self.playerQueue = AVQueuePlayer(items: items)
        self.playerQueue?.volume = 0.5
        self.playerQueue?.play()
        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player?.play()
        }
        self.playerVC = vc
    }
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    
    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
    
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        } else if let player = playerQueue {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty {
            // not playlist or album
            player?.pause()
        } else if let player = playerQueue {
            player.advanceToNextItem()
            index += 1
            playerVC?.refreshUI()
        }
    }
    
    func didTapBack() {
        if tracks.isEmpty {
            // not playlist or album
            player?.pause()
            player?.play()
        } else if let firstItem = playerQueue?.items().first {
            // PASS
//            playerQueue?.pause()
//            playerQueue?.removeAllItems()
//            playerQueue = AVQueuePlayer(items: [firstItem])
//            playerQueue?.play()
//            playerQueue?.volume = 0.5
        }
    }
}
extension PlaybackPresenter: PlayerDataSourse {
    var songName: String? {
        currentTrack?.name
    }
    
    var subtitle: String? {
        currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
}
