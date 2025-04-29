//
//  DiskImageCache.swift
//  ZImage
//
//  Created by Olzhas S
//

import SwiftUI

/// A disk-based implementation of the `ImageCache` protocol.
///
/// `DiskImageCacheImpl` persists image data to the disk using the app's caches directory.
/// This actor ensures thread-safe read and write operations by serializing access.
public actor DiskImageCacheImpl {
    
    // MARK: - Private
    
    private let directory: URL
    
    // MARK: - Init
    
    /// Creates a new disk image cache using a specified subdirectory in the user's cache directory.
    ///
    /// - Parameter subdirectory: The folder name inside the cache directory where images are saved. Default is `"ZImageDiskCache"`.
    ///
    /// Example:
    /// ```swift
    /// let diskCache = DiskImageCacheImpl(subdirectory: "MyAppImageCache")
    /// ```
    public init(subdirectory: String = "ZImageDiskCache") {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.directory = cachesDirectory.appendingPathComponent(subdirectory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
}

// MARK: - ImageCache

extension DiskImageCacheImpl: ImageCache {
    
    /// Asynchronously retrieves an image from disk for a given key.
    ///
    /// - Parameter key: A unique identifier for the image.
    /// - Returns: The `UIImage` if found and decodable, otherwise `nil`.
    public func get(forKey key: String) async -> UIImage? {
        let url = path(for: key)
        guard let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
    
    /// Asynchronously writes an image to disk using the given key.
    ///
    /// - Parameters:
    ///   - image: The `UIImage` to store.
    ///   - key: A unique identifier for the image.
    public func set(_ image: UIImage, forKey key: String) async {
        let url = path(for: key)
        guard let data = image.pngData() else { return }
        try? data.write(to: url)
    }
    
    /// Generates a file URL for a given cache key using SHA-256 hashing.
    ///
    /// - Parameter key: A string key associated with the image.
    /// - Returns: A `URL` pointing to the location on disk where the image is stored.
    private func path(for key: String) -> URL {
        directory.appendingPathComponent(key.sha256() + ".png")
    }
}
