import UIKit

class ProfileViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var models = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        title = "Profile"
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        fetchProfile()
    }
    
    private func fetchProfile() {
        APICaller.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let model):
                    self?.updateUI(with: model)
                case .failure(let error):
                    print("Profile Error " + error.localizedDescription)
                    self?.failedToGetProfile()
                }
            }
        }
    }
    
    private func updateUI(with model: UserProfile) {
        tableView.isHidden = false
        // configure table models
        models.append("Full name \(model.display_name)")
        models.append("Email Address \(model.email)")
        models.append("User ID \(model.id)")
        models.append("Plan \(model.product)")
        
        tableView.reloadData()
    }
    
    private func failedToGetProfile() {
        let label = UILabel(frame: .zero)
        label.text = "Failed to load profile"
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: Tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}
