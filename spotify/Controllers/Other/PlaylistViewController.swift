import UIKit

class PlaylistViewController: UIViewController {
    
    private let playlist: Playlist
    
    public var isOwner = false
    
    private let collectionView = UICollectionView(
        frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { _, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
            
            let group = NSCollectionLayoutGroup.vertical (
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(60)),
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top)
            ]
            return section
        }
    )
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    private var viewModels = [RecommendedTrackCellViewModel]()
    private var tracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLongTapGesture()
        title = playlist.name
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(RecommendedTrackCollectionViewCell.self,
                                forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.reuseID)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.reuseID)
        APICaller.shared.getPlaylistDetails(for: playlist) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let model):
                    self?.tracks = model.tracks.items.compactMap{ $0.track }
                    
                    self?.viewModels = model.tracks.items.compactMap({ item in
                        return RecommendedTrackCellViewModel(
                            name: item.track.name,
                            artistName: item.track.artists.first?.name ?? "-",
                            artworkURL: URL(string: item.track.album?.images.first?.url ?? ""))
                     })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(didTapShared))
    }
    
    private func addLongTapGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didtaplong(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc private func didtaplong(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        let touchpoint = gesture.location(in: collectionView)
        guard let indexpath = collectionView.indexPathForItem(at: touchpoint) else {
            return
        }
        let tracktodelete = tracks[indexpath.row]
        let actionsheet = UIAlertController(title: "remove \(tracktodelete.name)", message: "d u wana remove", preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "cancel", style: .cancel))
        actionsheet.addAction(UIAlertAction(title: "delete", style: .default,handler: { [weak self] _ in
            guard let playlist = self?.playlist else {return}
            APICaller.shared.removeTrackFromPlaylist(track: tracktodelete, playlist: playlist) { success in
                DispatchQueue.main.async {
                    if success {
                        self?.tracks.remove(at: indexpath.row)
                        self?.viewModels.remove(at: indexpath.row)
                        self?.collectionView.reloadData()
                        print("deleted")
                    } else {
                        print("not delelted")
                    }
                }
            }
        }))
        present(actionsheet, animated: true)
        
        
    }
    
    @objc private func didTapShared() {
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else {
            return
        }
        
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
}
extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        collectionView.deselectItem(at: indexPath, animated: true)
        let track = tracks[indexPath.row]
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecommendedTrackCollectionViewCell.reuseID,
            for: indexPath) as? RecommendedTrackCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.reuseID,
            for: indexPath) as? PlaylistHeaderCollectionReusableView,
        kind == UICollectionView.elementKindSectionHeader
        else {
            return UICollectionReusableView()
        }
        let headerVM = PlaylistHeaderViewViewModel(
            name: playlist.name,
             ownerName: playlist.owner.display_name,
              description: playlist.description,
               artworkURL: URL(string: playlist.images?.first?.url ?? ""))
        header.configure(with: headerVM)
        header.delegate = self
        return header
    }
}

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks)
    }
}
