//
//  Endless_imagesApp.swift
//  Endless images
//
//  Created by Ильнур Закиров on 10.02.2024.
//

import SwiftUI

@main
struct Endless_imagesApp: App {
    @StateObject var feedViewModel = FeedViewModel()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FeedView(viewModel: feedViewModel)
            }
        }
    }
}
