
# Zimran + Image = ZImage🚀

A lightweight, multithreaded image downloading framework for Swift and SwiftUI. It provides asynchronous image loading, in-memory caching, download progress tracking, and cancellation support — all optimized for use in SwiftUI with a clean, modular architecture.

## 🚀 Features

- ✅ SwiftUI-compatible image view (`ZImage`)
- ✅ Multithreaded downloading via a custom thread pool (using Swift's modern Structed Concurrency)
- ✅ Composite caching mechanism using In-Memory and Disk Caches
- ✅ Download progress tracking
- ✅ Image loading cancellation
- ✅ Testable and clean architecture

## 🧩 Architecture



## 🛠️ Usage

Basic usage:
```swift
let url = URL(string: "https://example.com/image.jpg")

ZImage(url: url)
    .frame(width: 100, height: 100)
```

Apply any SwiftUI modifiers to the loaded image through a flexible content builder:
```swift
ZImage(url) { image in
    image
        .resizable()
        .scaledToFit()
}
```
Ability to set placeholder/handling download progress and handle when image loading fails:
```swift
ZImage(url) { image in
    image
        .resizable()
        .scaledToFit()
} placeholder: { progress in
    // You can add your own Progress view
    // Or just placeholder view (replace "progress" with "_" if no needed)
} onErrorContent: { error in
    // Show view when image loading fails
}
```
### ⚙️ Configuration
As additional feature the framework supports advanced configuration to meet various performance and memory requirements. You can globally adjust settings such as the number of concurrent downloads and image cache limits:

```swift
func configureZImage() {
    // Set to nil to let the system automatically determine the number of concurrent downloads
    ZImageConfiguration.shared.maxConcurrentDownloads = 1

    // Setting Images max count to store (100) and Cache Size in Bytes (200 MB)
    MemoryImageCacheImpl.shared.configure(countLimit: 100, totalCostLimit: 1024 * 1024 * 200)
}
```

## Requirements
* iOS 15+

## Demo
Download repository with source code and demo application. All sources are in the corresponding folders. For now, everything is in one project, but it is possible to take it out as a separate library.
Demo application shows usecases of framework - downloading single/multiple images, caching, UI-features.
