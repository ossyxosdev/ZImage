//
//  ZImage.swift
//  ZImage
//
//  Created by Olzhas S
//

import SwiftUI

/// A SwiftUI view that loads and displays an image from a remote URL with support for placeholder,
/// progress indication, and error content.
///
/// `ZImage` leverages `ZImageLoader` to download images asynchronously and provides composable
/// content for loading, success, and failure states.
///
/// This view automatically starts loading the image when it appears and cancels the download when it disappears.
public struct ZImage<Content: View, Placeholder: View, ErrorContent: View>: View {
    
    // MARK: - Internal State

    @StateObject private var loader: ZImageLoader
    
    private let content: (Image) -> Content
    private let placeholder: (Double) -> Placeholder
    private let onErrorContent: (ZImageError) -> ErrorContent
    
    // MARK: - Body
    
    /// The content and behavior of the view.
    /// Displays the loaded image if available, otherwise shows a placeholder or error view.
    public var body: some View {
        Group {
            if let uiImage = loader.image {
                content(Image(uiImage: uiImage))
            } else if let error = loader.error {
                onErrorContent(error)
            } else {
                placeholder(loader.progress)
            }
        }
        .onAppear {
            loader.loadImageIfNeeded()
        }
        .onDisappear {
            loader.cancelDownload()
        }
    }
}

// MARK: - Initializers

extension ZImage {
    
    /// Creates a `ZImage` with custom content, placeholder, and error views.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to load.
    ///   - content: ViewBuilder for rendering the successfully loaded image.
    ///   - placeholder: ViewBuilder for rendering the placeholder view while the image is downloading, with progress value.
    ///   - onErrorContent: ViewBuilder for rendering the view in case of a loading error.
    public init(
        _ url: URL,
        @ViewBuilder content: @escaping (Image) -> Content = { $0 },
        @ViewBuilder placeholder: @escaping (Double) -> Placeholder,
        @ViewBuilder onErrorContent: @escaping (ZImageError) -> ErrorContent
    ) {
        _loader = StateObject(wrappedValue: ZImageLoader(url: url))
        self.content = content
        self.placeholder = placeholder
        self.onErrorContent = onErrorContent
    }

    /// Creates a `ZImage` with custom content and error views, but no placeholder.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to load.
    ///   - content: ViewBuilder for rendering the successfully loaded image.
    ///   - onErrorContent: ViewBuilder for rendering the view in case of a loading error.
    public init(
        _ url: URL,
        @ViewBuilder content: @escaping (Image) -> Content = { $0 },
        @ViewBuilder onErrorContent: @escaping (ZImageError) -> ErrorContent
    ) where Placeholder == EmptyView {
        self.init(url,
                  content: content,
                  placeholder: { _ in EmptyView() },
                  onErrorContent: onErrorContent)
    }

    /// Creates a `ZImage` with custom content and placeholder, but no error view.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to load.
    ///   - content: ViewBuilder for rendering the successfully loaded image.
    ///   - placeholder: ViewBuilder for rendering the placeholder view while the image is downloading, with progress value.
    public init(
        _ url: URL,
        @ViewBuilder content: @escaping (Image) -> Content = { $0 },
        @ViewBuilder placeholder: @escaping (Double) -> Placeholder
    ) where ErrorContent == EmptyView {
        self.init(url,
                  content: content,
                  placeholder: placeholder,
                  onErrorContent: { _ in EmptyView() })
    }

    /// Creates a `ZImage` with only custom image content. No placeholder or error views are shown.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to load.
    ///   - content: ViewBuilder for rendering the successfully loaded image.
    public init(
        _ url: URL,
        @ViewBuilder content: @escaping (Image) -> Content = { $0 }
    ) where Placeholder == EmptyView, ErrorContent == EmptyView {
        self.init(url,
                  content: content,
                  placeholder: { _ in EmptyView() },
                  onErrorContent: { _ in EmptyView() })
    }
}


#Preview {
    List {
        let url = URL(string: "https://picsum.photos/500/500")!
        ZImage(url) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: { progress in
            // Show view
        } onErrorContent: { error in
            // Do something
        }
    }
}
