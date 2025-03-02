//
//  LoadingCell.swift
//  Test
//
//  Created by Evelina on 28.02.2025.
//

import Foundation
import UIKit

struct LoadingCellConfig {
    
    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = LoadingCellLayout()
}

// MARK: - TableCellConfig

extension LoadingCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? LoadingCell else { return }
        cell.config = self
        
        cell.activityIndicator.startAnimation()
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

final class LoadingCell: UITableViewCell {

    fileprivate var config: Config?
    
    fileprivate let activityIndicator = LoadingView()

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
        activityIndicator.frame = layout.activityIndicatorFrame
    }

}

// MARK: - Private

private extension LoadingCell {

    func setupCell() {
        setupActivityIndicator()
    }

    func setupActivityIndicator() {
        contentView.addSubview(activityIndicator)
    }
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки количества отзывов.
/// После расчётов возвращается актуальная высота ячейки.
private final class LoadingCellLayout {
    
    // MARK: - Размеры

    fileprivate static let activityIndicatorSize = CGSize(width: 16.0, height: 16.0)

    // MARK: - Фреймы

    private(set) var activityIndicatorFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 20.0, left: 12.0, bottom: 20.0, right: 12.0)

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right
        let centerX = width / 2 + Self.activityIndicatorSize.width / 2

        activityIndicatorFrame = CGRect(
            origin: CGPoint(x: centerX, y: insets.top),
            size: Self.activityIndicatorSize
        )

        return activityIndicatorFrame.maxY + insets.bottom
    }

}

// MARK: - Typealias

fileprivate typealias Config = LoadingCellConfig
fileprivate typealias Layout = LoadingCellLayout
