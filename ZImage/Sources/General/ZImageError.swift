//
//  ZImageError.swift
//  ZImage
//
//  Created by Olzhas S
//

import Foundation

/// Represents all the errors that can occur in the ZImage framework.
public enum ZImageError: Error, LocalizedError{
    case invalidImageData
    case urlSessionError(URLError)
    case imageNotFound(URL)
    case custom(Error)
    
    public var errorDescription: String {
        switch self {
        case .invalidImageData:
            return "The downloaded data is not a valid image."
        case let .urlSessionError(urlError):
            return urlError.localizedDescription
        case let .custom(error):
            return error.localizedDescription
        case let .imageNotFound(url):
            return "Image not found at URL: \(url.absoluteString)"
        }
    }
}
