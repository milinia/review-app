//
//  ImageGalleryViewModel.swift
//  Test
//
//  Created by Evelina on 01.03.2025.
//

import Foundation
import UIKit

final class ImageGalleryViewModel: NSObject {
    var onStateChange: ((State) -> Void)?

    var state: State
    private let imageProvider: ImageProvider
    
    init(
        state: State = State(),
        imageProvider: ImageProvider = ImageProvider()
    ) {
        var state = state
        state.items = state.imageURLs.map({ ImageCellConfig(imageUrl: $0) })
        self.state = state
        self.imageProvider = imageProvider
    }
}

// MARK: - Internal

extension ImageGalleryViewModel {

    typealias State = ImageGalleryViewModelState
}

extension ImageGalleryViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        state.imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config = state.items[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCellConfig.reuseId,
            for: indexPath
        ) as? ImageCell else {
            return UICollectionViewCell()
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.imageProvider.image(for: config.imageUrl) { image in
                config.update(cell: cell, with: image)
            }
        }
        return cell
    }
    
}

extension ImageGalleryViewModel: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.bounds.width != 0 else { return }
        
        let index = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        
        if scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.width) == 0 {
            state.currentImageIndex = index + 1
        }
        onStateChange?(state)
    }
}
