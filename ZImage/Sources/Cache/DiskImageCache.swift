//
//  DiskImageCache.swift
//  ZImage
//
//  Created by Olzhas S
//

import SwiftUI
import CryptoKit

public actor DiskImageCacheImpl {
    
    // MARK: - Private
    
    private let directory: URL
    
    // MARK: - Init
    
    public init(subdirectory: String = "ZImageDiskCache") {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.directory = cachesDirectory.appendingPathComponent(subdirectory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
}

// MARK: - ImageCache

extension DiskImageCacheImpl: ImageCache {
    
    public func get(forKey key: String) async -> UIImage? {
        let url = path(for: key)
        guard let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
    
    public func set(_ image: UIImage, forKey key: String) async {
        let url = path(for: key)
        guard let data = image.pngData() else { return }
        try? data.write(to: url)
    }
    
    private func path(for key: String) -> URL {
        directory.appendingPathComponent(key.sha256() + ".png")
    }
}
