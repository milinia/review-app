//
//  ReviewCellViewModel.swift
//  Test
//
//  Created by Evelina on 02.03.2025.
//

import Foundation
import UIKit

final class ReviewCellViewModel: NSObject {
    private let imageConfigs: [ImageCellConfig]
    private let imageUrls: [String]
    var imageProvider: ImageProvider?
    
    var onTapPhoto: (([String], Int) -> Void)?
    
    init(imageUrls: [String]) {
        self.imageUrls = imageUrls
        self.imageConfigs = imageUrls.map({ ImageCellConfig(
            imageUrl: $0,
            isRoundedCorners: true
        )})
    }
}

extension ReviewCellViewModel: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        imageConfigs.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCellConfig.reuseId,
            for: indexPath
        ) as? ImageCell else {
            return UICollectionViewCell()
        }
        
        let config = imageConfigs[indexPath.item]
        
        DispatchQueue.global().async { [weak self] in
            self?.imageProvider?.image(for: config.imageUrl) { image in
                config.update(cell: cell, with: image)
            }
        }
        
        return cell
    }
}

extension ReviewCellViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTapPhoto?(imageUrls, indexPath.item + 1)
    }
}
