//
//  ZImage.swift
//  ZImage
//
//  Created by Olzhas S
//

import SwiftUI

public struct ZImage<Content: View, Placeholder: View, ErrorContent: View>: View {
    
    @StateObject private var loader: ZImageLoader
    
    private let content: (Image) -> Content
    private let placeholder: (Double) -> Placeholder
    private let onErrorContent: (ZImageError) -> ErrorContent
    
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

// MARK: - Inits

extension ZImage {
    
    // Full Init
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
