//
//  MockImageCache.swift
//  ZImageTests
//
//  Created by Olzhas S
//

@testable import ZImage
import SwiftUI

final class MockImageCache: ImageCache {
    private var storage: [String: UIImage] = [:]
    
    func get(forKey key: String) async -> UIImage? {
        storage[key]
    }
    
    func set(_ image: UIImage, forKey key: String) async {
        storage[key] = image
    }
}
