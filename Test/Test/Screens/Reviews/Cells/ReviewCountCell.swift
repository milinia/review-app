//
//  ReviewCountCell.swift
//  Test
//
//  Created by Evelina on 26.02.2025.
//

import Foundation
import UIKit

struct ReviewCountCellConfig {
    /// Общее количество отзывов.
    var reviewsCount: NSAttributedString
    
    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCountCellLayout()
}

// MARK: - TableCellConfig

extension ReviewCountCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCountCell else { return }
        cell.reviewsCountTextLabel.attributedText = reviewsCount
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

final class ReviewCountCell: UITableViewCell {

    fileprivate var config: Config?
    
    fileprivate let reviewsCountTextLabel = UILabel()

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
        reviewsCountTextLabel.frame = layout.reviewsCountTextLabelFrame
    }

}

// MARK: - Private

private extension ReviewCountCell {

    func setupCell() {
        setupReviewsCountTextLabel()
    }

    func setupReviewsCountTextLabel() {
        contentView.addSubview(reviewsCountTextLabel)
        reviewsCountTextLabel.textAlignment = .center
    }
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки количества отзывов.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCountCellLayout {

    // MARK: - Фреймы

    private(set) var reviewsCountTextLabelFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right

        reviewsCountTextLabelFrame = CGRect(
            origin: CGPoint(x: insets.right, y: insets.top),
            size: CGSize(
                width: width,
                height: config.reviewsCount.boundingRect(width: width).height
            )
        )

        return reviewsCountTextLabelFrame.maxY + insets.bottom
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCountCellConfig
fileprivate typealias Layout = ReviewCountCellLayout
