//
//  ZImageConfiguration.swift
//  ZImage
//
//  Created by Olzhas S
//

import Foundation

/// A global configuration object used to customize behavior of the ZImage framework.
///
/// Use `ZImageConfiguration.shared` to access and configure settings such as maximum concurrent downloads.
public final class ZImageConfiguration {
    
    public static let shared = ZImageConfiguration()
    
    private init() {}

    /// Set to `nil` to allow unlimited concurrent downloads
    public var maxConcurrentDownloads: Int? = nil
}
