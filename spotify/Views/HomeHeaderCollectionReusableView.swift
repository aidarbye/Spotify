//
//  HomeHeaderCollectionReusableView.swift
//  spotify
//
//  Created by Айдар Нуркин on 16.07.2023.
//

import UIKit

class HomeHeaderCollectionReusableView: UICollectionReusableView {
    static let reuseID = "HomeHeaderCollectionReusableView"
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(label)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 15, y: 0, width: width-30, height: height)
    }
    func configure(with title: String) {
        label.text = title
    }
    
}
