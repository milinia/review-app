final class ReviewsScreenFactory {

    /// Создаёт контроллер списка отзывов, проставляя нужные зависимости.
    func makeReviewsController() -> ReviewsViewController {
        let reviewsProvider = ReviewsProvider()
        let imageProvider = ImageProvider()
        let viewModel = ReviewsViewModel(
            reviewsProvider: reviewsProvider,
            imageProvider: imageProvider
        )
        let controller = ReviewsViewController(viewModel: viewModel)
        return controller
    }

}
