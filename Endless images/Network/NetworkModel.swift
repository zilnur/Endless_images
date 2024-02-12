//
//  NetworkModel.swift
//  Endless images
//
//  Created by Ильнур Закиров on 10.02.2024.
//

import Foundation

struct ImageNetworkModel: Decodable {
    let id: String
    let url: String
    let width: Int
    let height: Int
}
