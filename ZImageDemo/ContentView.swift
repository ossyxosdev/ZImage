//
//  ContentView.swift
//  ZImage
//
//  Created by Olzhas S
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        List {
            Section {
                NavigationLink {
                    SingleImageView()
                } label: {
                    Text("Single Image")
                }
                
                NavigationLink {
                    ImageGridView()
                } label: {
                    Text("Grid")
                }
            } footer: {
                Text("Картинки скачиваются асинхронно и сразу кешируются. При повторном скачивании если картинка в кеше - идет доступ с быстрого кеша (Memory Cache), если нет уже с дискового кеша (Disk Cache). При перезапуске приложения доступ уже идет с Disk Cache.\nЧтобы явно очистить Disk Cache нужно переустановить приложение.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            
        }
        .navigationTitle("ZImage Demo")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}

// MARK: - ImageGridView

struct ImageGridView: View {
    private let urls = (1...25).compactMap { URL(string: "https://dummyimage.com/600x600/6e6e6e/fff&text=\($0)") }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(urls, id: \.self) { url in
                    ZImage(url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: { _ in
                        ProgressView()
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - SingleImageView

struct SingleImageView: View {
    private let urls = (1...5).compactMap { URL(string: "https://dummyimage.com/600x400/6e6e6e/fff&text=\($0)") }
    
    @State private var currentURL: URL
    
    init() {
        _currentURL = State(initialValue: urls.randomElement()!)
    }
    
    var body: some View {
        VStack {
            Button("Load Random Image") {
                currentURL = urls.randomElement()!
            }
            
            ZImage(currentURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: { progress in
                ProgressView(value: progress)
            }
            .id(currentURL)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 400)
        }
    }
}
