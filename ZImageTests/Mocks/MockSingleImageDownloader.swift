//
//  MockSingleImageDownloader.swift
//  ZImageTests
//
//  Created by Olzhas S
//

@testable import ZImage
import SwiftUI

final class MockSingleImageDownloader: ImageDownloader {
    
    var downloadCalledCount = 0
    var downloadCalled = false
    var stubbedImages: [URL: UIImage] = [:]
    var errorToThrow: Error?
    var reportedProgressValues: [Double] = []
    
    func downloadImage(from url: URL,
                       onProgress: ((Double) async -> Void)? = nil) async throws -> UIImage {
        downloadCalled = true
        downloadCalledCount += 1
        
        if let error = errorToThrow {
            throw error
        }
        
        if let onProgress {
            await onProgress(0.1)   // 10% progress
            await onProgress(0.5)   // 50% progress
            await onProgress(1.0)   // 100% progress
            reportedProgressValues = [0.1, 0.5, 1.0]
        }
        
        guard let image = stubbedImages[url] else {
            throw URLError(.badServerResponse)
        }
        
        return image
    }
}

