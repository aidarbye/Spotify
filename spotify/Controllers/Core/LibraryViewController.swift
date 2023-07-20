import UIKit

class LibraryViewController: UIViewController {
    
    
    
    private let playlistVC = LibraryPlaylistViewController()
    private let albumVC = LibraryAlbumViewController()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private let toogleView = LibraryToggleView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        view.addSubview(toogleView)
        toogleView.delegate = self
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: view.width*2, height: scrollView.height)
        addChildren()
        updateBarButtons()
    }
    
    private func updateBarButtons() {
        switch toogleView.state {
        case .playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        case .album:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func didTapAdd() {
        playlistVC.showCreatePlaylistAlert()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.width, height: view.height-view.safeAreaInsets.bottom-view.safeAreaInsets.top-55)
        toogleView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: 200, height: 55)
    }
    private func addChildren() {
        addChild(playlistVC)
        scrollView.addSubview(playlistVC.view)
        playlistVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        playlistVC.didMove(toParent: self)
        
        addChild(albumVC)
        scrollView.addSubview(albumVC.view)
        albumVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
        albumVC.didMove(toParent: self)
    }
}

extension LibraryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (view.width-100) {
            toogleView.update(for: .album)
            updateBarButtons()
        } else {
            toogleView.update(for: .playlist)
            updateBarButtons()
        }
    }
}
extension LibraryViewController: LibraryToggleViewDelegate {
    func LibraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        updateBarButtons()
    }
    
    func LibraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        updateBarButtons()
    }
}
