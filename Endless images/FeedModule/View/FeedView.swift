//
//  ContentView.swift
//  Endless images
//
//  Created by Ильнур Закиров on 10.02.2024.
//

import SwiftUI
import Combine

struct FeedView: View {
    
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
        if viewModel.state != .loading  {
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack(alignment: .top ,spacing: 5) {
                        
                        ForEach(0..<2) { point in
                            
                            LazyVStack(spacing: 5, content: {
                                
                                ForEach(Array($viewModel.model.enumerated()), id: \.offset) { index, model in
                                    
                                    if index % 2 == point {
                                        imageView(image: model)
                                            .task {
                                                viewModel.loadImage(index: index)
                                                if viewModel.startLoadMore(image: model.wrappedValue) {
                                                    viewModel.loadMoreImages()
                                                }
                                            }
                                    }
                                    
                                }
                                
                            })
                            
                        }
                        
                    }
                    
                }
                if viewModel.state == .pagination {
                    ProgressView()
                }
            }
            .alert(viewModel.errorDescription, isPresented: $viewModel.isShowAlert) {
                Button("Ok") {
                    
                }
            }
        } else {
            ProgressView()
        }
    }
    
    @ViewBuilder
    func imageView(image: Binding<ImageModel>) -> some View {
        NavigationLink {
            DetailImageView(data: image.image)
        } label: {
            ImageView(data: image.image)
        }
    }
}

