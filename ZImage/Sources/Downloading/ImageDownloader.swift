//
//  ImageDownloader.swift
//  ZImage
//
//  Created by Olzhas S
//

import SwiftUI

/// A protocol that defines an interface for downloading a single image with optional progress tracking.
public protocol ImageDownloader {
    /// Downloads an image asynchronously from the specified URL.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to download.
    ///   - onProgress: An optional async closure that is called with download progress updates (from 0.0 to 1.0).
    /// - Returns: A `UIImage` object if the download succeeds.
    /// - Throws: An error if the image cannot be downloaded or decoded.
    func downloadImage(from url: URL,
                       onProgress: ((Double) async -> Void)?) async throws -> UIImage
}

/// A concrete implementation of `ImageDownloader` using `URLSessionDownloadTask`.
///
/// `ImageDownloaderImpl` supports asynchronous image downloading with progress updates
/// and error handling using continuations and `URLSessionDownloadDelegate`.
final public class ImageDownloaderImpl: NSObject {
    
    // MARK: - Private
    
    private var continuation: CheckedContinuation<UIImage, Error>?
    private var session: URLSession?
    private var onProgress: ((Double) async -> Void)?
    
    private func cleanup() {
        session?.invalidateAndCancel()
        session = nil
        continuation = nil
        onProgress = nil
    }
}

// MARK: - URLSessionDownloadDelegate

extension ImageDownloaderImpl: URLSessionDownloadDelegate {
    
    /// Reports download progress to the provided progress handler.
    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        if let onProgress = onProgress {
            Task {
                await onProgress(progress)
            }
        }
    }
    
    /// Called when the download finishes successfully. Attempts to convert the downloaded data to a `UIImage`.
    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        defer { cleanup() }
        
        do {
            let data = try Data(contentsOf: location)
            guard let image = UIImage(data: data) else {
                continuation?.resume(throwing: ZImageError.invalidImageData)
                return
            }
            continuation?.resume(returning: image)
        } catch {
            continuation?.resume(throwing: ZImageError.custom(error))
        }
    }
    
    /// Handles download task errors and resumes the continuation with failure if needed.
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error = error as? URLError {
            continuation?.resume(throwing: ZImageError.urlSessionError(error))
        } else if let error {
            continuation?.resume(throwing: ZImageError.custom(error))
        }
        cleanup()
    }
}

// MARK: - SingleImageDownloader

extension ImageDownloaderImpl: ImageDownloader {
    
    /// Starts downloading an image from the given URL with optional progress tracking.
    ///
    /// - Parameters:
    ///   - url: The image URL to download.
    ///   - onProgress: An optional closure for tracking download progress (0.0 - 1.0).
    /// - Returns: The downloaded image as a `UIImage` if successful.
    /// - Throws: A `ZImageError` if the image is invalid or the request fails.
    public func downloadImage(
        from url: URL,
        onProgress: ((Double) async -> Void)? = nil
    ) async throws -> UIImage {
        self.onProgress = onProgress
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            self.session = session
            session.downloadTask(with: url).resume()
        }
    }
}
