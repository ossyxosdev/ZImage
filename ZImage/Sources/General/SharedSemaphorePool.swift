//
//  SharedSemaphorePool.swift
//  ZImage
//
//  Created by Olzhas S
//

import Foundation

/// A shared pool that manages and caches `AsyncSemaphore` instances for reuse across the framework.
///
/// Use this when you want to enforce a global limit on the number of concurrent downloads
/// (or other async tasks) based on a configurable maximum. It ensures that semaphores are
/// reused rather than recreated for the same concurrency limits.
///
/// Semaphores are keyed by their maximum concurrent count (`Int`). If a semaphore for the
/// specified limit exists, it is reused; otherwise, a new one is created and stored.
///
/// Example usage:
///
/// ```swift
/// if let max = ZImageConfiguration.shared.maxConcurrentDownloads {
///     let semaphore = await SharedSemaphorePool.shared.get(for: max)
///     await semaphore.wait()
///     defer { semaphore.signal() }
///     // perform your async task
/// }
/// ```
///
public actor SharedSemaphorePool {
    
    public static let shared = SharedSemaphorePool()
    
    private var semaphores: [Int: AsyncSemaphore] = [:]
    
    public func get(for value: Int) -> AsyncSemaphore {
        if let existing = semaphores[value] {
            return existing
        }
        let new = AsyncSemaphore(value: value)
        semaphores[value] = new
        return new
    }
}
