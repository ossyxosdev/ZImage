//
//  ImageDownloader.swift
//  ZImage
//
//  Created by Olzhas S
//

import SwiftUI

public protocol ImageDownloader {
    func downloadImage(from url: URL,
                       onProgress: ((Double) async -> Void)?) async throws -> UIImage
}

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
    
    public func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        if let onProgress = onProgress {
            Task {
                await onProgress(progress)
            }
        }
    }
    
    public func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
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
    
    public func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
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
    
    public func downloadImage(from url: URL,
                       onProgress: ((Double) async -> Void)? = nil) async throws -> UIImage {
        self.onProgress = onProgress
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            self.session = session
            session.downloadTask(with: url).resume()
        }
    }
}
