//
//  ViewModel.swift
//  Endless images
//
//  Created by Ильнур Закиров on 10.02.2024.
//

import Foundation
import Combine

class FeedViewModel: ObservableObject {
    
    enum RequestState {
        case loading
        case loaded
        case pagination
    }
    
    let network = NetworkManager()
    var can = Set<AnyCancellable>()
    @Published var state = RequestState.loading
    @Published var errorDescription = ""
    @Published var isShowAlert = false
    @Published var model = [ImageModel]()
    var page = 0
    
    init() {
        loadImages()
    }
    
    func loadImages() {
        model.removeAll()
        do {
            try network.task(model: [ImageNetworkModel].self, queryItems: ["limit": "16", "page" : "\(page)"])
                .mapError{MyErrors.serverError($0.localizedDescription)}
                .receive(on: DispatchQueue.main)
                .sink { error in
                    switch error {
                    case .failure(let error):
                        self.errorDescription = error.localizedDescription
                        self.isShowAlert.toggle()
                    default: return
                    }
                } receiveValue: { model in
                    let newModel = model.sorted(by: {$0.height < $1.height})
                    self.model = newModel.map{.init(id: $0.id,
                                                    file: $0.url,
                                                    image: nil,
                                                    width: $0.width,
                                                    height: $0.height)}
                    self.state = .loaded
                }
                .store(in: &can)
        } catch {
            errorDescription = error.localizedDescription
            self.isShowAlert.toggle()
        }
            
    }
    
    func loadMoreImages() {
        state = .pagination
        page += 1
        do {
            try network.task(model: [ImageNetworkModel].self, queryItems: ["limit":"10", "page": "\(page)"])
                .mapError{MyErrors.serverError($0.localizedDescription)}
                .receive(on: DispatchQueue.main)
                .sink { error in
                    switch error {
                    case .failure(let error):
                        self.errorDescription = error.localizedDescription
                        self.isShowAlert.toggle()
                    default: return
                    }
                } receiveValue: { model in
                    print(model)
                    let newModel = model.sorted(by: {$0.height < $1.height})
                    self.model += newModel.map {.init(id: $0.id,
                                                      file: $0.url,
                                                      image: nil,
                                                      width: $0.width,
                                                      height: $0.height)}
                    self.state = .loaded
                }
                .store(in: &can)
        } catch {
            errorDescription = error.localizedDescription
            self.isShowAlert.toggle()
        }
    }
    
    func startLoadMore(image: ImageModel) -> Bool {
        image == model.last
    }
    
    func loadImage(index: Int) {
        guard model[index].image == nil else { return }
        guard let url = URL(string: model[index].file) else { return }
        let request = URLRequest(url: url)
        network.loadImage(request: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { error in
            }, receiveValue: { data in
                self.model[index].image = data
            })
            .store(in: &can)
    }
}
