import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?
    
    /// Замыкание, вызываемое при нажатии на фото
    var onPhotoTap: (([String], Int) -> Void)?

    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder
    
    let imageProvider: ImageProvider

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        imageProvider: ImageProvider = ImageProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.imageProvider = imageProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
    }

}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        state.shouldLoad = false
        
        if state.items.isEmpty {
            showLoadingIndicator()
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.reviewsProvider.getReviews(offset: self?.state.offset ?? 0) { reviews in
                self?.gotReviews(reviews)
            }
        }
    }
    
    func resetViewModel() {
        state = .init()
    }

}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            
            if state.isFirstLoad {
                hideLoadingIndicator()
            }
            state.items += reviews.items.map(makeReviewItem)
            
            if state.items.count >= reviews.count {
                state.items.append(makeReviewsCountItem(reviewsCount: reviews.count))
            }
            
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count
        } catch {
            state.shouldLoad = true
        }
        onStateChange?(state)
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        state.cellHeights[IndexPath(row: index, section: 0)] = nil
        onStateChange?(state)
    }
    
    func showLoadingIndicator() {
        state.items.append(LoadingCellConfig())
        onStateChange?(state)
    }
    
    func hideLoadingIndicator() {
        state.items.removeAll()
        state.cellHeights.removeAll()
        state.isFirstLoad = false
    }

}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig

    func makeReviewItem(_ review: Review) -> ReviewItem {
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let ratingImage = ratingRenderer.ratingImage(review.rating)
        let author = review.firstName + " " + review.lastName
        let authorText = author.attributed(font: .username)
        let item = ReviewItem(
            reviewText: reviewText,
            created: created,
            author: authorText,
            ratingImage: ratingImage,
            avatarImageUrl: review.avatarUrl,
            imageUrls: review.photoUrls, onTapShowMore: { [weak self] id in
                self?.showMoreReview(with: id)
            }
        )
        return item
    }

}

private extension ReviewsViewModel {
    
    typealias ReviewCountItem = ReviewCountCellConfig

    func makeReviewsCountItem(reviewsCount: Int) -> ReviewCountItem {
        let reviewCountText = "\(reviewsCount) отзывов".attributed(
            font: .reviewCount,
            color: .reviewCount
        )
        return ReviewCountItem(reviewsCount: reviewCountText)
    }

}



// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
        config.update(cell: cell)
        
        loadImageForCell(config: config, cell: cell)
        
        return cell
    }
    
    private func loadImageForCell(config: TableCellConfig, cell: UITableViewCell) {
        if let config = config as? ReviewCellConfig {
            
            if let cell = cell as? ReviewCell {
                let viewModel = ReviewCellViewModel(imageUrls: config.imageUrls)
                viewModel.onTapPhoto = self.onPhotoTap
                viewModel.imageProvider = imageProvider
                cell.setViewModel(viewModel: viewModel)
                
            }
            
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                self?.imageProvider.image(for: config.avatarImageUrl) { image in
                    config.updateAuthorImage(for: cell, with: image)
                }
            }
        }
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cachedHeight = state.cellHeights[indexPath] {
            return cachedHeight
        }
        let height = state.items[indexPath.row].height(with: tableView.bounds.size)
        state.cellHeights[indexPath] = height
        return height
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }

}
