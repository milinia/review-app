import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Автор создания отзыва.
    let author: NSAttributedString
    /// Рейтинг  отзыва.
    let ratingImage: UIImage
    /// URL аватара автора  отзыва.
    let avatarImageUrl: String
    /// Фотографии   отзыва.
    let imageUrls: [String]
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - Internal
extension ReviewCellConfig {
    
    func updateAuthorImage(for cell: UITableViewCell?, with image: UIImage?) {
        guard let cell = cell as? ReviewCell else { return }
        
        DispatchQueue.main.async {
            cell.authorImageView.image = image
        }
    }
}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.authorTextLabel.attributedText = author
        cell.ratingImageView.image = ratingImage
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?
    fileprivate var viewModel: ReviewCellViewModel?

    fileprivate let authorImageView = UIImageView()
    fileprivate let authorTextLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate let collectionViewLayout =  UICollectionViewFlowLayout()
    fileprivate lazy var reviewPhotoCollectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
        authorImageView.frame = layout.authorImageViewFrame
        authorTextLabel.frame = layout.authorLabelFrame
        ratingImageView.frame = layout.ratingImageViewFrame
        reviewPhotoCollectionView.frame = layout.reviewPhotoCollectionViewFrame
    }
    
    func setViewModel(viewModel: ReviewCellViewModel) {
        self.viewModel = viewModel
        reviewPhotoCollectionView.dataSource = viewModel
        reviewPhotoCollectionView.delegate = viewModel
        reviewPhotoCollectionView.reloadData()
    }

}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupAuthorImageView()
        setupAuthorTextLabel()
        setupRatingImageView()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        setupReviewPhotoCollectionView()
    }
    
    func setupAuthorImageView() {
        contentView.addSubview(authorImageView)
        authorImageView.layer.cornerRadius = Layout.avatarCornerRadius
        authorImageView.clipsToBounds = true
        authorImageView.contentMode = .scaleAspectFill
    }
    
    func setupAuthorTextLabel() {
        contentView.addSubview(authorTextLabel)
    }
    
    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
    }

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addAction(
            UIAction { [weak self] _ in
                guard let self = self, let config = self.config else { return }
                config.onTapShowMore(config.id)
            },
            for: .touchUpInside
        )
    }
    
    func setupReviewPhotoCollectionView() {
        collectionViewLayout.itemSize = ReviewCellLayout.photoSize
        contentView.addSubview(reviewPhotoCollectionView)
        reviewPhotoCollectionView.register(
            ImageCell.self,
            forCellWithReuseIdentifier: ImageCellConfig.reuseId
        )
    }

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0
    fileprivate static let photoSize = CGSize(width: 55.0, height: 66.0)
    
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    private(set) var authorLabelFrame = CGRect.zero
    private(set) var ratingImageViewFrame = CGRect.zero
    private(set) var authorImageViewFrame = CGRect.zero
    private(set) var reviewPhotoCollectionViewFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right - Self.avatarSize.width - avatarToUsernameSpacing
        
        var maxY = insets.top
        var showShowMoreButton = false
        
        authorImageViewFrame = CGRect(
            origin: CGPoint(x: insets.left, y: insets.top),
            size: Self.avatarSize
        )
        
        let xAfterAvatar = authorImageViewFrame.maxX + avatarToUsernameSpacing
        
        authorLabelFrame = CGRect(
            origin: CGPoint(x: xAfterAvatar, y: maxY),
            size: config.author.boundingRect(width: width).size
        )
        
        maxY = authorLabelFrame.maxY + usernameToRatingSpacing
        
        ratingImageViewFrame = CGRect(
            origin: CGPoint(x: xAfterAvatar, y: maxY),
            size: config.ratingImage.size
        )
        
        maxY = ratingImageViewFrame.maxY
        
        if !config.imageUrls.isEmpty {
            maxY += ratingToPhotosSpacing
            
            reviewPhotoCollectionViewFrame = CGRect(
                origin: CGPoint(x: xAfterAvatar, y: maxY),
                size: CGSize(
                    width: width,
                    height: Self.photoSize.height
                )
            )
            
            maxY = reviewPhotoCollectionViewFrame.maxY
            if !config.reviewText.isEmpty() {
                maxY += photosToTextSpacing
            } else {
                maxY += reviewTextToCreatedSpacing
            }
        }

        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight

            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: xAfterAvatar, y: maxY),
                size: config.reviewText.boundingRect(width: width, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }

        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: xAfterAvatar, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }

        createdLabelFrame = CGRect(
            origin: CGPoint(x: xAfterAvatar, y: maxY),
            size: config.created.boundingRect(width: width).size
        )

        return createdLabelFrame.maxY + insets.bottom
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
