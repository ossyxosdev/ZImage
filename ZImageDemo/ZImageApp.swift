//
//  ZImageApp.swift
//  ZImage
//
//  Created by Olzhas S
//

import SwiftUI

@main
struct ZImageApp: App {
    
    init() {
        //configureZImage()
    }
    
    func configureZImage() {
        ZImageConfiguration.shared.maxConcurrentDownloads = 1
        MemoryImageCacheImpl.shared.configure(countLimit: 200,
                                              totalCostLimit: 1024 * 1024 * 200)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
