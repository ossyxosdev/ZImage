
# Zimran + Image = ZImage🚀
<img width="1689" alt="image" src="https://github.com/user-attachments/assets/b12964fa-a723-475b-9005-f0b3cce3921d" />


A lightweight, multithreaded image downloading framework for Swift and SwiftUI. It provides asynchronous image loading, in-memory caching, download progress tracking, and cancellation support — all optimized for use in SwiftUI with a clean, modular architecture.

## 🚀 Features

- ✅ SwiftUI-compatible image view (`ZImage`)
- ✅ Multithreaded downloading via a custom thread pool (using Swift's modern Structed Concurrency)
- ✅ Composite caching mechanism using In-Memory and Disk Caches
- ✅ Download progress tracking
- ✅ Image loading cancellation
- ✅ Testable and clean architecture

## 🧩 Architecture
<img width="623" alt="image" src="https://github.com/user-attachments/assets/debeec77-79d5-4c38-b750-b5c60873eb52" />


The framework handles image downloading through a structured and efficient pipeline, with support for **caching**, **progress tracking**, and **cancellation**.
Uses a layered caching strategy that combines **in-memory** and optional **disk-based caching** through a composable abstraction:

- When an image is requested, the system first checks the **in-memory cache**.
- If not found, it checks the **disk cache**.
- If still not found, it downloads the image from the **network**.

After a successful download:

- The image is stored in the **memory cache** for fast reuse.
- Optionally stored in the **disk cache** for persistence across sessions.
---

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
    // Show your view when image loading fails
}
```

Additional:
The framework’s ```ZImageManager``` can be used independently of ZImage, making it easy to integrate with your own custom views or logic. This allows you to download and manage images directly, without relying on the built-in ZImage view.

```swift
.task {
    _ = await ZImageManager.shared.downloadImages(from: urls)
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


## Unit Tests
Core functionality covered with unit tests using Apple's modern Swift Testing native library.

## Demo
Download repository with source code and demo application. All sources are in the corresponding folders. For now, everything is in one project, but it is possible to take it out as a separate library.
Demo application shows usecases of framework - downloading single/multiple images, caching, UI-features.

<div align="center">

<img width="413" alt="image" src="https://github.com/user-attachments/assets/31dba98d-d440-41a5-8c75-9ee4739b8d6f" />
<img width="413" alt="image" src="https://github.com/user-attachments/assets/390053f7-56c3-43d6-bc89-3bd6b86b947d" />


</div>


