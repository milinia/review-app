//
//  ImageGalleryScreenFactory.swift
//  Test
//
//  Created by Evelina on 01.03.2025.
//

final class ImageGalleryScreenFactory {

    func makeImageGalleryController(
        imageUrls: [String],
        imageProvider: ImageProvider,
        chosenImageIndex: Int
    ) -> ImageGalleryViewController {
        let state = ImageGalleryViewModelState(
                    currentImageIndex: chosenImageIndex,
                    imageURLs: imageUrls
        )
        let viewModel = ImageGalleryViewModel(
            state: state,
            imageProvider: imageProvider
        )
        let controller = ImageGalleryViewController(viewModel: viewModel)
        return controller
    }

}
