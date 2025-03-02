//
//  ImageCell.swift
//  Test
//
//  Created by Evelina on 01.03.2025.
//

import Foundation
import UIKit

struct ImageCellConfig {
    let imageUrl: String
    var isRoundedCorners: Bool = false
    
    static var reuseId: String {
        String(describing: Self.self)
    }
}

final class ImageCell: UICollectionViewCell {
    fileprivate var config: Config?
    
    fileprivate let imageView = UIImageView()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
}

// MARK: - Internal

extension ImageCellConfig {

    func update(cell: ImageCell, with image: UIImage?) {
        cell.config = self
    
        DispatchQueue.main.async {
            if isRoundedCorners {
                cell.imageView.layer.cornerRadius = ImageCell.cornerRadius
                cell.imageView.contentMode = .scaleAspectFill
            }
            
            cell.imageView.image = image
        }
    }
}

// MARK: - Private

private extension ImageCell {
    
    static let cornerRadius: CGFloat = 8.0

    func setupCell() {
        setupImageView()
        
        imageView.frame = bounds
    }

    func setupImageView() {
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
    }
}

// MARK: - Typealias

fileprivate typealias Config = ImageCellConfig
