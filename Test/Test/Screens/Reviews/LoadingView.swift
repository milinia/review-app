//
//  LoadingView.swift
//  Test
//
//  Created by Evelina on 28.02.2025.
//

import Foundation
import UIKit

final class LoadingView: UIView {
    
    private let replicator = CAReplicatorLayer()
    private let dot = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Internal
extension LoadingView {
    
    func startAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.2
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.repeatCount = .infinity
        animation.autoreverses = true
            
        dot.add(animation, forKey: "opacityAnimation")
    }
    
    func stopAnimation() {
        dot.removeAnimation(forKey: "opacityAnimation")
    }
}

// MARK: - Private
private extension LoadingView {
    
    static let dotSize: CGFloat = 6.0
    static let dotOffset: CGFloat = 8.0
    static let dotColor: CGColor = UIColor.lightGray.cgColor
    
    func setupView() {
        backgroundColor = .systemBackground
        
        replicator.frame = bounds
        layer.addSublayer(replicator)
        
        dot.frame = CGRect(
            x: replicator.frame.size.width - Self.dotSize,
            y: replicator.position.y,
            width: Self.dotSize,
            height: Self.dotSize
        )
        
        dot.backgroundColor = Self.dotColor
        dot.borderColor = UIColor(white: 1.0, alpha: 1.0).cgColor
        dot.borderWidth = 0.5
        dot.opacity = 1.0
        dot.cornerRadius = dot.frame.width / 2.0
        
        replicator.addSublayer(dot)
        
        replicator.instanceCount = 3
        replicator.instanceDelay = 0.2
        replicator.instanceTransform = CATransform3DMakeTranslation(Self.dotOffset,0.0,0.0)
    }
}
