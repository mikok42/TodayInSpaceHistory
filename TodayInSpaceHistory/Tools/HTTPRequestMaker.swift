//
//  HTTPRequestMaker.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import Foundation
import Combine

struct APIConstants {
    static let baseURL: String = "https://images-api.nasa.gov"
    static let key: String = "LZbLlqQvVsMEUol6sIwGCIJbGEYzDerhRIFZN212"
}

enum Endpoints: String {
    case search = "/search"
    case asset = "/asset/"
    case captions = "/captions/"
    case album = "/album/"
    
    var queryParams: [URLQueryItem] {
        switch self {
        case .search:
            return [
                URLQueryItem(
                    name: "description",
                    value: Date.todayDayMonthComponents.joined(separator: " ")
                ),
                URLQueryItem(name: "media_type", value: "image")
            ]
        case .asset, .captions, .album:
            return []
        }
    }
    
    var url: URL? {
        switch self {
        case .search:
            var components = URLComponents(string: APIConstants.baseURL + rawValue)
            components?.queryItems = queryParams
            return components?.url
        case .asset, .captions, .album:
            return nil
        }
    }
    
    var method: HTTPMethods {
        switch self {
        case .search: return .get
        case .asset: return .get
        case .captions: return .get
        case .album: return .get
        }
    }
}

enum HTTPMethods: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    

}

protocol HTTPRequestMakerProtocol: AnyObject {
    func makeRequest<T>(endpoint: Endpoints) -> AnyPublisher<T, Error> where T : Decodable
    func fetchImages<T>(url: String) -> AnyPublisher<T, Error> where T : Decodable
}

class HTTPRequestMaker: HTTPRequestMakerProtocol {
    func fetchImages<T>(url: String) -> AnyPublisher<T, Error> where T : Decodable {
        guard let url = URL(string: url) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return perform(request: URLRequest(url: url), decoder: JSONDecoder())
    }
    
    func makeRequest<T>(endpoint: Endpoints) -> AnyPublisher<T, Error> where T: Decodable {
        guard let url = endpoint.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return perform(request: request, decoder: decoder)
    }
    
    private func perform<T: Decodable>(request: URLRequest, decoder: JSONDecoder) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
