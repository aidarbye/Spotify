import UIKit

class LibraryAlbumViewController: UIViewController, ActionLabelViewDelegate {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.reuseID)
        tableView.isHidden = true
        return tableView
    }()
    
    private var observer: NSObjectProtocol?
    
    var albums = [Album]()
    
    private let noAlbumsView = ActionLabelView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        setupnoalbum()
        fetchData()
        observer = NotificationCenter.default.addObserver(forName: .albumSaveNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.fetchData()
        })
    }
    
    @objc private  func didTapClose() {
        dismiss(animated: true)
    }
    
    private func fetchData() {
        albums.removeAll()
        APICaller.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let albums):
                    HapticsManager.shared.vibrate(for: .success)
                    self?.albums = albums.compactMap({  
                        return Album(album_type: $0.album.album_type,
                                     total_tracks: $0.album.total_tracks,
                                     available_markets: $0.album.available_markets,
                                     id: $0.album.id,
                                     images: $0.album.images,
                                     name: $0.album.name,
                                     release_date: $0.album.release_date,
                                     artists: $0.album.artists)
                    })
                    self?.updateUI()
                case .failure(let error):
                    HapticsManager.shared.vibrate(for: .error)
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func setupnoalbum() {
        view.addSubview(noAlbumsView)
        noAlbumsView.delegate = self
        noAlbumsView.configure(with: ActionLabelViewViewModel(text: "You dont have save any albums yeat",
                                                                 actionTitle: "Browse"))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumsView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noAlbumsView.center = view.center
        tableView.frame = view.bounds
    }
    
    private func updateUI() {
        if albums.isEmpty {
            // show label
            noAlbumsView.isHidden = false
            tableView.isHidden = true
        } else {
            tableView.reloadData()
            tableView.isHidden = false
            noAlbumsView.isHidden = true
            // show table
        }
    }
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        // allow show creation ui
        tabBarController?.selectedIndex = 0
    }

}
extension LibraryAlbumViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.reuseID, for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let album = albums[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(
            title: album.name,
            subtitle: album.artists.first?.name ?? "",
            imageurl: URL(string: album.images.first?.url ?? "")))
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        tableView.deselectRow(at: indexPath, animated: true)
        let album = albums[indexPath.row]
        let vc = AlbumViewController(album: album)
        
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
