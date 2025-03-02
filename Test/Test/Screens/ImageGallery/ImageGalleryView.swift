//
//  ImageGalleryView.swift
//  Test
//
//  Created by Evelina on 01.03.2025.
//

import Foundation
import UIKit

final class ImageGalleryView: UIView {
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        return collectionViewLayout
    }()
    
    lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        collectionViewLayout.itemSize = CGSize(width: frame.width, height: frame.height)
    }
}

// MARK: - Private

private extension ImageGalleryView {

    func setupView() {
        backgroundColor = .systemBackground
        setupCollectionView()
    }

    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.isPagingEnabled = true
        collectionView.register(
            ImageCell.self,
            forCellWithReuseIdentifier: ImageCellConfig.reuseId
        )
    }

}
