//
//  LImageView.swift
//  Endless images
//
//  Created by Ильнур Закиров on 12.02.2024.
//

import SwiftUI

struct ImageView: View {
    
    @Binding var data: Data?
    
    var body: some View {
        if let data {
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image("xmark")
                    .resizable()
                    .frame(height: 100)
            }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .border(.blue, width: 2)
        }
    }
}
