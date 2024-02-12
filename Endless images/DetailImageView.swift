//
//  DetailImageView.swift
//  Endless images
//
//  Created by Ильнур Закиров on 11.02.2024.
//

import SwiftUI

struct DetailImageView: View {
    
    @Binding var data: Data?
    @State var width = UIScreen.main.bounds.width
    @State var scale: CGFloat = 1
    
    var body: some View {
        ScrollView([.horizontal,.vertical]) {
            
            if let data, let image = UIImage(data: data) {
                ZStack(alignment: .center) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width)
                }
            } else {
                Image(systemName: "xmark")
            }
        }
        .highPriorityGesture(MagnifyGesture()
            .onChanged({ value in
                let scale = 1 + value.velocity
                if scale > 0 {
                    width *= pow(scale, 1/32)
                    print(pow(scale, 1/32))
                }
            }))
        .scrollIndicators(.never)
    }
}
