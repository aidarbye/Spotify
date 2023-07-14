import UIKit

class FeaturedPlaylistsCollectionViewCell: UICollectionViewCell {
    static let reuseID = "FeaturedPlaylistsCollectionViewCell"
    
    private let playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        
        return imageView
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(creatorNameLabel)
        contentView.addSubview(playlistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        creatorNameLabel.frame = CGRect(x: 3, y: contentView.height - 30, width: contentView.width-6, height: 30)
        playlistNameLabel.frame = CGRect(x: 3, y: contentView.height - 60, width: contentView.width-6, height: 30)
        let imageSize = contentView.height-70
        playlistCoverImageView.frame = CGRect(x: (contentView.width-imageSize)/2, y: 3, width: imageSize, height: imageSize)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistNameLabel.text = nil
        creatorNameLabel.text = nil
        playlistCoverImageView.image = nil
    }
    
    func configure(with viewModel: FeaturedPlaylistsCellViewModel) {
        playlistNameLabel.text = viewModel.name
        creatorNameLabel.text = viewModel.creatorName
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL)
    }
}
