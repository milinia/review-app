import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        viewModel.getReviews()
    }

}

// MARK: - Private

private extension ReviewsViewController {

    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        
        reviewsView.refreshControl.addTarget(self, action: #selector(refreshReviewData(_:)), for: .valueChanged)
        return reviewsView
    }
    
    @objc func refreshReviewData(_ sender: Any) {
        viewModel.resetViewModel()
        viewModel.getReviews()
        reviewsView.refreshControl.endRefreshing()
    }

    func setupViewModel() {
        viewModel.onStateChange = { [weak reviewsView] state in
            DispatchQueue.main.async {
                reviewsView?.tableView.reloadData()
            }
        }
        
        viewModel.onPhotoTap = { [weak self] imageUrls, chosenImageIndex in
            guard let self = self else { return }
            let factory = ImageGalleryScreenFactory()
            let controller = factory.makeImageGalleryController(
                imageUrls: imageUrls,
                imageProvider: self.viewModel.imageProvider,
                chosenImageIndex: chosenImageIndex)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
