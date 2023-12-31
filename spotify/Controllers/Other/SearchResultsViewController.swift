import UIKit

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

protocol SearchResultsViewControllerDelegate: AnyObject {
    func delegateDidTapResult(_ result: SearchResult)
}

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private var sections = [SearchSection]()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,style: .grouped)
        tableView.register(SearchResultsDefaultTableViewCell.self, forCellReuseIdentifier: SearchResultsDefaultTableViewCell.reuseID)
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.reuseID)
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func update(with results: [SearchResult]) {
        let artists = results.filter {
            switch $0 {
            case .artist: return true
            default: return false
            }
        }
        let playlists = results.filter {
            switch $0 {
            case .playlist: return true
            default: return false
            }
        }
        let tracks = results.filter {
            switch $0 {
            case .track: return true
            default: return false
            }
        }
        let albums = results.filter {
            switch $0 {
            case .album: return true
            default: return false
            }
        }
        self.sections = [
            SearchSection(title: "Songs",results: tracks),
            SearchSection(title: "Albums",results: albums),
            SearchSection(title: "Playlists",results: playlists),
            SearchSection(title: "Artists",results: artists)
        ]
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]
        switch result {
        case .artist(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsDefaultTableViewCell.reuseID, for: indexPath) as? SearchResultsDefaultTableViewCell else { return UITableViewCell() }
            cell.configure(with: SearchResultsDefaultTableViewCellViewModel(
                title: model.name,
                imageURL: URL(string: model.images.first?.url ?? "")))
            return cell
        case .track(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.reuseID, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }
            cell.configure(with: SearchResultSubtitleTableViewCellViewModel(
                title: model.name,
                subtitle: model.artists.first?.name ?? "-",
                imageurl: URL(string: model.album?.images.first?.url ?? "")))
            return cell
        case .album(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.reuseID, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }
            cell.configure(with: SearchResultSubtitleTableViewCellViewModel(
                title: model.name,
                subtitle: model.artists.first?.name ?? "-",
                imageurl: URL(string: model.images.first?.url ?? "")))
            return cell
        case .playlist(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.reuseID, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }
            cell.configure(with: SearchResultSubtitleTableViewCellViewModel(
                title: model.name,
                subtitle: model.owner.display_name,
                imageurl: URL(string: model.images?.first?.url ?? "")))
            return cell
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.delegateDidTapResult(result)
    }
}
