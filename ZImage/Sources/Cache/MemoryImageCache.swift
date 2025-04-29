//
//  ImageCache.swift
//  ZImage
//
//  Created by Olzhas S
//

import UIKit

public protocol ImageCache: AnyObject {
    func get(forKey key: String) async -> UIImage?
    func set(_ image: UIImage, forKey key: String) async
}

public actor MemoryImageCacheImpl {
    
    // MARK: - Private
    
    private let cache: NSCache<NSString, UIImage>
    
    // MARK: - Shared
    
    public static let shared = MemoryImageCacheImpl()
    
    private init() {
        let cache = NSCache<NSString, UIImage>()
        self.cache = cache
        self.cache.countLimit = 100 // Default count limit of 100 images
        self.cache.totalCostLimit = 1024 * 1024 * 50 // Default total cost limit of 50 MB
    }
    
    // MARK: - Public Configuration
    
    public func configure(countLimit: Int? = nil, totalCostLimit: Int? = nil) {
        if let countLimit = countLimit {
            self.cache.countLimit = countLimit
        }
        if let totalCostLimit = totalCostLimit {
            self.cache.totalCostLimit = totalCostLimit
        }
    }
}

// MARK: - ImageCache

extension MemoryImageCacheImpl: ImageCache {
    
    public func get(forKey key: String) async -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    public func set(_ image: UIImage, forKey key: String) async {
        cache.setObject(image, forKey: key as NSString)
    }
}
