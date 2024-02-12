//
//  NetworkManager.swift
//  Endless images
//
//  Created by Ильнур Закиров on 10.02.2024.
//

import Foundation
import Combine

enum MyErrors: Error {
    case wrongUrl
    case clientsError(Int)
    case serverError(String)
}

protocol NetworkManagerProtocol {
    func task<T: Decodable>(model: T.Type,queryItems: [String:String]) throws -> AnyPublisher<T, Error>
    func loadImage(request: URLRequest) -> AnyPublisher<Data, Never>
}

class NetworkManager: NetworkManagerProtocol {
    
    private let apiKey = "live_3XmmyATVYsZoZwkappGCzLEnfKBtJpw0E0zbcclV9vQrHBNqWoLvo8OLprMhMHR1"
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    private let cache = URLCache.shared
    
    private func buildUrl(queryItems: [String:String]) throws -> URL {
        
        var items = ["api_key": apiKey]
        queryItems.forEach{ items[$0.key] = $0.value }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.thecatapi.com"
        components.path = "/v1/images/search"
        components.queryItems = items.map{.init(name: $0.key, value: $0.value)}
        guard let url = components.url else { throw MyErrors.wrongUrl }
        return url
    }
    
    private func request(url: URL) -> URLRequest {
         URLRequest(url: url)
    }
    
    func task<T: Decodable>(model: T.Type,queryItems: [String:String]) throws -> AnyPublisher<T, Error> {
        let url = try buildUrl(queryItems: queryItems)
        let request = request(url: url)
        let publisher = URLSession.shared.dataTaskPublisher(for: request)
            .map{$0.data}
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
            
        return publisher
    }
    
    func loadImage(request: URLRequest) -> AnyPublisher<Data, Never> {
        if let data = cache.cachedResponse(for: request)?.data {
            return Just(data)
                .eraseToAnyPublisher()
        } else {
            let publisher = URLSession.shared.dataTaskPublisher(for: request)
                .map({ (data: Data, response: URLResponse) in
                    self.cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
                    return data
                })
            .replaceError(with: Data())
            .eraseToAnyPublisher()
        
        return publisher
                
        }
    }
}
