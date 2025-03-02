//
//  ImageGalleryViewController.swift
//  Test
//
//  Created by Evelina on 01.03.2025.
//

import Foundation
import UIKit

final class ImageGalleryViewController: UIViewController {
    
    private lazy var imageGalleryView = makeImageGalleryView()
    private let viewModel: ImageGalleryViewModel

    init(viewModel: ImageGalleryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = imageGalleryView
        title = createViewTitle(
            currentImageIndex: viewModel.state.currentImageIndex,
            totalImagesCount: viewModel.state.items.count
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        openNeededItem()
    }
}

// MARK: - Private

private extension ImageGalleryViewController {

    func makeImageGalleryView() -> ImageGalleryView {
        let imageGalleryView = ImageGalleryView()
        imageGalleryView.collectionView.delegate = viewModel
        imageGalleryView.collectionView.dataSource = viewModel
        
        return imageGalleryView
    }

    func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.title = self?.createViewTitle(
                currentImageIndex: state.currentImageIndex,
                totalImagesCount: state.items.count
            )
        }
    }
    
    func openNeededItem() {
        let indexPath = IndexPath(
            item: viewModel.state.currentImageIndex - 1,
            section: 0
        )
        
        imageGalleryView.collectionView.isPagingEnabled = false
        imageGalleryView.collectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: false
        )
        imageGalleryView.collectionView.isPagingEnabled = true
    }
    
    private func createViewTitle(
        currentImageIndex: Int,
        totalImagesCount: Int
    ) -> String {
        "\(currentImageIndex) из \(totalImagesCount)"
    }

}
