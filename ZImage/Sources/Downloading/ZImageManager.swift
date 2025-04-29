//
//  ZImageManager.swift
//  ZImage
//
//  Created by Olzhas S
//

import UIKit
import Foundation

/// A protocol defining the interface for managing image downloads with progress tracking and result grouping.
public protocol ZImageManagerProtocol {
    
    /// Downloads multiple images asynchronously from the given URLs.
    ///
    /// - Parameters:
    ///   - urls: An array of image URLs to download.
    ///   - onProgress: An optional closure that reports progress for each individual image.
    /// - Returns: A tuple containing a dictionary of successfully downloaded images and a dictionary of failed downloads with errors.
    func downloadImages(
        from urls: [URL],
        onProgress: ((URL, Double) async -> Void)?
    ) async -> (images: [URL: UIImage], failed: [URL: Error])
}

/// A manager responsible for downloading and caching images, supporting concurrent downloads and progress reporting.
///
/// `ZImageManager` uses an `ImageCache` for caching (memory + disk) and allows limiting concurrent downloads
/// using an optional `AsyncSemaphore`.
final public class ZImageManager {
    
    // MARK: - Dependencies
    
    private let cache: ImageCache
    private let makeImageDownloader: () -> ImageDownloader
    private var semaphore: AsyncSemaphore?
    
    // MARK: - Shared
    
    public static let shared = ZImageManager()
    
    // MARK: - Inits
    
    public init(makeImageDownloader: @escaping () -> ImageDownloader,
                cache: ImageCache) {
        self.makeImageDownloader = makeImageDownloader
        self.cache = cache
    }
    
    public convenience init() {
        self.init(makeImageDownloader: { ImageDownloaderImpl() },
                  cache: CompositeImageCacheImpl())
    }
}

// MARK: - ImageDownloadService

extension ZImageManager: ZImageManagerProtocol {
    
    /// Downloads images from the given URLs concurrently, with optional progress reporting and error handling.
    ///
    /// Caches successful downloads and avoids re-downloading already cached images.
    /// The number of concurrent downloads is limited if configured via `ZImageConfiguration.shared.maxConcurrentDownloads`.
    ///
    /// - Parameters:
    ///   - urls: List of image URLs to download.
    ///   - onProgress: Optional closure providing progress updates for each URL.
    /// - Returns: A tuple of:
    ///   - `images`: Successfully downloaded or cached images mapped by URL.
    ///   - `failed`: URLs that failed to download along with their associated error.
    public func downloadImages(
        from urls: [URL],
        onProgress: ((URL, Double) async -> Void)? = nil
    ) async -> (images: [URL: UIImage], failed: [URL: Error]) {
        var results: [URL: UIImage] = [:]
        var failedResults: [URL: Error] = [:]
        
        await withTaskGroup(of: (URL, Result<UIImage, Error>).self) { group in
            for url in urls {
                group.addTask {
                    let semaphore = await self.getSemaphore()
                    await semaphore?.wait()
                    defer { semaphore?.signal() }
                    
                    let key = url.absoluteString
                    if let cachedImage = await self.cache.get(forKey: key) {
                        return (url, .success(cachedImage))
                    }
                    
                    do {
                        let downloader = self.makeImageDownloader()
                        let image = try await downloader.downloadImage(from: url) { progress in
                            if let onProgress {
                                await onProgress(url, progress)
                            }
                        }
                        await self.cache.set(image, forKey: key)
                        return (url, .success(image))
                    } catch {
                        return (url, .failure(error))
                    }
                }
            }
            
            for await (url, result) in group {
                switch result {
                case let .success(image):
                    results[url] = image
                case let .failure(error):
                    failedResults[url] = error
                }
            }
        }
        
        return (images: results, failed: failedResults)
    }
}

// MARK: - Private Methods

private extension ZImageManager {
    
    /// Retrieves a shared semaphore based on configured concurrency limit.
    ///
    /// - Returns: An `AsyncSemaphore` if `ZImageConfiguration.shared.maxConcurrentDownloads` is set; otherwise, `nil`.
    func getSemaphore() async -> AsyncSemaphore? {
        if let max = ZImageConfiguration.shared.maxConcurrentDownloads {
            return await SharedSemaphorePool.shared.get(for: max)
        }
        return nil
    }
}
