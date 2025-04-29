//
//  ZImageConfiguration.swift
//  ZImage
//
//  Created by Olzhas S
//

import Foundation

public final class ZImageConfiguration {
    
    public static let shared = ZImageConfiguration()
    
    private init() {}

    /// Set to `nil` to allow unlimited concurrent downloads
    public var maxConcurrentDownloads: Int? = nil
}
