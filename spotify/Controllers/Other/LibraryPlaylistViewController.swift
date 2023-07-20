//
//  LibraryPlaylistViewController.swift
//  spotify
//
//  Created by Айдар Нуркин on 19.07.2023.
//

import UIKit

class LibraryPlaylistViewController: UIViewController, ActionLabelViewDelegate {

    public var selectionHandler: ((Playlist)->Void)?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.reuseID)
        tableView.isHidden = true
        return tableView
    }()
    
    var playlists = [Playlist]()
    
    private let noPlaylistsView = ActionLabelView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        setupnoplaylistsview()
        fetchData()
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }
    }
    
    @objc private  func didTapClose() {
        dismiss(animated: true)
    }
    
    private func fetchData() {
        APICaller.shared.getCurrentUserPlaylist { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func setupnoplaylistsview() {
        view.addSubview(noPlaylistsView)
        noPlaylistsView.delegate = self
        noPlaylistsView.configure(with: ActionLabelViewViewModel(text: "You dont have any playlists yeat",
                                                                 actionTitle: "Create"))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlaylistsView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noPlaylistsView.center = view.center
        tableView.frame = view.bounds
    }
    
    private func updateUI() {
        if playlists.isEmpty {
            // show label
            noPlaylistsView.isHidden = false
            tableView.isHidden = true
        } else {
            tableView.reloadData()
            tableView.isHidden = false
            noPlaylistsView.isHidden = true
            // show table
        }
    }
    public func showCreatePlaylistAlert() {
        let alert = UIAlertController(title: "New Playlist", message: "Enter name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            APICaller.shared.createPlaylist(with: text) { [weak self] success in
                if success {
                    // refresh
                    self?.fetchData()
                    HapticsManager.shared.vibrate(for: .success)
                } else {
                    HapticsManager.shared.vibrate(for: .error)
                    print("failed to create playlist")
                }
            }
        }))
        present(alert, animated: true)
    }
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        // allow show creation ui
        showCreatePlaylistAlert()
    }
}
extension LibraryPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.reuseID, for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(
            title: playlist.name,
            subtitle: playlist.description ?? "",
            imageurl: URL(string: playlist.images?.first?.url ?? "")))
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        tableView.deselectRow(at: indexPath, animated: true)
        let playlist = playlists[indexPath.row]
        
        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true)
            return
        }
    
        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.isOwner = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
