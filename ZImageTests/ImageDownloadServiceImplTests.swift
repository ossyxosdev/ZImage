//
//  ImageDownloadServiceImplTests.swift
//  ZImageTests
//
//  Created by Olzhas S
//

@testable import ZImage
import Testing
import SwiftUI

struct ImageDownloadServiceImplTests {
    
    private var sut: ZImageManager
    private var mockCache: MockImageCache
    private var mockDownloader: MockSingleImageDownloader

    init() {
        mockCache = MockImageCache()
        let mockDownloader = MockSingleImageDownloader()
        self.mockDownloader = mockDownloader
        sut = .init(makeImageDownloader: { mockDownloader },
                    cache: mockCache)
    }

    @Test func test_downloadImage_ifImageExistsInCache() async throws {
        let url = mockUrl()
        let expectedImage = UIImage()
        await mockCache.set(expectedImage, forKey: url.absoluteString)
        
        let result = await sut.downloadImages(from: [url])
        
        #expect(result.images[url] == expectedImage)
        #expect(mockDownloader.downloadCalled == false, "Downloader should not be called if image is cached")
    }
    
    @Test func test_downloadImage_ifNotInCache() async throws {
        let url = mockUrl()
        let expectedImage = UIImage()
        mockDownloader.stubbedImages[url] = expectedImage
        
        let result = await sut.downloadImages(from: [url])
        
        #expect(result.images[url] == expectedImage)
        #expect(mockDownloader.downloadCalled == true, "Downloader should be called if image is not cached")
        
        let cachedImage = await mockCache.get(forKey: url.absoluteString)
        #expect(cachedImage == expectedImage, "Image should be cached after downloading")
    }
    
    @Test func test_downloadImage_propagatesError_fromDownloader() async {
        let url = mockUrl()
        let expectedError = URLError(.badURL)
        mockDownloader.errorToThrow = expectedError
        
        let result = await sut.downloadImages(from: [url])
        
        let actualError = result.failed[url] as? URLError
        #expect(actualError == expectedError, "Expected \(expectedError), but got \(String(describing: actualError))")
    }
    
    @Test func test_downloadImages_concurrently() async throws {
        let url1 = URL(string: "https://example.com/image1.png")!
        let url2 = URL(string: "https://example.com/image2.png")!
        let url3 = URL(string: "https://example.com/image3.png")!
        
        let image1 = UIImage()
        let image2 = UIImage()
        let image3 = UIImage()
        
        // Set up the mock downloader
        mockDownloader.stubbedImages = [
            url1: image1,
            url2: image2,
            url3: image3
        ]

        await mockCache.set(image1, forKey: url1.absoluteString)
        await mockCache.set(image2, forKey: url2.absoluteString)
        
        // Call downloadImages concurrently
        let result = await sut.downloadImages(from: [url1, url2, url3])
        
        // Check that correct images are returned
        #expect(result.images[url1] == image1)
        #expect(result.images[url2] == image2)
        #expect(result.images[url3] == image3)
        
        // Check downloader was called for only url3 (since url1 & url2 were cached)
        #expect(mockDownloader.downloadCalledCount == 1, "Downloader should be called for url3")
        
        // Check that images are cached after downloading
        let cachedImage1 = await mockCache.get(forKey: url1.absoluteString)
        let cachedImage2 = await mockCache.get(forKey: url2.absoluteString)
        let cachedImage3 = await mockCache.get(forKey: url3.absoluteString)
        
        #expect(cachedImage1 == image1, "Image1 should be cached")
        #expect(cachedImage2 == image2, "Image2 should be cached")
        #expect(cachedImage3 == image3, "Image3 should be cached")
    }
    
    @Test func test_downloadImage_reportsProgress() async throws {
        let url = mockUrl()
        let expectedImage = UIImage()
        mockDownloader.stubbedImages = [url: expectedImage]
        
        var progressValues: [Double] = []
        
        _ = await sut.downloadImages(from: [url], onProgress: { url, progress in
            progressValues.append(progress)
        })
        
        #expect(progressValues == [0.1, 0.5, 1.0], "Progress values should match the expected sequence")
        #expect(progressValues.count == 3, "Progress should be reported 3 times (10%, 50%, 100%)")
        #expect(mockDownloader.downloadCalledCount == 1, "Downloader should be called once")
    }

}

extension ImageDownloadServiceImplTests {
    
    func mockUrl() -> URL {
        URL(string: "https://example.com/image.png")!
    }
}
