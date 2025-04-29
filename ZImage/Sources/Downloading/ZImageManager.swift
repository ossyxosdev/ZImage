//
//  ZImageManager.swift
//  ZImage
//
//  Created by Olzhas S
//

import UIKit
import Foundation

public protocol ZImageManagerProtocol {
    func downloadImages(from urls: [URL],
                        onProgress: ((URL, Double) async -> Void)?) async -> (images: [URL: UIImage], failed: [URL: Error])
}

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
    
    func getSemaphore() async -> AsyncSemaphore? {
        if let max = ZImageConfiguration.shared.maxConcurrentDownloads {
            return await SharedSemaphorePool.shared.get(for: max)
        }
        return nil
    }
}
