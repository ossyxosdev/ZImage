//
//  ImageCache.swift
//  ZImage
//
//  Created by Olzhas S
//

import UIKit

/// A protocol that defines an interface for caching images by key.
public protocol ImageCache: AnyObject {
    func get(forKey key: String) async -> UIImage?
    func set(_ image: UIImage, forKey key: String) async
}

/// A memory-based implementation of the `ImageCache` protocol using `NSCache`.
///
/// This class is an `actor` to ensure thread-safe access and mutation of the cache.
/// It uses a shared singleton instance and supports configurable limits.
public actor MemoryImageCacheImpl {
    
    // MARK: - Private
    
    private let cache: NSCache<NSString, UIImage>
    
    // MARK: - Shared
    
    public static let shared = MemoryImageCacheImpl()
    
    /// Initializes the memory cache with default configuration.
    ///
    /// - `countLimit`: 100 images.
    /// - `totalCostLimit`: 50 MB (50 * 1024 * 1024 bytes).
    private init() {
        let cache = NSCache<NSString, UIImage>()
        self.cache = cache
        self.cache.countLimit = 100
        self.cache.totalCostLimit = 1024 * 1024 * 50
    }
    
    // MARK: - Public Configuration
    
    /// Updates the cache configuration at runtime.
    ///
    /// - Parameters:
    ///   - countLimit: Optional maximum number of items to store in memory.
    ///   - totalCostLimit: Optional maximum memory cost limit (in bytes).
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
    
    /// Retrieves an image from the memory cache.
    ///
    /// - Parameter key: The key used to store the image.
    /// - Returns: A `UIImage` if found, otherwise `nil`.
    public func get(forKey key: String) async -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    /// Stores an image in the memory cache.
    ///
    /// - Parameters:
    ///   - image: The `UIImage` to store.
    ///   - key: The key to associate with the image.
    public func set(_ image: UIImage, forKey key: String) async {
        cache.setObject(image, forKey: key as NSString)
    }
}
