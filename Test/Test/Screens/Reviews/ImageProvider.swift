//
//  ImageProvider.swift
//  Test
//
//  Created by Evelina on 27.02.2025.
//

import Foundation
import UIKit

final class ImageProvider {
    
    private var imageCache: NSCache<NSString, UIImage>
    
    init() {
        self.imageCache = NSCache<NSString, UIImage>()
    }
}

// MARK: - Internal
extension ImageProvider {
    
    func image(for urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = getImageFromCache(for: urlString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            self?.saveImageToCache(image, for: urlString)
            
            completion(image)
        }.resume()
    }
}

// MARK: - Private
private extension ImageProvider {
    
    func getImageFromCache(for urlString: String) -> UIImage? {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            return cachedImage
        }
        return nil
    }
    
    func saveImageToCache(_ image: UIImage, for urlString: String) {
        imageCache.setObject(image, forKey: urlString as NSString)
    }
}
