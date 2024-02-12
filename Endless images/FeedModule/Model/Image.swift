//
//  Image.swift
//  Endless images
//
//  Created by Ильнур Закиров on 11.02.2024.
//

import Foundation

struct ImageModel: Identifiable, Hashable {
    let id: String
    let file: String
    var image: Data?
    let width: Int
    let height: Int
}
