//
//  CompositeImageCache.swift
//  ZImage
//
//  Created by Olzhas S
//

import SwiftUI

/// A composite implementation of the `ImageCache` protocol that combines in-memory and disk caching.
///
/// `CompositeImageCacheImpl` first checks the memory cache for an image. If not found, it checks the disk cache.
/// If the image is found on disk, it is promoted back into memory for faster future access.
/// This actor ensures thread-safe access to both memory and disk caches.
public actor CompositeImageCacheImpl {
    
    // MARK: - Private
    
    /// The underlying memory-based image cache (typically fast but volatile).
    private let memoryCache: ImageCache
    /// The underlying disk-based image cache (persistent between app launches).
    private let diskCache: ImageCache
    
    // MARK: - Init
    
    /// Creates a new composite image cache with optional custom memory and disk cache implementations.
    public init(
        memoryCache: ImageCache = MemoryImageCacheImpl.shared,
        diskCache: ImageCache = DiskImageCacheImpl())
    {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }
}

// MARK: - ImageCache

extension CompositeImageCacheImpl: ImageCache {
    
    /// Asynchronously retrieves an image for the specified key.
    ///
    /// First checks the memory cache. If not found, attempts to load from disk cache and re-caches it in memory.
    ///
    /// - Parameter key: A unique identifier for the cached image.
    /// - Returns: A `UIImage` if found, otherwise `nil`.
    public func get(forKey key: String) async -> UIImage? {
        if let memoryImage = await memoryCache.get(forKey: key) {
            return memoryImage
        }
        
        if let diskImage = await diskCache.get(forKey: key) {
            await memoryCache.set(diskImage, forKey: key)
            return diskImage
        }
        
        return nil
    }
    
    /// Asynchronously stores an image in both memory and disk caches.
    ///
    /// - Parameters:
    ///   - image: The `UIImage` to cache.
    ///   - key: A unique identifier for the image.
    public func set(_ image: UIImage, forKey key: String) async {
        await memoryCache.set(image, forKey: key)
        await diskCache.set(image, forKey: key)
    }
}
