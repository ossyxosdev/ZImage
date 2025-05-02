//
//  ZImageLoader.swift
//  ZImage
//
//  Created by Olzhas S
//

import SwiftUI
import UIKit
import Combine

/// An `ObservableObject` that asynchronously loads an image from a given URL using a download manager.
/// `ZImageLoader` provides `@Published` properties to track the downloaded image, progress, and error state.
@MainActor
public final class ZImageLoader: ObservableObject {
    
    // MARK: - Published
    
    @Published public var image: UIImage?
    @Published public var error: ZImageError?
    @Published public var progress: Double = 0.0
    
    // MARK: - Private
    
    private let url: URL
    private var currentTask: Task<Void, Never>?
    
    // MARK: - Dependencies
    
    private let downloadManager: ZImageManagerProtocol
    
    // MARK: - Inits
    
    public init(url: URL,
                downloadManager: ZImageManagerProtocol) {
        self.url = url
        self.downloadManager = downloadManager
    }
    
    public convenience init(url: URL) {
        self.init(url: url,
                  downloadManager: ZImageManager.shared)
    }
    
    // MARK: - Deinit
    
    deinit {
        currentTask?.cancel()
    }
}

// MARK: - Public

extension ZImageLoader {
    
    public func loadImageIfNeeded() {
        guard image == nil else { return }
        load()
    }
    
    public func load() {
        currentTask?.cancel()
        currentTask = Task {
            let result = await downloadManager.downloadImages(from: [url]) { url, progress in
                await MainActor.run {
                    self.progress = progress
                }
            }
            
            if let image = result.images[url] {
                self.image = image
                self.error = nil
            } else if let error  = result.failed[url] {
                self.image = nil
                self.error = error as? ZImageError
            }
        }
    }
    
    public func cancelDownload() {
        currentTask?.cancel()
    }
}
