//
//  CompositeImageCache.swift
//  ZImage
//
//  Created by Olzhas S
//

import SwiftUI

public actor CompositeImageCacheImpl {
    
    // MARK: - Private
    
    private let memoryCache: ImageCache
    private let diskCache: ImageCache
    
    // MARK: - Init
    
    public init(memoryCache: ImageCache = MemoryImageCacheImpl.shared,
         diskCache: ImageCache = DiskImageCacheImpl()) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }
}

// MARK: - ImageCache

extension CompositeImageCacheImpl: ImageCache {
    
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
    
    public func set(_ image: UIImage, forKey key: String) async {
        await memoryCache.set(image, forKey: key)
        await diskCache.set(image, forKey: key)
    }
}
